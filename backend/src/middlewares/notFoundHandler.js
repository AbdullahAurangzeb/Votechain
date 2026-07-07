const { sendError } = require('../utils/apiResponse');
const AppError = require('../utils/AppError');

/**
 * Handles unmatched routes with a consistent 404 response.
 */
function notFoundHandler(req, res) {
  return sendError(res, {
    statusCode: 404,
    message: `Route not found: ${req.method} ${req.originalUrl}`,
  });
}

module.exports = notFoundHandler;
