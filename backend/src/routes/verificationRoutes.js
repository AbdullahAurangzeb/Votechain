const express = require('express');
const verificationController = require('../controllers/verificationController');
const { authenticate } = require('../middlewares/auth');
const validate = require('../middlewares/validate');
const { upload } = require('../middlewares/upload');
const { submitVerificationValidator } = require('../validators/verificationValidator');

const router = express.Router();

router.post(
  '/extract',
  authenticate,
  upload.single('image'),
  verificationController.extractCnic,
);

router.post(
  '/submit',
  authenticate,
  validate(submitVerificationValidator),
  verificationController.submitVerification,
);

router.get('/status', authenticate, verificationController.getStatus);

module.exports = router;
