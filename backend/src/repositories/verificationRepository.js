const { User } = require('../models/User');

/**
 * Data access layer for voter identity verification.
 */
class VerificationRepository {
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
   * @param {string} cnic
   * @param {string} excludeUserId
   * @returns {Promise<boolean>}
   */
  async cnicExistsForOtherUser(cnic, excludeUserId) {
    const count = await User.countDocuments({
      cnic,
      _id: { $ne: excludeUserId },
    });

    return count > 0;
  }
}

module.exports = new VerificationRepository();
