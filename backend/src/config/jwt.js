const jwt = require('jsonwebtoken');
const { env } = require('./env');

const jwtConfig = {
  secret: env.jwt.secret,
  expiresIn: env.jwt.expiresIn,
  refreshSecret: env.jwt.refreshSecret,
  refreshExpiresIn: env.jwt.refreshExpiresIn,
};

/**
 * Signs an access token payload. Used by auth services in later phases.
 * @param {object} payload
 * @returns {string}
 */
function signAccessToken(payload) {
  if (!jwtConfig.secret) {
    throw new Error('JWT_SECRET is not configured');
  }

  return jwt.sign(payload, jwtConfig.secret, {
    expiresIn: jwtConfig.expiresIn,
  });
}

/**
 * Signs a refresh token payload. Used by auth services in later phases.
 * @param {object} payload
 * @returns {string}
 */
function signRefreshToken(payload) {
  if (!jwtConfig.refreshSecret) {
    throw new Error('JWT_REFRESH_SECRET is not configured');
  }

  return jwt.sign(payload, jwtConfig.refreshSecret, {
    expiresIn: jwtConfig.refreshExpiresIn,
  });
}

/**
 * Verifies an access token.
 * @param {string} token
 * @returns {object}
 */
function verifyAccessToken(token) {
  return jwt.verify(token, jwtConfig.secret);
}

module.exports = {
  jwtConfig,
  signAccessToken,
  signRefreshToken,
  verifyAccessToken,
};
