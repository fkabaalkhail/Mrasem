const express = require('express');
const db = require('../db');

const router = express.Router();

// GET / — list users with phone search + pagination, include booking count per user
router.get('/', (req, res) => {
  try {
    const { search, page = 1, limit = 20 } = req.query;
    const pageNum = parseInt(page, 10);
    const limitNum = parseInt(limit, 10);
    const offset = (pageNum - 1) * limitNum;

    let countSql = 'SELECT COUNT(*) as total FROM users';
    let dataSql = `
      SELECT users.id, users.phone, users.created_at,
             COUNT(bookings.id) as bookingCount
      FROM users
      LEFT JOIN bookings ON bookings.user_id = users.id
    `;
    const params = [];

    if (search && search.trim() !== '') {
      const whereClause = ' WHERE users.phone LIKE ?';
      const searchParam = `%${search.trim()}%`;
      countSql += whereClause;
      dataSql += whereClause;
      params.push(searchParam);
    }

    dataSql += ' GROUP BY users.id ORDER BY users.id ASC LIMIT ? OFFSET ?';

    const total = db.prepare(countSql).get(...params).total;
    const rows = db.prepare(dataSql).all(...params, limitNum, offset);

    res.json({
      data: rows.map(row => ({
        id: row.id,
        phone: row.phone,
        createdAt: row.created_at,
        bookingCount: row.bookingCount
      })),
      total,
      page: pageNum,
      limit: limitNum,
      totalPages: Math.ceil(total / limitNum)
    });
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
});

// GET /:id — user detail with phone, registration date, and all associated bookings
router.get('/:id', (req, res) => {
  try {
    const user = db.prepare('SELECT id, phone, created_at FROM users WHERE id = ?').get(req.params.id);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const bookings = db.prepare(
      'SELECT * FROM bookings WHERE user_id = ? ORDER BY id ASC'
    ).all(req.params.id);

    res.json({
      id: user.id,
      phone: user.phone,
      createdAt: user.created_at,
      bookings: bookings.map(row => ({
        id: row.id,
        ticketCode: row.ticket_code,
        userId: row.user_id,
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
      }))
    });
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
});

module.exports = router;
