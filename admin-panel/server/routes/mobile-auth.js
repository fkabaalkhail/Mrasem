const express = require('express');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const db = require('../db');

const router = express.Router();

const USER_JWT_SECRET = process.env.USER_JWT_SECRET || 'change-me';

// Generate a random 6-digit OTP
function generateOTP() {
  return crypto.randomInt(100000, 999999).toString();
}

// POST /api/mobile/auth/send-otp
router.post('/send-otp', (req, res) => {
  const { phone } = req.body;

  if (!phone) {
    return res.status(400).json({ error: 'Phone number is required' });
  }

  const code = generateOTP();
  const expiresAt = new Date(Date.now() + 5 * 60 * 1000).toISOString();

  // Delete any existing OTPs for this phone
  db.prepare('DELETE FROM otp_codes WHERE phone = ?').run(phone);

  // Insert new OTP
  db.prepare('INSERT INTO otp_codes (phone, code, expires_at) VALUES (?, ?, ?)').run(phone, code, expiresAt);

  // In production, send OTP via SMS here
  // For development, log it
  console.log(`[DEV] OTP for ${phone}: ${code}`);

  res.json({ message: 'OTP sent successfully' });
});

// POST /api/mobile/auth/verify-otp
router.post('/verify-otp', (req, res) => {
  const { phone, code } = req.body;

  if (!phone || !code) {
    return res.status(400).json({ error: 'Phone number and OTP code are required' });
  }

  const otpRecord = db.prepare(
    'SELECT * FROM otp_codes WHERE phone = ? AND code = ? ORDER BY created_at DESC LIMIT 1'
  ).get(phone, code);

  if (!otpRecord) {
    return res.status(401).json({ error: 'Invalid OTP code' });
  }

  // Check expiry
  if (new Date(otpRecord.expires_at) < new Date()) {
    db.prepare('DELETE FROM otp_codes WHERE id = ?').run(otpRecord.id);
    return res.status(401).json({ error: 'OTP code has expired' });
  }

  // Delete used OTP
  db.prepare('DELETE FROM otp_codes WHERE phone = ?').run(phone);

  // Create user if not exists
  let user = db.prepare('SELECT * FROM users WHERE phone = ?').get(phone);
  if (!user) {
    const result = db.prepare('INSERT INTO users (phone) VALUES (?)').run(phone);
    user = { id: result.lastInsertRowid, phone };
  }

  // Sign user JWT
  const token = jwt.sign(
    { userId: user.id, phone: user.phone },
    USER_JWT_SECRET,
    { expiresIn: '30d' }
  );

  res.json({ token, user: { id: user.id, phone: user.phone } });
});

// GET /api/mobile/auth/validate
router.get('/validate', (req, res) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, USER_JWT_SECRET);
    res.json({ valid: true, user: { id: decoded.userId, phone: decoded.phone } });
  } catch (err) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
});

module.exports = router;
module.exports.USER_JWT_SECRET = USER_JWT_SECRET;
