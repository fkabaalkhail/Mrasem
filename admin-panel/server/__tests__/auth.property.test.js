import fc from 'fast-check';
import request from 'supertest';
import { createTestApp } from './test-helper.js';

const app = createTestApp();

// The only valid credentials in the seeded database
const VALID_EMAIL = 'admin@mrasem.com';
const VALID_PASSWORD = 'change-me';

// Feature: admin-panel, Property 1: Invalid credentials are always rejected
// **Validates: Requirements 1.3**
describe('Property 1: Invalid credentials are always rejected', () => {
  it('should return 401 for any random email/password that is not the valid admin credential', async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.string({ minLength: 1, maxLength: 100 }),
        fc.string({ minLength: 1, maxLength: 100 }),
        async (email, password) => {
          // Filter out the exact valid credentials to avoid false positives
          fc.pre(email !== VALID_EMAIL || password !== VALID_PASSWORD);

          const res = await request(app)
            .post('/api/auth/login')
            .send({ email, password });

          expect(res.status).toBe(401);
          expect(res.body).toHaveProperty('error');
          expect(res.body.error).toBe('Invalid email or password');
        }
      ),
      { numRuns: 100 }
    );
  });
});

// Feature: admin-panel, Property 2: Protected routes require valid authentication
// **Validates: Requirements 1.5**
describe('Property 2: Protected routes require valid authentication', () => {
  const protectedRoutes = [
    '/api/restaurants',
    '/api/activities',
    '/api/bookings',
    '/api/users',
    '/api/dashboard',
    '/api/season-events',
  ];

  it('should return 401 for any random invalid token on all protected routes', async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.string({ minLength: 1, maxLength: 200 }),
        fc.constantFrom(...protectedRoutes),
        async (randomToken, route) => {
          const res = await request(app)
            .get(route)
            .set('Authorization', `Bearer ${randomToken}`);

          expect(res.status).toBe(401);
          expect(res.body).toHaveProperty('error');
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should return 401 when no Authorization header is provided on all protected routes', async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.constantFrom(...protectedRoutes),
        async (route) => {
          const res = await request(app).get(route);

          expect(res.status).toBe(401);
          expect(res.body).toHaveProperty('error');
          expect(res.body.error).toBe('Authentication required');
        }
      ),
      { numRuns: 100 }
    );
  });
});
