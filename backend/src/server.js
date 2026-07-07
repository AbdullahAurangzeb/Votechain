const app = require('./app');
const { env, validateEnv } = require('./config/env');
const { connectDatabase, disconnectDatabase } = require('./config/database');

/**
 * Boots the VoteChain API server.
 */
async function startServer() {
  validateEnv();
  await connectDatabase();

  const server = app.listen(env.port, () => {
    console.log(
      `[VoteChain] API listening on port ${env.port} (${env.nodeEnv})`,
    );
  });

  const shutdown = async (signal) => {
    console.log(`[VoteChain] Received ${signal}. Shutting down...`);
    server.close(async () => {
      await disconnectDatabase();
      process.exit(0);
    });
  };

  process.on('SIGINT', () => shutdown('SIGINT'));
  process.on('SIGTERM', () => shutdown('SIGTERM'));

  process.on('unhandledRejection', (reason) => {
    console.error('[UnhandledRejection]', reason);
  });

  process.on('uncaughtException', (error) => {
    console.error('[UncaughtException]', error);
    process.exit(1);
  });
}

startServer().catch((error) => {
  console.error('[VoteChain] Failed to start server:', error.message);
  process.exit(1);
});
