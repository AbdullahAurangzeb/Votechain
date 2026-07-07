const authRepository = require('../repositories/authRepository');
const { hashPassword, comparePassword } = require('../utils/password');
const { signAccessToken } = require('../config/jwt');
const AppError = require('../utils/AppError');
const { ROLES } = require('../models/User');

/**
 * Business logic for voter authentication.
 */
class AuthService {
  /**
   * Registers a new voter account.
   * @param {object} input
   * @returns {Promise<object>}
   */
  async register(input) {
    const { fullName, email, phoneNumber, password, cnic } = input;

    if (await authRepository.emailExists(email)) {
      throw new AppError('Email is already registered', 409);
    }

    if (cnic && (await authRepository.cnicExists(cnic))) {
      throw new AppError('CNIC is already registered', 409);
    }

    const passwordHash = await hashPassword(password);

    const user = await authRepository.create({
      fullName,
      email,
      phoneNumber,
      password: passwordHash,
      cnic: cnic || undefined,
      role: ROLES.VOTER,
    });

    return this.toPublicUser(user);
  }

  /**
   * Authenticates a user and returns a JWT access token.
   * @param {object} input
   * @returns {Promise<{ user: object, token: string }>}
   */
  async login(input) {
    const { email, password } = input;

    const user = await authRepository.findByEmailWithPassword(email);

    if (!user) {
      throw new AppError('Invalid email or password', 401);
    }

    const passwordMatches = await comparePassword(password, user.password);

    if (!passwordMatches) {
      throw new AppError('Invalid email or password', 401);
    }

    const token = signAccessToken({
      sub: user._id.toString(),
      email: user.email,
      role: user.role,
    });

    return {
      user: this.toPublicUser(user),
      token,
    };
  }

  /**
   * Returns the authenticated user's profile.
   * @param {string} userId
   * @returns {Promise<object>}
   */
  async getProfile(userId) {
    const user = await authRepository.findById(userId);

    if (!user) {
      throw new AppError('User not found', 404);
    }

    return this.toPublicUser(user);
  }

  /**
   * Strips sensitive fields from a user document.
   * @param {import('mongoose').Document} user
   * @returns {object}
   */
  toPublicUser(user) {
    return user.toJSON();
  }
}

module.exports = new AuthService();
