const express = require('express');
const { sendSuccess } = require('../utils/apiResponse');
const asyncHandler = require('../utils/asyncHandler');
const authRoutes = require('./authRoutes');
const verificationRoutes = require('./verificationRoutes');

const router = express.Router();

/**
 * Infrastructure health probe — not a business API endpoint.
 */
router.get(
  '/health',
  asyncHandler(async (_req, res) => {
    return sendSuccess(res, {
      message: 'VoteChain API is running',
      data: {
        status: 'ok',
        timestamp: new Date().toISOString(),
      },
    });
  }),
);

router.use('/auth', authRoutes);
router.use('/verification', verificationRoutes);

module.exports = router;
