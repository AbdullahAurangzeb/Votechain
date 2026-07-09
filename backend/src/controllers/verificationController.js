const fs = require('fs/promises');
const verificationService = require('../services/verificationService');
const { sendSuccess } = require('../utils/apiResponse');
const asyncHandler = require('../utils/asyncHandler');
const AppError = require('../utils/AppError');

/**
 * HTTP handlers for verification endpoints.
 */
const verificationController = {
  /**
   * POST /api/v1/verification/extract
   */
  extractCnic: asyncHandler(async (req, res) => {
    if (!req.file) {
      throw new AppError('CNIC image is required', 400);
    }

    try {
      const extraction = await verificationService.extractCnicFromImage(req.file);

      return sendSuccess(res, {
        message: 'CNIC extracted successfully',
        data: extraction,
      });
    } finally {
      await fs.unlink(req.file.path).catch(() => undefined);
    }
  }),

  /**
   * POST /api/v1/verification/submit
   */
  submitVerification: asyncHandler(async (req, res) => {
    const status = await verificationService.submitVerification(
      req.auth.sub,
      req.body,
    );

    return sendSuccess(res, {
      statusCode: 201,
      message: 'Verification submitted successfully',
      data: { status },
    });
  }),

  /**
   * GET /api/v1/verification/status
   */
  getStatus: asyncHandler(async (req, res) => {
    const status = await verificationService.getStatus(req.auth.sub);

    return sendSuccess(res, {
      message: 'Verification status retrieved successfully',
      data: { status },
    });
  }),
};

module.exports = verificationController;
