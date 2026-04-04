const express = require('express');
const db = require('../db');

const router = express.Router();

// --- Mapping helpers (same as admin routes) ---

function mapRestaurant(row) {
  // `id` is stable; name/ar fields are parallel translations of the same entity (bookings must use id only).
  return {
    id: row.id,
    name: row.name,
    arabicName: row.arabic_name,
    rating: row.rating,
    cuisine: row.cuisine,
    arabicCuisine: row.arabic_cuisine,
    imageName: row.image_name,
    hasMichelin: row.has_michelin === 1,
    description: row.description,
    arabicDescription: row.arabic_description,
    city: row.city,
    arabicCity: row.arabic_city,
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
}

function mapActivity(row) {
  // `id` is stable across locales; localized copy may be served per `Accept-Language` later — clients must key by id.
  return {
    id: row.id,
    name: row.name,
    rating: row.rating,
    category: row.category,
    imageName: row.image_name,
    location: row.location,
    description: row.description,
    city: row.city,
    arabicName: row.arabic_name ?? null,
    arabicCategory: row.arabic_category ?? null,
    arabicDescription: row.arabic_description ?? null,
    arabicLocation: row.arabic_location ?? null,
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
}

function mapSeasonEvent(row) {
  return {
    id: row.id,
    name: row.name,
    category: row.category,
    imageName: row.image_name,
    location: row.location,
    description: row.description,
    city: row.city,
    arabicName: row.arabic_name ?? null,
    arabicCategory: row.arabic_category ?? null,
    arabicDescription: row.arabic_description ?? null,
    arabicLocation: row.arabic_location ?? null,
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
}

// --- Generic paginated list query ---

function paginatedList(req, res, { table, mapFn }) {
  try {
    const { city, page = 1, limit = 20 } = req.query;
    const pageNum = parseInt(page, 10);
    const limitNum = parseInt(limit, 10);
    const offset = (pageNum - 1) * limitNum;

    let countSql = `SELECT COUNT(*) as total FROM ${table}`;
    let dataSql = `SELECT * FROM ${table}`;
    const params = [];

    if (city && city.trim() !== '') {
      countSql += ' WHERE city = ?';
      dataSql += ' WHERE city = ?';
      params.push(city);
    }

    dataSql += ' ORDER BY id ASC LIMIT ? OFFSET ?';

    const total = db.prepare(countSql).get(...params).total;
    const rows = db.prepare(dataSql).all(...params, limitNum, offset);

    res.json({
      data: rows.map(mapFn),
      total,
      page: pageNum,
      limit: limitNum,
      totalPages: Math.ceil(total / limitNum)
    });
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
}

// --- Generic single-item query ---

function singleItem(req, res, { table, mapFn, notFoundMsg }) {
  try {
    const row = db.prepare(`SELECT * FROM ${table} WHERE id = ?`).get(req.params.id);
    if (!row) {
      return res.status(404).json({ error: notFoundMsg });
    }
    res.json(mapFn(row));
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
}

// --- Restaurants ---

router.get('/restaurants', (req, res) => {
  paginatedList(req, res, { table: 'restaurants', mapFn: mapRestaurant });
});

router.get('/restaurants/:id', (req, res) => {
  singleItem(req, res, { table: 'restaurants', mapFn: mapRestaurant, notFoundMsg: 'Restaurant not found' });
});

// --- Activities ---

router.get('/activities', (req, res) => {
  paginatedList(req, res, { table: 'activities', mapFn: mapActivity });
});

router.get('/activities/:id', (req, res) => {
  singleItem(req, res, { table: 'activities', mapFn: mapActivity, notFoundMsg: 'Activity not found' });
});

// --- Season Events ---

router.get('/season-events', (req, res) => {
  paginatedList(req, res, { table: 'season_events', mapFn: mapSeasonEvent });
});

router.get('/season-events/:id', (req, res) => {
  singleItem(req, res, { table: 'season_events', mapFn: mapSeasonEvent, notFoundMsg: 'Season event not found' });
});

module.exports = router;
