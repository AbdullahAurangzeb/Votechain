/**
 * Standard VoteChain API success response envelope.
 * @param {import('express').Response} res
 * @param {object} options
 */
function sendSuccess(res, { statusCode = 200, message = 'OK', data = null } = {}) {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
    errors: null,
  });
}

/**
 * Standard VoteChain API error response envelope.
 * @param {import('express').Response} res
 * @param {object} options
 */
function sendError(
  res,
  { statusCode = 500, message = 'Internal server error', errors = null } = {},
) {
  return res.status(statusCode).json({
    success: false,
    message,
    data: null,
    errors,
  });
}

module.exports = { sendSuccess, sendError };
