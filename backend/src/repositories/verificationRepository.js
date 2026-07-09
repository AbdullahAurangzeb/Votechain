const { User } = require('../models/User');

/**
 * Data access layer for voter identity verification.
 */
class VerificationRepository {
  /**
   * Normalizes CNIC to `XXXXX-XXXXXXX-X` for consistent comparisons.
   * @param {string} cnic
   * @returns {string}
   */
  normalizeCnic(cnic) {
    const digits = String(cnic).replace(/\D/g, '');
    if (digits.length !== 13) {
      return String(cnic).trim();
    }

    return `${digits.slice(0, 5)}-${digits.slice(5, 12)}-${digits.slice(12)}`;
  }

  /**
   * @param {string} userId
   * @returns {Promise<import('mongoose').Document|null>}
   */
  async findById(userId) {
    return User.findById(userId);
  }

  /**
   * Persists a completed verification submission for a voter.
   * @param {string} userId
   * @param {object} submission
   * @returns {Promise<import('mongoose').Document|null>}
   */
  async submitVerification(userId, submission) {
    return User.findByIdAndUpdate(
      userId,
      {
        cnic: submission.cnicNumber,
        cnicFrontImageUrl: submission.cnicFrontImageUrl,
        cnicBackImageUrl: submission.cnicBackImageUrl,
        verificationStatus: 'pending',
        faceRegistered: true,
        verificationSubmittedAt: submission.submittedAt,
      },
      { new: true, runValidators: true },
    );
  }

  /**
   * Returns true when another account already owns [cnic].
   * @param {string} cnic
   * @param {string} excludeUserId
   * @returns {Promise<boolean>}
   */
  async cnicExistsForOtherUser(cnic, excludeUserId) {
    const normalized = this.normalizeCnic(cnic);
    const users = await User.find({
      cnic: { $exists: true, $ne: null },
    }).select('cnic _id');

    return users.some((user) => {
      if (user._id.toString() === String(excludeUserId)) {
        return false;
      }

      return this.normalizeCnic(user.cnic) === normalized;
    });
  }
}

module.exports = new VerificationRepository();
