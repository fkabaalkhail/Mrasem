const express = require('express');
const multer = require('multer');
const path = require('path');
const db = require('../db');

const router = express.Router();

// Configure multer for image uploads
const storage = multer.diskStorage({
  destination: path.join(__dirname, '../../uploads/'),
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  }
});

const fileFilter = (req, file, cb) => {
  if (file.mimetype === 'image/jpeg' || file.mimetype === 'image/png') {
    cb(null, true);
  } else {
    cb(new Error('Only JPEG and PNG images are accepted'), false);
  }
};

const upload = multer({ storage, fileFilter });

// Handle multer errors (invalid file type)
function handleUpload(req, res, next) {
  upload.single('image')(req, res, (err) => {
    if (err) {
      return res.status(400).json({ error: err.message });
    }
    next();
  });
}

// Map DB row (snake_case) to camelCase response
function mapRestaurant(row) {
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

// GET / — list restaurants with optional city filter + pagination
router.get('/', (req, res) => {
  try {
    const { city, page = 1, limit = 20 } = req.query;
    const pageNum = parseInt(page, 10);
    const limitNum = parseInt(limit, 10);
    const offset = (pageNum - 1) * limitNum;

    let countSql = 'SELECT COUNT(*) as total FROM restaurants';
    let dataSql = 'SELECT * FROM restaurants';
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
      data: rows.map(mapRestaurant),
      total,
      page: pageNum,
      limit: limitNum,
      totalPages: Math.ceil(total / limitNum)
    });
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
});

// GET /:id — single restaurant
router.get('/:id', (req, res) => {
  try {
    const row = db.prepare('SELECT * FROM restaurants WHERE id = ?').get(req.params.id);
    if (!row) {
      return res.status(404).json({ error: 'Restaurant not found' });
    }
    res.json(mapRestaurant(row));
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
});

// POST / — create restaurant
router.post('/', handleUpload, (req, res) => {
  try {
    const { name, arabicName, rating, cuisine, arabicCuisine, hasMichelin, description, arabicDescription, city, arabicCity } = req.body;

    // Validate required fields
    const missing = [];
    if (!name || name.trim() === '') missing.push('name');
    if (!arabicName || arabicName.trim() === '') missing.push('arabicName');
    if (!cuisine || cuisine.trim() === '') missing.push('cuisine');
    if (!city || city.trim() === '') missing.push('city');

    if (missing.length > 0) {
      return res.status(400).json({ error: `Missing required fields: ${missing.join(', ')}` });
    }

    // Validate rating if provided
    if (rating !== undefined && rating !== null && rating !== '') {
      const ratingNum = parseFloat(rating);
      if (isNaN(ratingNum) || ratingNum < 0 || ratingNum > 5) {
        return res.status(400).json({ error: 'Rating must be between 0 and 5' });
      }
    }

    const imageName = req.file ? `/uploads/${req.file.filename}` : '';
    const ratingVal = (rating !== undefined && rating !== null && rating !== '') ? parseFloat(rating) : 0;
    const hasMichelinVal = hasMichelin === 'true' || hasMichelin === '1' || hasMichelin === true ? 1 : 0;

    const stmt = db.prepare(`
      INSERT INTO restaurants (name, arabic_name, rating, cuisine, arabic_cuisine, image_name, has_michelin, description, arabic_description, city, arabic_city)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);

    const result = stmt.run(
      name.trim(),
      arabicName.trim(),
      ratingVal,
      cuisine.trim(),
      (arabicCuisine || '').trim(),
      imageName,
      hasMichelinVal,
      (description || '').trim(),
      (arabicDescription || '').trim(),
      city.trim(),
      (arabicCity || '').trim()
    );

    const created = db.prepare('SELECT * FROM restaurants WHERE id = ?').get(result.lastInsertRowid);
    res.status(201).json(mapRestaurant(created));
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
});

// PUT /:id — update restaurant
router.put('/:id', handleUpload, (req, res) => {
  try {
    const existing = db.prepare('SELECT * FROM restaurants WHERE id = ?').get(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Restaurant not found' });
    }

    const { name, arabicName, rating, cuisine, arabicCuisine, hasMichelin, description, arabicDescription, city, arabicCity } = req.body;

    // Validate required fields
    const missing = [];
    if (!name || name.trim() === '') missing.push('name');
    if (!arabicName || arabicName.trim() === '') missing.push('arabicName');
    if (!cuisine || cuisine.trim() === '') missing.push('cuisine');
    if (!city || city.trim() === '') missing.push('city');

    if (missing.length > 0) {
      return res.status(400).json({ error: `Missing required fields: ${missing.join(', ')}` });
    }

    // Validate rating if provided
    if (rating !== undefined && rating !== null && rating !== '') {
      const ratingNum = parseFloat(rating);
      if (isNaN(ratingNum) || ratingNum < 0 || ratingNum > 5) {
        return res.status(400).json({ error: 'Rating must be between 0 and 5' });
      }
    }

    const imageName = req.file ? `/uploads/${req.file.filename}` : existing.image_name;
    const ratingVal = (rating !== undefined && rating !== null && rating !== '') ? parseFloat(rating) : existing.rating;
    const hasMichelinVal = hasMichelin === 'true' || hasMichelin === '1' || hasMichelin === true ? 1 : 0;

    const stmt = db.prepare(`
      UPDATE restaurants
      SET name = ?, arabic_name = ?, rating = ?, cuisine = ?, arabic_cuisine = ?, image_name = ?, has_michelin = ?, description = ?, arabic_description = ?, city = ?, arabic_city = ?, updated_at = datetime('now')
      WHERE id = ?
    `);

    stmt.run(
      name.trim(),
      arabicName.trim(),
      ratingVal,
      cuisine.trim(),
      (arabicCuisine || '').trim(),
      imageName,
      hasMichelinVal,
      (description || '').trim(),
      (arabicDescription || '').trim(),
      city.trim(),
      (arabicCity || '').trim(),
      req.params.id
    );

    const updated = db.prepare('SELECT * FROM restaurants WHERE id = ?').get(req.params.id);
    res.json(mapRestaurant(updated));
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
});

// DELETE /:id — delete restaurant
router.delete('/:id', (req, res) => {
  try {
    const existing = db.prepare('SELECT * FROM restaurants WHERE id = ?').get(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Restaurant not found' });
    }

    db.prepare('DELETE FROM restaurants WHERE id = ?').run(req.params.id);
    res.json({ message: 'Restaurant deleted' });
  } catch (err) {
    res.status(500).json({ error: 'An unexpected error occurred. Please try again.' });
  }
});

module.exports = router;
