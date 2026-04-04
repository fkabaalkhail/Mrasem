import fc from 'fast-check';
import request from 'supertest';
import { createTestApp } from './test-helper.js';

const app = createTestApp();

const PUBLIC_ENDPOINTS = [
  '/api/public/restaurants',
  '/api/public/activities',
  '/api/public/season-events',
];

const PROTECTED_ENDPOINTS = [
  '/api/mobile/bookings',
  '/api/mobile/invitations/sent',
  '/api/mobile/invitations/received',
];

// Feature: ios-api-integration, Property 7: Public endpoints accessible without authentication
// **Validates: Requirements 9.1, 9.5**
describe('Property 7: Public endpoints accessible without authentication', () => {
  it('should return 200 for public endpoints without any auth header', async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.constantFrom(...PUBLIC_ENDPOINTS),
        async (endpoint) => {
          const res = await request(app)
            .get(endpoint);

          expect(res.status).toBe(200);
          expect(res.body).toHaveProperty('data');
          expect(Array.isArray(res.body.data)).toBe(true);
          expect(res.body).toHaveProperty('total');
          expect(res.body).toHaveProperty('page');
          expect(res.body).toHaveProperty('limit');
          expect(res.body).toHaveProperty('totalPages');
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should return 401 for protected endpoints without any auth header', async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.constantFrom(...PROTECTED_ENDPOINTS),
        async (endpoint) => {
          const res = await request(app)
            .get(endpoint);

          expect(res.status).toBe(401);
        }
      ),
      { numRuns: 100 }
    );
  });
});
