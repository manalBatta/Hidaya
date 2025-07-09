const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ status: false, message: 'No token provided' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, 'secret'); // Same key used to sign
         console.log('Decoded:', decoded);

    if (!decoded || !decoded._id) {
      return res.status(401).json({ status: false, message: 'Invalid token payload!1!!!1' });
    }

    req.userId = decoded._id; // UUID like "a48f938c-e414-4109-a3d8-28671dad0aa0"
    req.userEmail = decoded.email;
    req.userRole = decoded.role;

    next();
  } catch (err) {
      console.log('JWT verification error:', err.message);

    return res.status(403).json({ status: false, message: 'Invalid or expired token' });
  }
};

module.exports = authMiddleware;
