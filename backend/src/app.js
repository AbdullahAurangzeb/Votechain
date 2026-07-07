const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { env } = require('./config/env');
const routes = require('./routes');
const notFoundHandler = require('./middlewares/notFoundHandler');
const errorHandler = require('./middlewares/errorHandler');
const { handleMulterError } = require('./middlewares/upload');

const app = express();

const allowedOrigins = env.corsOrigin
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

app.use(helmet());
app.use(
  cors({
    origin(origin, callback) {
      if (!origin || allowedOrigins.includes(origin) || !env.isProduction) {
        callback(null, true);
        return;
      }

      callback(new Error(`CORS blocked for origin: ${origin}`));
    },
    credentials: true,
  }),
);
app.use(
  morgan(env.isProduction ? 'combined' : 'dev', {
    skip: (req) => req.path === '/api/v1/health',
  }),
);
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

app.get('/', (_req, res) => {
  res.json({
    success: true,
    message: 'VoteChain API',
    data: {
      version: '0.1.0',
      docs: '/api/v1/health',
    },
    errors: null,
  });
});

app.use('/api/v1', routes);

app.use(notFoundHandler);
app.use(handleMulterError);
app.use(errorHandler);

module.exports = app;
