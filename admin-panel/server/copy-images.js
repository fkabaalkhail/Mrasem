/**
 * One-time script: copies iOS asset images into /uploads/ and updates
 * the database image_name column so the admin panel can display them.
 *
 * Usage: node copy-images.js
 */
const fs = require('fs');
const path = require('path');
const db = require('./db');

const ASSETS_DIR = path.join(__dirname, '..', '..', 'Mrasem', 'Mrasem', 'Assets.xcassets');
const UPLOADS_DIR = path.join(__dirname, '..', 'uploads');

// Ensure uploads directory exists
if (!fs.existsSync(UPLOADS_DIR)) {
  fs.mkdirSync(UPLOADS_DIR, { recursive: true });
}

const tables = ['restaurants', 'activities', 'season_events'];
let copied = 0;
let updated = 0;

for (const table of tables) {
  const rows = db.prepare(`SELECT id, image_name FROM ${table}`).all();

  for (const row of rows) {
    const assetName = row.image_name;

    // Skip if already an uploads path
    if (assetName.startsWith('/uploads/')) continue;

    // Find the imageset directory
    const imagesetDir = path.join(ASSETS_DIR, `${assetName}.imageset`);
    if (!fs.existsSync(imagesetDir)) {
      console.log(`  SKIP: ${assetName} — no imageset found`);
      continue;
    }

    // Find the actual image file (png or jpg)
    const files = fs.readdirSync(imagesetDir).filter(f =>
      f.endsWith('.png') || f.endsWith('.jpg') || f.endsWith('.jpeg')
    );

    if (files.length === 0) {
      console.log(`  SKIP: ${assetName} — no image file in imageset`);
      continue;
    }

    const sourceFile = path.join(imagesetDir, files[0]);
    const ext = path.extname(files[0]);
    const destFilename = `${assetName}${ext}`;
    const destPath = path.join(UPLOADS_DIR, destFilename);

    // Copy the file
    if (!fs.existsSync(destPath)) {
      fs.copyFileSync(sourceFile, destPath);
      copied++;
    }

    // Update the database
    const newImageName = `/uploads/${destFilename}`;
    db.prepare(`UPDATE ${table} SET image_name = ? WHERE id = ?`).run(newImageName, row.id);
    updated++;
  }
}

console.log(`Done! Copied ${copied} images, updated ${updated} database rows.`);
