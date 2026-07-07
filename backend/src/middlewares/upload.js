const path = require('path');
const fs = require('fs');
const multer = require('multer');
const AppError = require('../utils/AppError');
const { env } = require('../config/env');

const uploadRoot = path.resolve(__dirname, '../../', env.upload.dir);

if (!fs.existsSync(uploadRoot)) {
  fs.mkdirSync(uploadRoot, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, uploadRoot);
  },
  filename: (_req, file, cb) => {
    const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    const extension = path.extname(file.originalname).toLowerCase();
    cb(null, `${file.fieldname}-${uniqueSuffix}${extension}`);
  },
});

const allowedMimeTypes = new Set([
  'image/jpeg',
  'image/png',
  'image/webp',
  'application/pdf',
]);

/**
 * Rejects unsupported file types before they are stored.
 */
function fileFilter(_req, file, cb) {
  if (allowedMimeTypes.has(file.mimetype)) {
    cb(null, true);
    return;
  }

  cb(new AppError('Unsupported file type', 400), false);
}

const maxFileSizeBytes = env.upload.maxFileSizeMb * 1024 * 1024;

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: maxFileSizeBytes,
    files: 5,
  },
});

/**
 * Maps multer errors to operational AppError instances.
 * @param {Error} error
 * @param {import('express').Request} _req
 * @param {import('express').Response} _res
 * @param {import('express').NextFunction} next
 */
function handleMulterError(error, _req, _res, next) {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return next(
        new AppError(
          `File too large. Maximum size is ${env.upload.maxFileSizeMb}MB`,
          400,
        ),
      );
    }

    return next(new AppError(error.message, 400));
  }

  return next(error);
}

module.exports = {
  upload,
  uploadRoot,
  handleMulterError,
};
