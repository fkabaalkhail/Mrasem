const express = require('express');
const QRCode = require('qrcode');
const db = require('../db');

const router = express.Router();

// Map DB row (snake_case) to camelCase response
function mapBooking(row) {
  return {
    id: row.id,
    ticketCode: row.ticket_code,
    userId: row.user_id,
    userPhone: row.userPhone || null,
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

// GET / — list bookings with search + pagination
router.get('/', (req, res) => {
  try {
    const { search, page = 1, limit = 20 } = req.query;
    const pageNum = parseInt(page, 10);
    const limitNum = parseInt(limit, 10);
    const offset = (pageNum - 1) * limitNum;

    let countSql = 'SELECT COUNT(*) as total FROM bookings LEFT JOIN users ON bookings.user_id = users.id';
    let dataSql = 'SELECT bookings.*, users.phone as userPhone FROM bookings LEFT JOIN users ON bookings.user_id = users.id';
    const params = [];

    if (search && search.trim() !== '') {
      const whereClause = ' WHERE bookings.ticket_code LIKE ? OR bookings.place_title LIKE ? OR users.phone LIKE ?';
      const searchParam = `%${search.trim()}%`;
      countSql += whereClause;
      dataSql += whereClause;
      params.push(searchParam, searchParam, searchParam);
    }

    dataSql += ' ORDER BY bookings.id ASC LIMIT ? OFFSET ?';

    const total = db.prepare(countSql).get(...params).total;
    const rows = db.prepare(dataSql).all(...params, limitNum, offset);

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

// GET /:id — booking detail
router.get('/:id', (req, res) => {
  try {
    const row = db.prepare(
      'SELECT bookings.*, users.phone as userPhone FROM bookings LEFT JOIN users ON bookings.user_id = users.id WHERE bookings.id = ?'
    ).get(req.params.id);

    if (!row) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    res.json(mapBooking(row));
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
});

// PATCH /:id — update booking status (approve/reject)
router.patch('/:id', (req, res) => {
  try {
    const { status } = req.body;

    if (status !== 'approved' && status !== 'rejected') {
      return res.status(400).json({ error: "Status must be 'approved' or 'rejected'" });
    }

    const existing = db.prepare('SELECT * FROM bookings WHERE id = ?').get(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    db.prepare('UPDATE bookings SET status = ? WHERE id = ?').run(status, req.params.id);

    const row = db.prepare(
      'SELECT bookings.*, users.phone as userPhone FROM bookings LEFT JOIN users ON bookings.user_id = users.id WHERE bookings.id = ?'
    ).get(req.params.id);

    res.json(mapBooking(row));
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
});

// GET /:id/qr — generate QR code PNG from qrPayload
router.get('/:id/qr', async (req, res) => {
  try {
    const row = db.prepare('SELECT qr_payload FROM bookings WHERE id = ?').get(req.params.id);

    if (!row) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    const buffer = await QRCode.toBuffer(row.qr_payload);
    res.set('Content-Type', 'image/png');
    res.send(buffer);
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
});

module.exports = router;
