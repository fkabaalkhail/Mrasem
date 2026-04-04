const express = require('express');
const crypto = require('crypto');
const db = require('../db');

const router = express.Router();

// Map DB row (snake_case) to camelCase response
function mapBooking(row) {
  return {
    id: row.id,
    ticketCode: row.ticket_code,
    placeTitle: row.place_title,
    subtitle: row.subtitle,
    imageName: row.image_name,
    dateDisplay: row.date_display,
    timeDisplay: row.time_display,
    branch: row.branch,
    qrPayload: row.qr_payload,
    eventDate: row.event_date,
    status: row.status,
    usesForkSubtitleIcon: row.uses_fork_subtitle_icon === 1,
    createdAt: row.created_at
  };
}

// GET /api/mobile/bookings — list bookings for the authenticated user
router.get('/', (req, res) => {
  try {
    const userId = req.user.userId;
    const { page = 1, limit = 20 } = req.query;
    const pageNum = parseInt(page, 10);
    const limitNum = parseInt(limit, 10);
    const offset = (pageNum - 1) * limitNum;

    const total = db.prepare(
      'SELECT COUNT(*) as total FROM bookings WHERE user_id = ?'
    ).get(userId).total;

    const rows = db.prepare(
      'SELECT * FROM bookings WHERE user_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?'
    ).all(userId, limitNum, offset);

    res.json({
      data: rows.map(mapBooking),
      total,
      page: pageNum,
      limit: limitNum,
      totalPages: Math.ceil(total / limitNum)
    });
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
});

// POST /api/mobile/bookings — create a booking for the authenticated user
router.post('/', (req, res) => {
  try {
    const userId = req.user.userId;
    const {
      placeTitle,
      subtitle = '',
      imageName = '',
      dateDisplay,
      timeDisplay,
      branch = '',
      eventDate,
      usesForkSubtitleIcon = false
    } = req.body;

    if (!placeTitle || !dateDisplay || !timeDisplay || !eventDate) {
      return res.status(400).json({ error: 'placeTitle, dateDisplay, timeDisplay, and eventDate are required' });
    }

    const ticketCode = 'TKT-' + crypto.randomBytes(6).toString('hex').toUpperCase();
    const qrPayload = JSON.stringify({ ticketCode, placeTitle, eventDate });

    const result = db.prepare(
      `INSERT INTO bookings (ticket_code, user_id, place_title, subtitle, image_name, date_display, time_display, branch, qr_payload, event_date, status, uses_fork_subtitle_icon)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', ?)`
    ).run(
      ticketCode,
      userId,
      placeTitle,
      subtitle,
      imageName,
      dateDisplay,
      timeDisplay,
      branch,
      qrPayload,
      eventDate,
      usesForkSubtitleIcon ? 1 : 0
    );

    const row = db.prepare('SELECT * FROM bookings WHERE id = ?').get(result.lastInsertRowid);
    res.status(201).json(mapBooking(row));
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
});

module.exports = router;
