const Database = require('better-sqlite3');
const path = require('path');

const dbPath = path.join(__dirname, '..', 'mrasem.db');
const db = new Database(dbPath);

// Enable WAL mode for better performance
db.pragma('journal_mode = WAL');

// Enable foreign keys
db.pragma('foreign_keys = ON');

// Create all tables
db.exec(`
  CREATE TABLE IF NOT EXISTS admin_users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TEXT DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS restaurants (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    arabic_name TEXT NOT NULL,
    rating REAL DEFAULT 0 CHECK(rating >= 0 AND rating <= 5),
    cuisine TEXT NOT NULL,
    arabic_cuisine TEXT DEFAULT '',
    image_name TEXT DEFAULT '',
    has_michelin INTEGER DEFAULT 0,
    description TEXT DEFAULT '',
    arabic_description TEXT DEFAULT '',
    city TEXT NOT NULL,
    arabic_city TEXT DEFAULT '',
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS activities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    rating REAL DEFAULT 0 CHECK(rating >= 0 AND rating <= 5),
    category TEXT NOT NULL,
    image_name TEXT DEFAULT '',
    location TEXT DEFAULT '',
    description TEXT DEFAULT '',
    city TEXT NOT NULL,
    arabic_name TEXT DEFAULT '',
    arabic_category TEXT DEFAULT '',
    arabic_description TEXT DEFAULT '',
    arabic_location TEXT DEFAULT '',
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS season_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    image_name TEXT DEFAULT '',
    location TEXT DEFAULT '',
    description TEXT DEFAULT '',
    city TEXT NOT NULL,
    arabic_name TEXT DEFAULT '',
    arabic_category TEXT DEFAULT '',
    arabic_description TEXT DEFAULT '',
    arabic_location TEXT DEFAULT '',
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    phone TEXT UNIQUE NOT NULL,
    created_at TEXT DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS bookings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ticket_code TEXT UNIQUE NOT NULL,
    user_id INTEGER REFERENCES users(id),
    place_title TEXT NOT NULL,
    subtitle TEXT DEFAULT '',
    image_name TEXT DEFAULT '',
    date_display TEXT NOT NULL,
    time_display TEXT NOT NULL,
    branch TEXT DEFAULT '',
    qr_payload TEXT NOT NULL,
    event_date TEXT NOT NULL,
    status TEXT DEFAULT 'pending' CHECK(status IN ('pending', 'approved', 'rejected')),
    uses_fork_subtitle_icon INTEGER DEFAULT 0,
    created_at TEXT DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS otp_codes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    phone TEXT NOT NULL,
    code TEXT NOT NULL,
    expires_at TEXT NOT NULL,
    created_at TEXT DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS sent_invitations (
    id TEXT PRIMARY KEY,
    outcome TEXT DEFAULT 'pending' CHECK(outcome IN ('pending', 'accepted', 'declined')),
    place_title TEXT NOT NULL,
    subtitle TEXT DEFAULT '',
    image_name TEXT DEFAULT '',
    date_display TEXT NOT NULL,
    time_display TEXT NOT NULL,
    branch TEXT DEFAULT '',
    recipient_phone TEXT NOT NULL,
    created_at TEXT DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS received_invitations (
    id TEXT PRIMARY KEY,
    user_response TEXT DEFAULT 'awaiting' CHECK(user_response IN ('awaiting', 'accepted', 'declined')),
    place_title TEXT NOT NULL,
    subtitle TEXT DEFAULT '',
    image_name TEXT DEFAULT '',
    date_display TEXT NOT NULL,
    time_display TEXT NOT NULL,
    branch TEXT DEFAULT '',
    inviter_phone TEXT NOT NULL,
    created_at TEXT DEFAULT (datetime('now'))
  );
`);

const { seedDatabase } = require('./seed-data');
const { backfillArabicListings } = require('./listing-arabic-backfill');

seedDatabase(db);
backfillArabicListings(db);

module.exports = db;
