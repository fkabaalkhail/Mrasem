const express = require('express');
const db = require('../db');

const router = express.Router();

// GET /sent — list sent invitations with pagination
router.get('/sent', (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const pageNum = parseInt(page, 10);
    const limitNum = parseInt(limit, 10);
    const offset = (pageNum - 1) * limitNum;

    const total = db.prepare('SELECT COUNT(*) as total FROM sent_invitations').get().total;
    const rows = db.prepare(
      'SELECT * FROM sent_invitations ORDER BY created_at DESC LIMIT ? OFFSET ?'
    ).all(limitNum, offset);

    res.json({
      data: rows.map(row => ({
        id: row.id,
        outcome: row.outcome,
        placeTitle: row.place_title,
        subtitle: row.subtitle,
        imageName: row.image_name,
        dateDisplay: row.date_display,
        timeDisplay: row.time_display,
        branch: row.branch,
        recipientPhone: row.recipient_phone
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

// GET /received — list received invitations with pagination
router.get('/received', (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const pageNum = parseInt(page, 10);
    const limitNum = parseInt(limit, 10);
    const offset = (pageNum - 1) * limitNum;

    const total = db.prepare('SELECT COUNT(*) as total FROM received_invitations').get().total;
    const rows = db.prepare(
      'SELECT * FROM received_invitations ORDER BY created_at DESC LIMIT ? OFFSET ?'
    ).all(limitNum, offset);

    res.json({
      data: rows.map(row => ({
        id: row.id,
        userResponse: row.user_response,
        placeTitle: row.place_title,
        subtitle: row.subtitle,
        imageName: row.image_name,
        dateDisplay: row.date_display,
        timeDisplay: row.time_display,
        branch: row.branch,
        inviterPhone: row.inviter_phone
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

module.exports = router;
