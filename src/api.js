const express = require('express');
const metadataRouter = require('./routes/metadata');
const reconcileRouter = require('./routes/reconcile');
const suggestEntityRouter = require('./routes/suggest-entity');
// ...other routers
const previewRouter = require('./routes/preview');
const extendProposeRouter = require('./routes/extend-propose');
const extendRouter = require('./routes/extend');
const streamChunkRouter = require('./routes/stream-chunk');

const app = express();
app.use(express.json());

// Enable CORS
app.use((req, res, next) => {
  res.set('Access-Control-Allow-Origin', '*');
  next();
});

// Mount routes
app.use('/metadata', metadataRouter);
app.use('/reconcile', reconcileRouter);
app.use('/suggest/entity', suggestEntityRouter);
app.use('/suggest/type', require('./routes/suggest-type'));
app.use('/suggest/property', require('./routes/suggest-property'));
app.use('/preview', previewRouter);
app.use('/extend/propose', extendProposeRouter);
app.use('/extend', extendRouter);
app.use('/stream-chunk', streamChunkRouter);

// Error middleware
app.use((err, req, res, next) => {
  console.error(err);
  res.status(err.status || 500).json({
    status: err.status || 500,
    error: err.name,
    message: err.message,
    timestamp: new Date().toISOString(),
  });
});

module.exports = app;
