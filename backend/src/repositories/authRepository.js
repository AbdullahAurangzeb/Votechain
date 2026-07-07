const { User } = require('../models/User');

/**
 * Data access layer for authentication-related user operations.
 */
class AuthRepository {
  /**
   * @param {object} userData
   * @returns {Promise<import('mongoose').Document>}
   */
  async create(userData) {
    return User.create(userData);
  }

  /**
   * @param {string} email
   * @returns {Promise<import('mongoose').Document|null>}
   */
  async findByEmail(email) {
    return User.findOne({ email: email.toLowerCase() });
  }

  /**
   * @param {string} email
   * @returns {Promise<import('mongoose').Document|null>}
   */
  async findByEmailWithPassword(email) {
    return User.findOne({ email: email.toLowerCase() }).select('+password');
  }

  /**
   * @param {string} id
   * @returns {Promise<import('mongoose').Document|null>}
   */
  async findById(id) {
    return User.findById(id);
  }

  /**
   * @param {string} email
   * @returns {Promise<boolean>}
   */
  async emailExists(email) {
    const count = await User.countDocuments({ email: email.toLowerCase() });
    return count > 0;
  }

  /**
   * @param {string} cnic
   * @returns {Promise<boolean>}
   */
  async cnicExists(cnic) {
    if (!cnic) {
      return false;
    }

    const count = await User.countDocuments({ cnic });
    return count > 0;
  }
}

module.exports = new AuthRepository();
