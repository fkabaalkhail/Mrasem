import { createRequire } from 'module';
import request from 'supertest';
import { createTestApp } from './test-helper.js';

const require = createRequire(import.meta.url);
const app = createTestApp();
const db = require('../db');

// ─── 14.4 Mobile auth and public routes unit tests ─────────────────────────
// Validates: Requirements 9.1, 9.4, 9.5

describe('Mobile Auth - send-otp', () => {
  const testPhone = '+966500000001';

  afterEach(() => {
    // Clean up OTP records for the test phone
    db.prepare('DELETE FROM otp_codes WHERE phone = ?').run(testPhone);
  });

  it('POST /api/mobile/auth/send-otp creates an OTP record in the database', async () => {
    const res = await request(app)
      .post('/api/mobile/auth/send-otp')
      .send({ phone: testPhone });

    expect(res.status).toBe(200);
    expect(res.body.message).toBe('OTP sent successfully');

    // Verify OTP record was created in the database
    const otpRecord = db.prepare('SELECT * FROM otp_codes WHERE phone = ?').get(testPhone);
    expect(otpRecord).toBeDefined();
    expect(otpRecord.phone).toBe(testPhone);
    expect(otpRecord.code).toMatch(/^\d{6}$/);
    expect(otpRecord.expires_at).toBeDefined();
  });

  it('returns 400 when phone number is missing', async () => {
    const res = await request(app)
      .post('/api/mobile/auth/send-otp')
      .send({});

    expect(res.status).toBe(400);
    expect(res.body.error).toBeDefined();
  });
});

describe('Mobile Auth - verify-otp', () => {
  const testPhone = '+966500000002';

  afterEach(() => {
    db.prepare('DELETE FROM otp_codes WHERE phone = ?').run(testPhone);
    db.prepare('DELETE FROM users WHERE phone = ?').run(testPhone);
  });

  it('POST /api/mobile/auth/verify-otp returns a user JWT on correct code', async () => {
    // First, send an OTP to create the record
    await request(app)
      .post('/api/mobile/auth/send-otp')
      .send({ phone: testPhone });

    // Read the OTP code directly from the database
    const otpRecord = db.prepare('SELECT * FROM otp_codes WHERE phone = ?').get(testPhone);
    expect(otpRecord).toBeDefined();

    // Verify with the correct code
    const res = await request(app)
      .post('/api/mobile/auth/verify-otp')
      .send({ phone: testPhone, code: otpRecord.code });

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('token');
    expect(typeof res.body.token).toBe('string');
    expect(res.body.token.split('.')).toHaveLength(3); // JWT has 3 parts
    expect(res.body.user).toBeDefined();
    expect(res.body.user.phone).toBe(testPhone);
  });

  it('returns 401 for an incorrect OTP code', async () => {
    await request(app)
      .post('/api/mobile/auth/send-otp')
      .send({ phone: testPhone });

    const res = await request(app)
      .post('/api/mobile/auth/verify-otp')
      .send({ phone: testPhone, code: '000000' });

    expect(res.status).toBe(401);
    expect(res.body.error).toBeDefined();
  });
});

describe('Public endpoints - no auth required', () => {
  it('GET /api/public/restaurants returns 200 without auth', async () => {
    const res = await request(app).get('/api/public/restaurants');

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('data');
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body).toHaveProperty('total');
    expect(res.body).toHaveProperty('page');
  });

  it('GET /api/public/activities returns 200 without auth', async () => {
    const res = await request(app).get('/api/public/activities');

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('data');
    expect(Array.isArray(res.body.data)).toBe(true);
  });

  it('GET /api/public/season-events returns 200 without auth', async () => {
    const res = await request(app).get('/api/public/season-events');

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('data');
    expect(Array.isArray(res.body.data)).toBe(true);
  });
});

describe('Mobile bookings - requires user JWT', () => {
  it('GET /api/mobile/bookings returns 401 without auth', async () => {
    const res = await request(app).get('/api/mobile/bookings');

    expect(res.status).toBe(401);
    expect(res.body.error).toBeDefined();
  });

  it('GET /api/mobile/bookings returns 200 with valid user JWT', async () => {
    const testPhone = '+966500000003';

    // Create OTP and verify to get a user JWT
    await request(app)
      .post('/api/mobile/auth/send-otp')
      .send({ phone: testPhone });

    const otpRecord = db.prepare('SELECT * FROM otp_codes WHERE phone = ?').get(testPhone);
    const verifyRes = await request(app)
      .post('/api/mobile/auth/verify-otp')
      .send({ phone: testPhone, code: otpRecord.code });

    const userToken = verifyRes.body.token;

    // Access bookings with the user JWT
    const res = await request(app)
      .get('/api/mobile/bookings')
      .set('Authorization', `Bearer ${userToken}`);

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('data');
    expect(Array.isArray(res.body.data)).toBe(true);

    // Cleanup
    db.prepare('DELETE FROM otp_codes WHERE phone = ?').run(testPhone);
    db.prepare('DELETE FROM users WHERE phone = ?').run(testPhone);
  });

  it('GET /api/mobile/bookings returns 401 with an invalid token', async () => {
    const res = await request(app)
      .get('/api/mobile/bookings')
      .set('Authorization', 'Bearer invalid.token.here');

    expect(res.status).toBe(401);
    expect(res.body.error).toBeDefined();
  });
});
