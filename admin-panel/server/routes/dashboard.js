const express = require('express');
const db = require('../db');

const router = express.Router();

// GET / — return stats + 5 most recent bookings
router.get('/', (req, res) => {
  try {
    const activeBookings = db.prepare('SELECT COUNT(*) as count FROM bookings').get().count;
    const registeredUsers = db.prepare('SELECT COUNT(*) as count FROM users').get().count;

    const restaurantCount = db.prepare('SELECT COUNT(*) as count FROM restaurants').get().count;
    const activityCount = db.prepare('SELECT COUNT(*) as count FROM activities').get().count;
    const seasonEventCount = db.prepare('SELECT COUNT(*) as count FROM season_events').get().count;
    const totalEvents = restaurantCount + activityCount + seasonEventCount;

    const recentBookings = db.prepare(`
      SELECT bookings.ticket_code, bookings.place_title, bookings.date_display,
             bookings.time_display, bookings.status, users.phone as userPhone
      FROM bookings
      LEFT JOIN users ON bookings.user_id = users.id
      ORDER BY bookings.created_at DESC
      LIMIT 5
    `).all();

    res.json({
      stats: {
        activeBookings,
        registeredUsers,
        totalEvents
      },
      recentBookings: recentBookings.map(row => ({
        ticketCode: row.ticket_code,
        placeTitle: row.place_title,
        dateDisplay: row.date_display,
        timeDisplay: row.time_display,
        userPhone: row.userPhone || null,
        status: row.status
      }))
    });
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
});

module.exports = router;
