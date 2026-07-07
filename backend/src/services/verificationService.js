const verificationRepository = require('../repositories/verificationRepository');
const AppError = require('../utils/AppError');
const { VERIFICATION_STATUSES } = require('../models/User');

/**
 * Business logic for voter identity verification submissions.
 */
class VerificationService {
  /**
   * Submits CNIC and face registration data for admin review.
   * @param {string} userId
   * @param {object} input
   * @returns {Promise<object>}
   */
  async submitVerification(userId, input) {
    const user = await verificationRepository.findById(userId);

    if (!user) {
      throw new AppError('User not found', 404);
    }

    if (user.verificationStatus === VERIFICATION_STATUSES.PENDING) {
      throw new AppError('Verification has already been submitted', 409);
    }

    if (user.verificationStatus === VERIFICATION_STATUSES.VERIFIED) {
      throw new AppError('Verification is already complete', 409);
    }

    const { cnicNumber, cnicFrontImageUrl, cnicBackImageUrl } = input;

    if (await verificationRepository.cnicExistsForOtherUser(cnicNumber, userId)) {
      throw new AppError('CNIC is already registered to another account', 409);
    }

    const updatedUser = await verificationRepository.submitVerification(userId, {
      cnicNumber,
      cnicFrontImageUrl,
      cnicBackImageUrl,
      submittedAt: new Date(),
    });

    return this.toStatusResponse(updatedUser);
  }

  /**
   * Returns the authenticated user's verification status.
   * @param {string} userId
   * @returns {Promise<object>}
   */
  async getStatus(userId) {
    const user = await verificationRepository.findById(userId);

    if (!user) {
      throw new AppError('User not found', 404);
    }

    return this.toStatusResponse(user);
  }

  /**
   * @param {import('mongoose').Document} user
   * @returns {object}
   */
  toStatusResponse(user) {
    return {
      verificationStatus: user.verificationStatus,
      approvalStatus: user.approvalStatus,
      faceRegistered: user.faceRegistered,
      cnic: user.cnic ?? null,
      cnicFrontImageUrl: user.cnicFrontImageUrl ?? null,
      cnicBackImageUrl: user.cnicBackImageUrl ?? null,
      verificationSubmittedAt: user.verificationSubmittedAt ?? null,
    };
  }
}

module.exports = new VerificationService();
