const jwt = require('jsonwebtoken');
const { USER_JWT_SECRET } = require('../routes/mobile-auth');

function userAuthMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, USER_JWT_SECRET);
    req.user = { userId: decoded.userId, phone: decoded.phone };
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid or expired user token' });
  }
}

module.exports = { userAuthMiddleware };
