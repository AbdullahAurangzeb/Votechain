const path = require('path');
const dotenv = require('dotenv');

const envPath = path.resolve(__dirname, '../../.env');

dotenv.config({
  path: envPath,
  // Prefer project .env over stale shell variables during local development.
  override: process.env.NODE_ENV !== 'production',
});

/**
 * Validated environment configuration for the VoteChain API.
 */
const env = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: Number(process.env.PORT) || 5000,
  isProduction: process.env.NODE_ENV === 'production',
  mongodbUri: process.env.MONGODB_URI || '',
  jwt: {
    secret: process.env.JWT_SECRET || '',
    expiresIn: process.env.JWT_EXPIRES_IN || '15m',
    refreshSecret: process.env.JWT_REFRESH_SECRET || '',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  },
  bcryptSaltRounds: Number(process.env.BCRYPT_SALT_ROUNDS) || 12,
  corsOrigin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  upload: {
    dir: process.env.UPLOAD_DIR || 'uploads',
    maxFileSizeMb: Number(process.env.UPLOAD_MAX_FILE_SIZE_MB) || 5,
  },
  aiService: {
    baseUrl: process.env.AI_SERVICE_URL || 'http://localhost:8000',
  },
};

/**
 * Ensures required variables are present before the server starts.
 */
function validateEnv() {
  const required = ['MONGODB_URI', 'JWT_SECRET'];

  if (env.isProduction) {
    required.push('JWT_REFRESH_SECRET');
  }

  const missing = required.filter((key) => !process.env[key]);

  if (missing.length > 0) {
    throw new Error(
      `Missing required environment variables: ${missing.join(', ')}`,
    );
  }
}

module.exports = { env, validateEnv };
