const { validationResult } = require('express-validator');
const AppError = require('../utils/AppError');

/**
 * Runs express-validator chains and forwards formatted errors.
 * @param {import('express-validator').ValidationChain[]} validations
 * @returns {import('express').RequestHandler[]}
 */
function validate(validations) {
  return [
    ...validations,
    (req, res, next) => {
      const result = validationResult(req);

      if (result.isEmpty()) {
        return next();
      }

      const errors = result.array().map((error) => ({
        field: error.path,
        message: error.msg,
        value: error.value,
      }));

      return next(new AppError('Validation failed', 422, errors));
    },
  ];
}

module.exports = validate;
