const authService = require('../services/authService');
const { sendSuccess } = require('../utils/apiResponse');
const asyncHandler = require('../utils/asyncHandler');

/**
 * HTTP handlers for authentication endpoints.
 */
const authController = {
  /**
   * POST /api/v1/auth/register
   */
  register: asyncHandler(async (req, res) => {
    const user = await authService.register(req.body);

    return sendSuccess(res, {
      statusCode: 201,
      message: 'Registration successful',
      data: { user },
    });
  }),

  /**
   * POST /api/v1/auth/login
   */
  login: asyncHandler(async (req, res) => {
    const { user, token } = await authService.login(req.body);

    return sendSuccess(res, {
      message: 'Login successful',
      data: { user, token },
    });
  }),

  /**
   * GET /api/v1/auth/me
   */
  getMe: asyncHandler(async (req, res) => {
    const user = await authService.getProfile(req.auth.sub);

    return sendSuccess(res, {
      message: 'Profile retrieved successfully',
      data: { user },
    });
  }),
};

module.exports = authController;
