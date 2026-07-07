const { body } = require('express-validator');

const CNIC_PATTERN = /^\d{5}-\d{7}-\d{1}$/;

const submitVerificationValidator = [
  body('cnicNumber')
    .trim()
    .notEmpty()
    .withMessage('CNIC number is required')
    .matches(CNIC_PATTERN)
    .withMessage('CNIC must be in the format 35202-1234567-1'),
  body('cnicFrontImageUrl')
    .trim()
    .notEmpty()
    .withMessage('CNIC front image URL is required')
    .isLength({ max: 500 })
    .withMessage('CNIC front image URL is too long'),
  body('cnicBackImageUrl')
    .trim()
    .notEmpty()
    .withMessage('CNIC back image URL is required')
    .isLength({ max: 500 })
    .withMessage('CNIC back image URL is too long'),
];

module.exports = {
  submitVerificationValidator,
};
