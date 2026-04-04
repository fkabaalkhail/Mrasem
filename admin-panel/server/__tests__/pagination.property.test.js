import fc from 'fast-check';
import request from 'supertest';
import { createTestApp } from './test-helper.js';

const app = createTestApp();

const PUBLIC_ENDPOINTS = [
  '/api/public/restaurants',
  '/api/public/activities',
  '/api/public/season-events',
];

// Feature: ios-api-integration, Property 8: Pagination correctness
// **Validates: Requirements 9.3**
describe('Property 8: Pagination correctness', () => {
  it('should return data.length <= limit, correct page, and totalPages = ceil(total/limit)', async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.integer({ min: 1, max: 10 }),
        fc.integer({ min: 1, max: 50 }),
        fc.constantFrom(...PUBLIC_ENDPOINTS),
        async (page, limit, endpoint) => {
          const res = await request(app)
            .get(endpoint)
            .query({ page, limit });

          expect(res.status).toBe(200);

          const { data, total, page: resPage, limit: resLimit, totalPages } = res.body;

          // data is an array with at most `limit` items
          expect(Array.isArray(data)).toBe(true);
          expect(data.length).toBeLessThanOrEqual(limit);

          // page in response matches requested page
          expect(resPage).toBe(page);

          // limit in response matches requested limit
          expect(resLimit).toBe(limit);

          // total is a non-negative integer
          expect(total).toBeGreaterThanOrEqual(0);

          // totalPages = ceil(total / limit)
          const expectedTotalPages = Math.ceil(total / limit);
          expect(totalPages).toBe(expectedTotalPages);

          // If page is within valid range, data length should be correct
          if (page <= totalPages && totalPages > 0) {
            // Last page may have fewer items
            if (page < totalPages) {
              expect(data.length).toBe(limit);
            } else {
              // Last page: remaining items
              const expectedLastPageItems = total - (page - 1) * limit;
              expect(data.length).toBe(expectedLastPageItems);
            }
          } else if (totalPages === 0) {
            // No data at all
            expect(data.length).toBe(0);
          } else {
            // Page beyond totalPages should return empty
            expect(data.length).toBe(0);
          }
        }
      ),
      { numRuns: 100 }
    );
  });
});
