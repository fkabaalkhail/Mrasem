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

const PHONE_REGEX = /^\+966\d{9}$/;

// Feature: admin-panel, Property 9: Phone numbers follow +966 format
// **Validates: Requirements 3.6, 7.4, 12.3**
describe('Property 9: Phone numbers follow +966 format', () => {
  let token;

  beforeAll(async () => {
    token = await getAuthToken();
  });

  it('all user phone numbers match +966 followed by 9 digits', async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.constant(null),
        async () => {
          const res = await request(app)
            .get('/api/users')
            .query({ limit: 100 })
            .set('Authorization', `Bearer ${token}`);

          expect(res.status).toBe(200);
          const { data } = res.body;

          for (const user of data) {
            expect(user.phone).toMatch(PHONE_REGEX);
          }
        }
      ),
      { numRuns: 10 }
    );
  });

  it('all booking userPhone numbers match +966 followed by 9 digits', async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.constant(null),
        async () => {
          const res = await request(app)
            .get('/api/bookings')
            .query({ limit: 100 })
            .set('Authorization', `Bearer ${token}`);

          expect(res.status).toBe(200);
          const { data } = res.body;

          for (const booking of data) {
            if (booking.userPhone) {
              expect(booking.userPhone).toMatch(PHONE_REGEX);
            }
          }
        }
      ),
      { numRuns: 10 }
    );
  });
});
