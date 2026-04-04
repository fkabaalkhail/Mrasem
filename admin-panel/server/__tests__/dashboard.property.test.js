import fc from 'fast-check';
import request from 'supertest';
import { createRequire } from 'module';
import { createTestApp } from './test-helper.js';

const require = createRequire(import.meta.url);
const app = createTestApp();

const VALID_EMAIL = 'admin@mrasem.com';
const VALID_PASSWORD = 'admin123';

async function getAuthToken() {
  const res = await request(app)
    .post('/api/auth/login')
    .send({ email: VALID_EMAIL, password: VALID_PASSWORD });
  return res.body.token;
}

// Feature: admin-panel, Property 3: Dashboard stats match database state
// **Validates: Requirements 2.1, 2.4**
describe('Property 3: Dashboard stats match database state', () => {
  let token;
  const db = require('../db');

  beforeAll(async () => {
    token = await getAuthToken();
  });

  afterEach(() => {
    // Clean up any test-inserted rows (keep only seeded data by removing rows with known test markers)
    db.prepare("DELETE FROM restaurants WHERE name LIKE 'test_%'").run();
    db.prepare("DELETE FROM activities WHERE name LIKE 'test_%'").run();
    db.prepare("DELETE FROM season_events WHERE name LIKE 'test_%'").run();
  });

  it('totalEvents count matches actual row counts in restaurants + activities + season_events after random inserts/deletes', async () => {
    await fc.assert(
      fc.asyncProperty(
        // Generate a list of operations: insert or delete on one of the 3 tables
        fc.array(
          fc.record({
            op: fc.constantFrom('insert', 'delete'),
            table: fc.constantFrom('restaurants', 'activities', 'season_events')
          }),
          { minLength: 1, maxLength: 10 }
        ),
        async (operations) => {
          const insertedIds = { restaurants: [], activities: [], season_events: [] };

          for (const { op, table } of operations) {
            if (op === 'insert') {
              let result;
              if (table === 'restaurants') {
                result = db.prepare(
                  "INSERT INTO restaurants (name, arabic_name, cuisine, city) VALUES (?, ?, ?, ?)"
                ).run(`test_${Date.now()}_${Math.random()}`, 'تجربة', 'Test Cuisine', 'Jeddah');
              } else if (table === 'activities') {
                result = db.prepare(
                  "INSERT INTO activities (name, category, city) VALUES (?, ?, ?)"
                ).run(`test_${Date.now()}_${Math.random()}`, 'Test Category', 'Riyadh');
              } else {
                result = db.prepare(
                  "INSERT INTO season_events (name, category, city) VALUES (?, ?, ?)"
                ).run(`test_${Date.now()}_${Math.random()}`, 'Test Category', 'Mecca');
              }
              insertedIds[table].push(result.lastInsertRowid);
            } else {
              // Delete a previously inserted row if any exist
              if (insertedIds[table].length > 0) {
                const id = insertedIds[table].pop();
                db.prepare(`DELETE FROM ${table} WHERE id = ?`).run(id);
              }
            }
          }

          // Fetch dashboard
          const res = await request(app)
            .get('/api/dashboard')
            .set('Authorization', `Bearer ${token}`);

          expect(res.status).toBe(200);

          // Get actual counts from DB
          const actualRestaurants = db.prepare('SELECT COUNT(*) as count FROM restaurants').get().count;
          const actualActivities = db.prepare('SELECT COUNT(*) as count FROM activities').get().count;
          const actualSeasonEvents = db.prepare('SELECT COUNT(*) as count FROM season_events').get().count;
          const expectedTotalEvents = actualRestaurants + actualActivities + actualSeasonEvents;

          expect(res.body.stats.totalEvents).toBe(expectedTotalEvents);

          // Also verify other stats match DB
          const actualBookings = db.prepare('SELECT COUNT(*) as count FROM bookings').get().count;
          const actualUsers = db.prepare('SELECT COUNT(*) as count FROM users').get().count;

          expect(res.body.stats.activeBookings).toBe(actualBookings);
          expect(res.body.stats.registeredUsers).toBe(actualUsers);

          // Cleanup inserted rows for this iteration
          for (const table of ['restaurants', 'activities', 'season_events']) {
            for (const id of insertedIds[table]) {
              db.prepare(`DELETE FROM ${table} WHERE id = ?`).run(id);
            }
          }
        }
      ),
      { numRuns: 100 }
    );
  });
});
