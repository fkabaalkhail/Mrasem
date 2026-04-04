import fc from 'fast-check';
import request from 'supertest';
import { createTestApp } from './test-helper.js';

const app = createTestApp();

const SUPPORTED_CITIES = ['Jeddah', 'Riyadh', 'Mecca', 'AlUla', 'Southern Provence'];

const PUBLIC_ENDPOINTS = [
  '/api/public/restaurants',
  '/api/public/activities',
  '/api/public/season-events',
];

// Feature: ios-api-integration, Property 4: City filter returns only matching entities
// **Validates: Requirements 3.2, 4.2, 5.2, 9.2**
describe('Property 4: City filter returns only matching entities', () => {
  it('should return only entities matching the requested city for all public endpoints', async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.constantFrom(...SUPPORTED_CITIES),
        fc.constantFrom(...PUBLIC_ENDPOINTS),
        async (city, endpoint) => {
          const res = await request(app)
            .get(endpoint)
            .query({ city, limit: 100 });

          expect(res.status).toBe(200);
          expect(res.body).toHaveProperty('data');
          expect(Array.isArray(res.body.data)).toBe(true);

          // Every returned item must have city matching the requested city
          for (const item of res.body.data) {
            expect(item.city).toBe(city);
          }
        }
      ),
      { numRuns: 100 }
    );
  });
});
