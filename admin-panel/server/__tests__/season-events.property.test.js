// Feature: admin-panel, Property 19: City filter returns only matching events
import fc from 'fast-check';
import request from 'supertest';
import { createTestApp } from './test-helper.js';

const app = createTestApp();

const VALID_EMAIL = 'admin@mrasem.com';
const VALID_PASSWORD = 'admin123';
const CITIES = ['Jeddah', 'Riyadh', 'Mecca', 'AlUla', 'Southern Provence'];

/**
 * Helper: login and return a valid JWT token.
 */
async function getAuthToken() {
  const res = await request(app)
    .post('/api/auth/login')
    .send({ email: VALID_EMAIL, password: VALID_PASSWORD });
  return res.body.token;
}

// **Validates: Requirements 13.2, 13.3**
describe('Property 19: City filter returns only matching events', () => {
  let token;

  beforeAll(async () => {
    token = await getAuthToken();
  });

  it('should return only season events matching the selected city filter', async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.constantFrom(...CITIES),
        async (selectedCity) => {
          const res = await request(app)
            .get(`/api/season-events?city=${encodeURIComponent(selectedCity)}`)
            .set('Authorization', `Bearer ${token}`);

          expect(res.status).toBe(200);
          expect(res.body).toHaveProperty('data');
          expect(Array.isArray(res.body.data)).toBe(true);

          // Every returned event must match the selected city
          for (const event of res.body.data) {
            expect(event.city).toBe(selectedCity);
          }

          // There should be at least one result for seeded cities
          expect(res.body.data.length).toBeGreaterThan(0);
        }
      ),
      { numRuns: 100 }
    );
  });

  it('should return all season events when no city filter is provided', async () => {
    // Get total count without filter
    const allRes = await request(app)
      .get('/api/season-events')
      .set('Authorization', `Bearer ${token}`);

    expect(allRes.status).toBe(200);
    expect(allRes.body).toHaveProperty('data');
    expect(allRes.body).toHaveProperty('total');
    expect(allRes.body.data.length).toBeGreaterThan(0);

    // Sum of per-city counts should equal total
    let cityTotal = 0;
    for (const city of CITIES) {
      const res = await request(app)
        .get(`/api/season-events?city=${encodeURIComponent(city)}&limit=100`)
        .set('Authorization', `Bearer ${token}`);
      cityTotal += res.body.data.length;
    }

    // Use a high limit to get all events in one page
    const allWithHighLimit = await request(app)
      .get('/api/season-events?limit=100')
      .set('Authorization', `Bearer ${token}`);

    expect(allWithHighLimit.body.data.length).toBe(cityTotal);
  });

  it('should return all season events when city param is empty string', async () => {
    const emptyRes = await request(app)
      .get('/api/season-events?city=&limit=100')
      .set('Authorization', `Bearer ${token}`);

    const allRes = await request(app)
      .get('/api/season-events?limit=100')
      .set('Authorization', `Bearer ${token}`);

    expect(emptyRes.status).toBe(200);
    expect(emptyRes.body.data.length).toBe(allRes.body.data.length);
  });
});
