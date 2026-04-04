import fc from 'fast-check';
import request from 'supertest';
import { createTestApp } from './test-helper.js';

const app = createTestApp();

const VALID_EMAIL = 'admin@mrasem.com';
const VALID_PASSWORD = 'admin123';

/**
 * Helper: login and return a valid JWT token.
 */
async function getAuthToken() {
  const res = await request(app)
    .post('/api/auth/login')
    .send({ email: VALID_EMAIL, password: VALID_PASSWORD });
  return res.body.token;
}

// Feature: admin-panel, Property 11: Entity deletion removes the record
// **Validates: Requirements 5.5**
describe('Property 11: Entity deletion removes the record (activities)', () => {
  let token;

  beforeAll(async () => {
    token = await getAuthToken();
  });

  it('should return 404 when fetching a deleted activity', async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.record({
          name: fc.string({ minLength: 1, maxLength: 50 }).filter(s => s.trim().length > 0),
          category: fc.string({ minLength: 1, maxLength: 50 }).filter(s => s.trim().length > 0),
          city: fc.constantFrom('Jeddah', 'Riyadh', 'Mecca', 'AlUla', 'Southern Provence'),
          rating: fc.float({ min: 0, max: 5, noNaN: true }).map(r => Math.round(r * 10) / 10),
          location: fc.string({ maxLength: 100 }),
          description: fc.string({ maxLength: 100 }),
        }),
        async (data) => {
          // POST — create activity
          const createRes = await request(app)
            .post('/api/activities')
            .set('Authorization', `Bearer ${token}`)
            .field('name', data.name)
            .field('category', data.category)
            .field('city', data.city)
            .field('rating', String(data.rating))
            .field('location', data.location)
            .field('description', data.description);

          expect(createRes.status).toBe(201);
          const created = createRes.body;
          expect(created).toHaveProperty('id');

          // DELETE — remove the activity
          const deleteRes = await request(app)
            .delete(`/api/activities/${created.id}`)
            .set('Authorization', `Bearer ${token}`);

          expect(deleteRes.status).toBe(200);

          // GET — fetch the deleted activity by ID, expect 404
          const getRes = await request(app)
            .get(`/api/activities/${created.id}`)
            .set('Authorization', `Bearer ${token}`);

          expect(getRes.status).toBe(404);
        }
      ),
      { numRuns: 100 }
    );
  });
});
