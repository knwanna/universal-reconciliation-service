const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Correctly import routes from the src directory
const reconcileRouter = require('../../src/routes/reconcile');
const metadataRouter = require('../../src/routes/metadata');
const previewRouter = require('../../src/routes/preview');
const suggestRouter = require('../../src/routes/suggest-entity');
const suggestPropertyRouter = require('../../src/routes/suggest-property');
const suggestTypeRouter = require('../../src/routes/suggest-type');
const extendRouter = require('../../src/routes/extend');
const extendProposeRouter = require('../../src/routes/extend-propose');
const streamChunkRouter = require('../../src/routes/stream-chunk');

// Register the route handlers.
app.use('/', metadataRouter);
app.use('/reconcile', reconcileRouter);
app.use('/preview', previewRouter);
app.use('/suggest/entity', suggestRouter);
app.use('/suggest/property', suggestPropertyRouter);
app.use('/suggest/type', suggestTypeRouter);
app.use('/extend', extendRouter);
app.use('/extend/propose', extendProposeRouter);
app.use('/stream-chunk', streamChunkRouter);

// Basic error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

module.exports = app;
