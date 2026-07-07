/**
 * Operational HTTP error with status code and optional validation details.
 */
class AppError extends Error {
  /**
   * @param {string} message
   * @param {number} statusCode
   * @param {Array<object>|null} errors
   */
  constructor(message, statusCode = 500, errors = null) {
    super(message);
    this.name = 'AppError';
    this.statusCode = statusCode;
    this.errors = errors;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

module.exports = AppError;
