const bcrypt = require('bcrypt');
const { env } = require('../config/env');

/**
 * Hashes a plain-text password for storage.
 * @param {string} plainPassword
 * @returns {Promise<string>}
 */
async function hashPassword(plainPassword) {
  return bcrypt.hash(plainPassword, env.bcryptSaltRounds);
}

/**
 * Compares a plain-text password with a stored hash.
 * @param {string} plainPassword
 * @param {string} passwordHash
 * @returns {Promise<boolean>}
 */
async function comparePassword(plainPassword, passwordHash) {
  return bcrypt.compare(plainPassword, passwordHash);
}

module.exports = { hashPassword, comparePassword };
