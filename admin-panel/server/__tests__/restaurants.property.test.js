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

// Feature: admin-panel, Property 10: Entity CRUD round-trip
// **Validates: Requirements 4.3, 4.4**
describe('Property 10: Entity CRUD round-trip (restaurants)', () => {
  let token;

  beforeAll(async () => {
    token = await getAuthToken();
  });

  it('should create a restaurant via POST and fetch it via GET with equivalent data', async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.record({
          name: fc.string({ minLength: 1, maxLength: 50 }).filter(s => s.trim().length > 0),
          arabicName: fc.string({ minLength: 1, maxLength: 50 }).filter(s => s.trim().length > 0),
          cuisine: fc.string({ minLength: 1, maxLength: 50 }).filter(s => s.trim().length > 0),
          city: fc.constantFrom('Jeddah', 'Riyadh', 'Mecca', 'AlUla', 'Southern Provence'),
          rating: fc.float({ min: 0, max: 5, noNaN: true }).map(r => Math.round(r * 10) / 10),
          arabicCuisine: fc.string({ maxLength: 50 }),
          description: fc.string({ maxLength: 100 }),
          arabicDescription: fc.string({ maxLength: 100 }),
          arabicCity: fc.string({ maxLength: 50 }),
          hasMichelin: fc.boolean(),
        }),
        async (data) => {
          // POST — create restaurant (as form fields, no image)
          const createRes = await request(app)
            .post('/api/restaurants')
            .set('Authorization', `Bearer ${token}`)
            .field('name', data.name)
            .field('arabicName', data.arabicName)
            .field('cuisine', data.cuisine)
            .field('city', data.city)
            .field('rating', String(data.rating))
            .field('arabicCuisine', data.arabicCuisine)
            .field('description', data.description)
            .field('arabicDescription', data.arabicDescription)
            .field('arabicCity', data.arabicCity)
            .field('hasMichelin', String(data.hasMichelin));

          expect(createRes.status).toBe(201);
          const created = createRes.body;
          expect(created).toHaveProperty('id');

          // GET — fetch the created restaurant by ID
          const getRes = await request(app)
            .get(`/api/restaurants/${created.id}`)
            .set('Authorization', `Bearer ${token}`);

          expect(getRes.status).toBe(200);
          const fetched = getRes.body;

          // Verify all submitted fields match
          expect(fetched.name).toBe(data.name.trim());
          expect(fetched.arabicName).toBe(data.arabicName.trim());
          expect(fetched.cuisine).toBe(data.cuisine.trim());
          expect(fetched.city).toBe(data.city.trim());
          expect(fetched.rating).toBeCloseTo(data.rating, 1);
          expect(fetched.arabicCuisine).toBe(data.arabicCuisine.trim());
          expect(fetched.description).toBe(data.description.trim());
          expect(fetched.arabicDescription).toBe(data.arabicDescription.trim());
          expect(fetched.arabicCity).toBe(data.arabicCity.trim());
          expect(fetched.hasMichelin).toBe(data.hasMichelin);

          // Clean up — delete the created restaurant
          await request(app)
            .delete(`/api/restaurants/${created.id}`)
            .set('Authorization', `Bearer ${token}`);
        }
      ),
      { numRuns: 100 }
    );
  });
});


// Feature: admin-panel, Property 12: Required field validation rejects incomplete submissions
// **Validates: Requirements 4.6**
describe('Property 12: Required field validation rejects incomplete submissions (restaurants)', () => {
  let token;

  const REQUIRED_FIELDS = ['name', 'arabicName', 'cuisine', 'city'];

  beforeAll(async () => {
    token = await getAuthToken();
  });

  it('should return 400 when random required fields are removed from restaurant data', async () => {
    await fc.assert(
      fc.asyncProperty(
        // Generate complete restaurant data
        fc.record({
          name: fc.string({ minLength: 1, maxLength: 50 }).filter(s => s.trim().length > 0),
          arabicName: fc.string({ minLength: 1, maxLength: 50 }).filter(s => s.trim().length > 0),
          cuisine: fc.string({ minLength: 1, maxLength: 50 }).filter(s => s.trim().length > 0),
          city: fc.constantFrom('Jeddah', 'Riyadh', 'Mecca', 'AlUla', 'Southern Provence'),
          rating: fc.float({ min: 0, max: 5, noNaN: true }).map(r => Math.round(r * 10) / 10),
        }),
        // Generate a non-empty subset of required fields to remove
        fc.subarray(REQUIRED_FIELDS, { minLength: 1 }),
        async (data, fieldsToRemove) => {
          // Build form data, omitting the randomly selected required fields
          const req = request(app)
            .post('/api/restaurants')
            .set('Authorization', `Bearer ${token}`);

          for (const [key, value] of Object.entries(data)) {
            if (!fieldsToRemove.includes(key)) {
              req.field(key, String(value));
            }
          }

          const res = await req;

          expect(res.status).toBe(400);
          expect(res.body).toHaveProperty('error');
          expect(res.body.error).toMatch(/Missing required fields/i);
        }
      ),
      { numRuns: 100 }
    );
  });
});
