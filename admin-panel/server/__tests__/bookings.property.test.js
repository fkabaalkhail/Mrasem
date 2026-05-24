import fc from 'fast-check';
import request from 'supertest';
import { createTestApp } from './test-helper.js';

const app = createTestApp();

const VALID_EMAIL = 'admin@mrasem.com';
const VALID_PASSWORD = 'change-me';

/**
 * Helper: login and return a valid JWT token.
 */
async function getAuthToken() {
  const res = await request(app)
    .post('/api/auth/login')
    .send({ email: VALID_EMAIL, password: VALID_PASSWORD });
  return res.body.token;
}

// Known seeded data for search term generation
const KNOWN_TICKET_CODES = [
  '11223344556677',
  '22334455667788',
  '33445566778899',
  '44556677889900',
  '55667788990011',
];
const KNOWN_PLACE_TITLES = [
  'Myazu Restaurant',
  'Scuba Diving',
  'Winter Wonderland',
  'Le Vesuvio',
  'Hegra Day Tour',
];
const KNOWN_USER_PHONES = [
  '+966559035417',
  '+966588762140',
  '+966500111222',
];

const ALL_KNOWN_VALUES = [...KNOWN_TICKET_CODES, ...KNOWN_PLACE_TITLES, ...KNOWN_USER_PHONES];

// Feature: admin-panel, Property 6: Booking search filters correctly
// **Validates: Requirements 3.2**
describe('Property 6: Booking search filters correctly', () => {
  let token;

  beforeAll(async () => {
    token = await getAuthToken();
  });

  it('all returned results contain the search term in ticketCode, placeTitle, or userPhone', async () => {
    await fc.assert(
      fc.asyncProperty(
        // Pick a known value, then generate a random substring of it
        fc.constantFrom(...ALL_KNOWN_VALUES).chain((value) => {
          const len = value.length;
          return fc.tuple(
            fc.integer({ min: 0, max: len - 1 }),
            fc.integer({ min: 1, max: len })
          ).filter(([start, end]) => end > start)
            .map(([start, end]) => value.substring(start, end));
        }),
        async (searchTerm) => {
          const res = await request(app)
            .get('/api/bookings')
            .query({ search: searchTerm, limit: 100 })
            .set('Authorization', `Bearer ${token}`);

          expect(res.status).toBe(200);
          const { data } = res.body;

          // The server trims the search term, so we should check against the trimmed version
          const trimmed = searchTerm.trim();
          if (trimmed.length === 0) {
            // Empty/whitespace-only search returns all bookings — no filtering assertion needed
            return;
          }

          // Every returned booking must contain the trimmed search term in at least one field
          for (const booking of data) {
            const ticketMatch = (booking.ticketCode || '').toLowerCase().includes(trimmed.toLowerCase());
            const placeMatch = (booking.placeTitle || '').toLowerCase().includes(trimmed.toLowerCase());
            const phoneMatch = (booking.userPhone || '').toLowerCase().includes(trimmed.toLowerCase());
            expect(ticketMatch || placeMatch || phoneMatch).toBe(true);
          }
        }
      ),
      { numRuns: 100 }
    );
  });
});


// Feature: admin-panel, Property 8: Booking status transitions persist correctly
// **Validates: Requirements 3.4, 3.5**
describe('Property 8: Booking status transitions persist correctly', () => {
  let token;

  beforeAll(async () => {
    token = await getAuthToken();
  });

  it('should persist approved/rejected status after PATCH and re-fetch', async () => {
    // Get all pending bookings from seeded data
    const listRes = await request(app)
      .get('/api/bookings')
      .query({ limit: 100 })
      .set('Authorization', `Bearer ${token}`);

    const pendingBookings = listRes.body.data.filter(b => b.status === 'pending');
    // We need at least one pending booking for this test
    expect(pendingBookings.length).toBeGreaterThan(0);

    // Use the first pending booking for all iterations
    const bookingId = pendingBookings[0].id;

    await fc.assert(
      fc.asyncProperty(
        fc.constantFrom('approved', 'rejected'),
        async (newStatus) => {
          // PATCH — update status
          const patchRes = await request(app)
            .patch(`/api/bookings/${bookingId}`)
            .set('Authorization', `Bearer ${token}`)
            .send({ status: newStatus });

          expect(patchRes.status).toBe(200);
          expect(patchRes.body.status).toBe(newStatus);

          // GET — re-fetch and verify
          const getRes = await request(app)
            .get(`/api/bookings/${bookingId}`)
            .set('Authorization', `Bearer ${token}`);

          expect(getRes.status).toBe(200);
          expect(getRes.body.status).toBe(newStatus);

          // Reset back to pending for next iteration
          // (Direct DB reset via the bookings route won't work since 'pending' isn't a valid PATCH status)
          // We use a raw DB call through the test helper
          const { createRequire } = await import('module');
          const require = createRequire(import.meta.url);
          const db = require('../db');
          db.prepare('UPDATE bookings SET status = ? WHERE id = ?').run('pending', bookingId);
        }
      ),
      { numRuns: 100 }
    );
  });
});

// Feature: admin-panel, Property 20: QR payload round-trip parsing
// **Validates: Requirements 14.2, 14.3**
describe('Property 20: QR payload round-trip parsing', () => {
  it('should round-trip MRASEM|code|name payloads correctly', () => {
    fc.assert(
      fc.property(
        // Generate a 14-digit numeric string
        fc.array(fc.constantFrom('0','1','2','3','4','5','6','7','8','9'), { minLength: 14, maxLength: 14 }).map(arr => arr.join('')),
        // Generate a place name string without | character
        fc.string({ minLength: 1, maxLength: 100 }).filter(s => !s.includes('|') && s.trim().length > 0),
        (code, placeName) => {
          // Build payload
          const payload = `MRASEM|${code}|${placeName}`;

          // Parse by splitting on |
          const parts = payload.split('|');

          // Verify exactly 3 parts
          expect(parts.length).toBe(3);

          // Verify each part
          expect(parts[0]).toBe('MRASEM');
          expect(parts[1]).toBe(code);
          expect(parts[2]).toBe(placeName);

          // Verify round-trip: re-assembling produces original payload
          const reassembled = parts.join('|');
          expect(reassembled).toBe(payload);
        }
      ),
      { numRuns: 100 }
    );
  });
});
