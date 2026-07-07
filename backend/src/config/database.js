const mongoose = require('mongoose');
const { env } = require('./env');

/**
 * Connects to MongoDB Atlas using Mongoose.
 * @returns {Promise<typeof mongoose>}
 */
async function connectDatabase() {
  mongoose.set('strictQuery', true);

  const connection = await mongoose.connect(env.mongodbUri, {
    autoIndex: !env.isProduction,
  });

  return connection;
}

/**
 * Gracefully closes the MongoDB connection.
 */
async function disconnectDatabase() {
  await mongoose.disconnect();
}

module.exports = { connectDatabase, disconnectDatabase };
