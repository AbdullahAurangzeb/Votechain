const { sendError } = require('../utils/apiResponse');
const AppError = require('../utils/AppError');

/**
 * Global error handler — returns standardized JSON error envelopes.
 * @param {Error} err
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} _next
 */
function errorHandler(err, req, res, _next) {
  let normalizedError = err;

  if (err.name === 'MongoServerError' && err.code === 11000) {
    const field = Object.keys(err.keyPattern || {})[0] || 'field';
    normalizedError = new AppError(`${field} is already registered`, 409);
  }

  const isOperational =
    normalizedError instanceof AppError || normalizedError.isOperational === true;

  const statusCode = isOperational ? normalizedError.statusCode || 400 : 500;
  const message = isOperational
    ? normalizedError.message
    : 'Internal server error';

  if (!isOperational) {
    console.error('[UnhandledError]', {
      method: req.method,
      path: req.originalUrl,
      message: normalizedError.message,
      stack: normalizedError.stack,
    });
  }

  return sendError(res, {
    statusCode,
    message,
    errors: normalizedError.errors || null,
  });
}

module.exports = errorHandler;
