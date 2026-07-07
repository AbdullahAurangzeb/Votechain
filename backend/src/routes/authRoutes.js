const express = require('express');
const authController = require('../controllers/authController');
const validate = require('../middlewares/validate');
const { authenticate } = require('../middlewares/auth');
const {
  registerValidator,
  loginValidator,
} = require('../validators/authValidator');

const router = express.Router();

router.post(
  '/register',
  validate(registerValidator),
  authController.register,
);

router.post('/login', validate(loginValidator), authController.login);

router.get('/me', authenticate, authController.getMe);

module.exports = router;
