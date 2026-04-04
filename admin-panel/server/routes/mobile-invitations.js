const express = require('express');
const crypto = require('crypto');
const db = require('../db');

const router = express.Router();

// Ensure sender_id column exists on sent_invitations
try {
  db.prepare("SELECT sender_id FROM sent_invitations LIMIT 1").get();
} catch (e) {
  db.exec("ALTER TABLE sent_invitations ADD COLUMN sender_id INTEGER REFERENCES users(id)");
}

// Ensure recipient_id column exists on received_invitations
try {
  db.prepare("SELECT recipient_id FROM received_invitations LIMIT 1").get();
} catch (e) {
  db.exec("ALTER TABLE received_invitations ADD COLUMN recipient_id INTEGER REFERENCES users(id)");
}

function mapSentInvitation(row) {
  return {
    id: row.id,
    outcome: row.outcome,
    placeTitle: row.place_title,
    subtitle: row.subtitle,
    imageName: row.image_name,
    dateDisplay: row.date_display,
    timeDisplay: row.time_display,
    branch: row.branch,
    recipientPhone: row.recipient_phone,
    createdAt: row.created_at
  };
}

function mapReceivedInvitation(row) {
  return {
    id: row.id,
    userResponse: row.user_response,
    placeTitle: row.place_title,
    subtitle: row.subtitle,
    imageName: row.image_name,
    dateDisplay: row.date_display,
    timeDisplay: row.time_display,
    branch: row.branch,
    inviterPhone: row.inviter_phone,
    createdAt: row.created_at
  };
}

// GET /api/mobile/invitations/sent — list sent invitations for the authenticated user
router.get('/sent', (req, res) => {
  try {
    const userId = req.user.userId;
    const { page = 1, limit = 20 } = req.query;
    const pageNum = parseInt(page, 10);
    const limitNum = parseInt(limit, 10);
    const offset = (pageNum - 1) * limitNum;

    const total = db.prepare(
      'SELECT COUNT(*) as total FROM sent_invitations WHERE sender_id = ?'
    ).get(userId).total;

    const rows = db.prepare(
      'SELECT * FROM sent_invitations WHERE sender_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?'
    ).all(userId, limitNum, offset);

    res.json({
      data: rows.map(mapSentInvitation),
      total,
      page: pageNum,
      limit: limitNum,
      totalPages: Math.ceil(total / limitNum)
    });
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
});

// GET /api/mobile/invitations/received — list received invitations for the authenticated user
router.get('/received', (req, res) => {
  try {
    const userId = req.user.userId;
    const { page = 1, limit = 20 } = req.query;
    const pageNum = parseInt(page, 10);
    const limitNum = parseInt(limit, 10);
    const offset = (pageNum - 1) * limitNum;

    const total = db.prepare(
      'SELECT COUNT(*) as total FROM received_invitations WHERE recipient_id = ?'
    ).get(userId).total;

    const rows = db.prepare(
      'SELECT * FROM received_invitations WHERE recipient_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?'
    ).all(userId, limitNum, offset);

    res.json({
      data: rows.map(mapReceivedInvitation),
      total,
      page: pageNum,
      limit: limitNum,
      totalPages: Math.ceil(total / limitNum)
    });
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
});

// POST /api/mobile/invitations — send an invitation
router.post('/', (req, res) => {
  try {
    const userId = req.user.userId;
    const senderPhone = req.user.phone;
    const {
      recipientPhone,
      placeTitle,
      subtitle = '',
      imageName = '',
      dateDisplay,
      timeDisplay,
      branch = ''
    } = req.body;

    if (!recipientPhone || !placeTitle || !dateDisplay || !timeDisplay) {
      return res.status(400).json({ error: 'recipientPhone, placeTitle, dateDisplay, and timeDisplay are required' });
    }

    const id = crypto.randomUUID();

    // Create sent invitation record (sender's perspective)
    db.prepare(
      `INSERT INTO sent_invitations (id, outcome, place_title, subtitle, image_name, date_display, time_display, branch, recipient_phone, sender_id)
       VALUES (?, 'pending', ?, ?, ?, ?, ?, ?, ?, ?)`
    ).run(id, placeTitle, subtitle, imageName, dateDisplay, timeDisplay, branch, recipientPhone, userId);

    // Look up recipient user by phone to set recipient_id
    const recipientUser = db.prepare('SELECT id FROM users WHERE phone = ?').get(recipientPhone);
    const recipientId = recipientUser ? recipientUser.id : null;

    // Create received invitation record (recipient's perspective)
    db.prepare(
      `INSERT INTO received_invitations (id, user_response, place_title, subtitle, image_name, date_display, time_display, branch, inviter_phone, recipient_id)
       VALUES (?, 'awaiting', ?, ?, ?, ?, ?, ?, ?, ?)`
    ).run(id, placeTitle, subtitle, imageName, dateDisplay, timeDisplay, branch, senderPhone, recipientId);

    const row = db.prepare('SELECT * FROM sent_invitations WHERE id = ?').get(id);
    res.status(201).json(mapSentInvitation(row));
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
});

// PATCH /api/mobile/invitations/:id/respond — accept or decline a received invitation
router.patch('/:id/respond', (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    const { response } = req.body;

    if (response !== 'accepted' && response !== 'declined') {
      return res.status(400).json({ error: "Response must be 'accepted' or 'declined'" });
    }

    // Verify the invitation belongs to this user
    const invitation = db.prepare(
      'SELECT * FROM received_invitations WHERE id = ? AND recipient_id = ?'
    ).get(id, userId);

    if (!invitation) {
      return res.status(404).json({ error: 'Invitation not found' });
    }

    // Update received invitation
    db.prepare(
      'UPDATE received_invitations SET user_response = ? WHERE id = ?'
    ).run(response, id);

    // Also update the corresponding sent invitation outcome
    db.prepare(
      'UPDATE sent_invitations SET outcome = ? WHERE id = ?'
    ).run(response, id);

    const updated = db.prepare('SELECT * FROM received_invitations WHERE id = ?').get(id);
    res.json(mapReceivedInvitation(updated));
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
});

module.exports = router;
