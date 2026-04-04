const express = require('express');
const cors = require('cors');
const path = require('path');

// Trigger database initialization and seeding
require('./db');

const { authMiddleware } = require('./middleware/auth');

// Import route files
const authRoutes = require('./routes/auth');
const restaurantRoutes = require('./routes/restaurants');
const activityRoutes = require('./routes/activities');
const seasonEventRoutes = require('./routes/season-events');
const bookingRoutes = require('./routes/bookings');
const userRoutes = require('./routes/users');
const invitationRoutes = require('./routes/invitations');
const dashboardRoutes = require('./routes/dashboard');
const publicRoutes = require('./routes/public');
const mobileAuthRoutes = require('./routes/mobile-auth');
const mobileBookingRoutes = require('./routes/mobile-bookings');
const mobileInvitationRoutes = require('./routes/mobile-invitations');
const { userAuthMiddleware } = require('./middleware/user-auth');

const app = express();
const PORT = process.env.PORT || 3001;

// Enable CORS for admin panel and iOS app requests
app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, curl, etc.)
    if (!origin) return callback(null, true);
    const allowedOrigins = ['http://localhost:5173', 'http://localhost:3001'];
    if (allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    // Allow any origin for mobile app requests
    return callback(null, true);
  },
  credentials: true
}));

// Parse JSON bodies
app.use(express.json());

// Serve uploaded images as static files
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

// Health check route
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Public routes (no auth required)
app.use('/api/auth', authRoutes);
app.use('/api/public', publicRoutes);
app.use('/api/mobile/auth', mobileAuthRoutes);

// User-protected routes (user JWT required)
app.use('/api/mobile/bookings', userAuthMiddleware, mobileBookingRoutes);
app.use('/api/mobile/invitations', userAuthMiddleware, mobileInvitationRoutes);

// Protected routes (admin auth required)
app.use('/api/restaurants', authMiddleware, restaurantRoutes);
app.use('/api/activities', authMiddleware, activityRoutes);
app.use('/api/season-events', authMiddleware, seasonEventRoutes);
app.use('/api/bookings', authMiddleware, bookingRoutes);
app.use('/api/users', authMiddleware, userRoutes);
app.use('/api/invitations', authMiddleware, invitationRoutes);
app.use('/api/dashboard', authMiddleware, dashboardRoutes);

app.listen(PORT, () => {
  console.log(`Mrasem Admin API server running on http://localhost:${PORT}`);
});

module.exports = app;
