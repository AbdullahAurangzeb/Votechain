const mongoose = require('mongoose');

const ROLES = Object.freeze({
  VOTER: 'voter',
  ADMIN: 'admin',
  SUPER_ADMIN: 'super_admin',
});

const APPROVAL_STATUSES = Object.freeze({
  PENDING: 'pending',
  APPROVED: 'approved',
  REJECTED: 'rejected',
});

const VERIFICATION_STATUSES = Object.freeze({
  NOT_STARTED: 'not_started',
  PENDING: 'pending',
  VERIFIED: 'verified',
});

const userSchema = new mongoose.Schema(
  {
    fullName: {
      type: String,
      required: [true, 'Full name is required'],
      trim: true,
      maxlength: 120,
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      trim: true,
      maxlength: 255,
    },
    password: {
      type: String,
      required: [true, 'Password is required'],
      minlength: 8,
      select: false,
    },
    phoneNumber: {
      type: String,
      required: [true, 'Phone number is required'],
      trim: true,
      maxlength: 20,
    },
    cnic: {
      type: String,
      trim: true,
      unique: true,
      sparse: true,
      maxlength: 15,
    },
    role: {
      type: String,
      enum: Object.values(ROLES),
      default: ROLES.VOTER,
    },
    approvalStatus: {
      type: String,
      enum: Object.values(APPROVAL_STATUSES),
      default: APPROVAL_STATUSES.PENDING,
    },
    verificationStatus: {
      type: String,
      enum: Object.values(VERIFICATION_STATUSES),
      default: VERIFICATION_STATUSES.NOT_STARTED,
    },
    faceRegistered: {
      type: Boolean,
      default: false,
    },
    cnicFrontImageUrl: {
      type: String,
      trim: true,
      maxlength: 500,
    },
    cnicBackImageUrl: {
      type: String,
      trim: true,
      maxlength: 500,
    },
    verificationSubmittedAt: {
      type: Date,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform(_doc, ret) {
        delete ret.password;
        delete ret.__v;
        return ret;
      },
    },
  },
);

const User = mongoose.model('User', userSchema);

module.exports = {
  User,
  ROLES,
  APPROVAL_STATUSES,
  VERIFICATION_STATUSES,
};
