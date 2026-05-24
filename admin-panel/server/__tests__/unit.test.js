import { createRequire } from 'module';
import request from 'supertest';
import { createTestApp } from './test-helper.js';

const require = createRequire(import.meta.url);
const app = createTestApp();
const db = require('../db');

// Helper: login and return auth token
async function getAuthToken() {
  const res = await request(app)
    .post('/api/auth/login')
    .send({ email: 'admin@mrasem.com', password: 'change-me' });
  return res.body.token;
}

// ─── 24.1 Auth unit tests ───────────────────────────────────────────────────
// Validates: Requirements 1.2, 1.3
describe('Auth', () => {
  it('login with correct credentials returns token', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: 'admin@mrasem.com', password: 'change-me' });

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('token');
    expect(typeof res.body.token).toBe('string');
    expect(res.body.user.email).toBe('admin@mrasem.com');
  });

  it('login with wrong password returns 401', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: 'admin@mrasem.com', password: 'wrongpassword' });

    expect(res.status).toBe(401);
    expect(res.body.error).toBe('Invalid email or password');
  });
});

// ─── 24.2 Seed data unit tests ─────────────────────────────────────────────
// Validates: Requirements 9.2
describe('Seed data', () => {
  it('seed creates 33 restaurants, 26 activities, 19 season events', () => {
    const restaurants = db.prepare('SELECT COUNT(*) as c FROM restaurants').get().c;
    const activities = db.prepare('SELECT COUNT(*) as c FROM activities').get().c;
    const seasonEvents = db.prepare('SELECT COUNT(*) as c FROM season_events').get().c;

    expect(restaurants).toBe(33);
    expect(activities).toBe(26);
    expect(seasonEvents).toBe(19);
  });

  it('admin user exists with correct email', () => {
    const admin = db.prepare('SELECT * FROM admin_users WHERE email = ?').get('admin@mrasem.com');
    expect(admin).toBeDefined();
    expect(admin.email).toBe('admin@mrasem.com');
  });
});


// ─── 24.3 Bookings unit tests ──────────────────────────────────────────────
// Validates: Requirements 3.1, 3.2, 14.1
describe('Bookings', () => {
  let token;

  beforeAll(async () => {
    token = await getAuthToken();
  });

  it('QR payload generation produces MRASEM|code|name format', async () => {
    const res = await request(app)
      .get('/api/bookings?limit=100')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    for (const booking of res.body.data) {
      const parts = booking.qrPayload.split('|');
      expect(parts).toHaveLength(3);
      expect(parts[0]).toBe('MRASEM');
      expect(parts[1]).toBe(booking.ticketCode);
      expect(parts[2]).toBe(booking.placeTitle);
    }
  });

  it('pagination returns correct page size and total count', async () => {
    const res = await request(app)
      .get('/api/bookings?page=1&limit=2')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(res.body.data.length).toBeLessThanOrEqual(2);
    expect(res.body.limit).toBe(2);
    expect(res.body.page).toBe(1);
    expect(typeof res.body.total).toBe('number');
    expect(res.body.total).toBeGreaterThan(0);
    expect(res.body.totalPages).toBe(Math.ceil(res.body.total / 2));
  });

  it('empty search returns all bookings', async () => {
    const allRes = await request(app)
      .get('/api/bookings')
      .set('Authorization', `Bearer ${token}`);

    const emptySearchRes = await request(app)
      .get('/api/bookings?search=')
      .set('Authorization', `Bearer ${token}`);

    expect(allRes.body.total).toBe(emptySearchRes.body.total);
  });

  it('approving already-approved booking is idempotent', async () => {
    // Find or create an approved booking
    const listRes = await request(app)
      .get('/api/bookings?limit=100')
      .set('Authorization', `Bearer ${token}`);

    const booking = listRes.body.data[0];

    // Approve it
    await request(app)
      .patch(`/api/bookings/${booking.id}`)
      .set('Authorization', `Bearer ${token}`)
      .send({ status: 'approved' });

    // Approve again — should be idempotent
    const res = await request(app)
      .patch(`/api/bookings/${booking.id}`)
      .set('Authorization', `Bearer ${token}`)
      .send({ status: 'approved' });

    expect(res.status).toBe(200);
    expect(res.body.status).toBe('approved');
  });
});

// ─── 24.4 Image upload unit tests ──────────────────────────────────────────
// Validates: Requirements 8.2, 8.4
describe('Image upload', () => {
  let token;

  beforeAll(async () => {
    token = await getAuthToken();
  });

  it('valid PNG upload succeeds', async () => {
    // Minimal 1x1 pixel PNG buffer
    const pngBuffer = Buffer.from(
      '89504e470d0a1a0a0000000d49484452000000010000000108060000001f15c489' +
      '0000000a49444154789c626000000002000198e195280000000049454e44ae426082',
      'hex'
    );

    const res = await request(app)
      .post('/api/restaurants')
      .set('Authorization', `Bearer ${token}`)
      .field('name', 'Test Restaurant PNG')
      .field('arabicName', 'مطعم تجريبي')
      .field('cuisine', 'Test')
      .field('city', 'Jeddah')
      .attach('image', pngBuffer, 'test.png');

    expect(res.status).toBe(201);
    expect(res.body.imageName).toMatch(/\/uploads\/.+\.png$/);

    // Cleanup
    db.prepare('DELETE FROM restaurants WHERE id = ?').run(res.body.id);
  });

  it('.txt file upload fails with 400', async () => {
    const txtBuffer = Buffer.from('this is not an image');

    const res = await request(app)
      .post('/api/restaurants')
      .set('Authorization', `Bearer ${token}`)
      .field('name', 'Test Restaurant TXT')
      .field('arabicName', 'مطعم تجريبي')
      .field('cuisine', 'Test')
      .field('city', 'Jeddah')
      .attach('image', txtBuffer, 'test.txt');

    expect(res.status).toBe(400);
    expect(res.body.error).toMatch(/JPEG|PNG/i);
  });
});

// ─── 24.5 City filter unit tests ───────────────────────────────────────────
// Validates: Requirements 13.2, 13.3
describe('City filter', () => {
  let token;

  beforeAll(async () => {
    token = await getAuthToken();
  });

  it('city filter "All" returns all records', async () => {
    // No city param = all records
    const allRes = await request(app)
      .get('/api/restaurants?limit=100')
      .set('Authorization', `Bearer ${token}`);

    expect(allRes.status).toBe(200);
    expect(allRes.body.total).toBeGreaterThan(0);

    // Verify multiple cities are present
    const cities = new Set(allRes.body.data.map(r => r.city));
    expect(cities.size).toBeGreaterThan(1);
  });

  it('specific city returns only matching records', async () => {
    const res = await request(app)
      .get('/api/restaurants?city=Jeddah&limit=100')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(res.body.data.length).toBeGreaterThan(0);
    for (const restaurant of res.body.data) {
      expect(restaurant.city).toBe('Jeddah');
    }
  });
});
