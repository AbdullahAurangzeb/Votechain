const AppError = require('../utils/AppError');
const asyncHandler = require('../utils/asyncHandler');
const { verifyAccessToken } = require('../config/jwt');

/**
 * Verifies JWT bearer tokens on protected routes.
 */
const authenticate = asyncHandler(async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new AppError('Authentication required', 401);
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = verifyAccessToken(token);
    req.auth = decoded;
    next();
  } catch {
    throw new AppError('Invalid or expired token', 401);
  }
});

/**
 * Restricts access to one or more roles. Requires authenticate middleware first.
 * @param {...string} roles
 * @returns {import('express').RequestHandler}
 */
function authorize(...roles) {
  return (req, res, next) => {
    if (!req.auth) {
      return next(new AppError('Authentication required', 401));
    }

    if (roles.length > 0 && !roles.includes(req.auth.role)) {
      return next(new AppError('Insufficient permissions', 403));
    }

    return next();
  };
}

module.exports = { authenticate, authorize };
