import { createRequire } from 'module';
const require = createRequire(import.meta.url);

const express = require('express');
const cors = require('cors');

/**
 * Creates a fresh Express app with auth routes mounted for testing.
 * This avoids depending on the main index.js wiring (task 11).
 */
export function createTestApp() {
  // Ensure the database is initialized (importing db.js triggers table creation + seeding)
  const db = require('../db');
  const authRoutes = require('../routes/auth');
  const { authMiddleware } = require('../middleware/auth');
  const { userAuthMiddleware } = require('../middleware/user-auth');

  const app = express();
  app.use(cors());
  app.use(express.json());

  // Public routes (no auth required)
  app.use('/api/auth', authRoutes);
  const publicRoutes = require('../routes/public');
  app.use('/api/public', publicRoutes);

  // Mobile auth routes (no auth required)
  const mobileAuthRoutes = require('../routes/mobile-auth');
  app.use('/api/mobile/auth', mobileAuthRoutes);

  // User-protected mobile routes (user JWT required)
  const mobileBookingRoutes = require('../routes/mobile-bookings');
  app.use('/api/mobile/bookings', userAuthMiddleware, mobileBookingRoutes);
  const mobileInvitationRoutes = require('../routes/mobile-invitations');
  app.use('/api/mobile/invitations', userAuthMiddleware, mobileInvitationRoutes);

  // Admin-protected routes (admin auth required)
  const restaurantRoutes = require('../routes/restaurants');
  app.use('/api/restaurants', authMiddleware, restaurantRoutes);

  const activityRoutes = require('../routes/activities');
  app.use('/api/activities', authMiddleware, activityRoutes);

  const seasonEventRoutes = require('../routes/season-events');
  app.use('/api/season-events', authMiddleware, seasonEventRoutes);

  const bookingRoutes = require('../routes/bookings');
  app.use('/api/bookings', authMiddleware, bookingRoutes);

  const userRoutes = require('../routes/users');
  app.use('/api/users', authMiddleware, userRoutes);

  const invitationRoutes = require('../routes/invitations');
  app.use('/api/invitations', authMiddleware, invitationRoutes);

  const dashboardRoutes = require('../routes/dashboard');
  app.use('/api/dashboard', authMiddleware, dashboardRoutes);

  return app;
}
