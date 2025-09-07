const Joi = require('joi');

const reconciliationSchema = Joi.object({
  queries: Joi.object().pattern(
    Joi.string().pattern(/^q\d+$/),
    Joi.object({
      query: Joi.string().min(1).max(1000).required()
        .description('Entity query string'),
      type: Joi.string().max(100).optional()
        .description('Entity type filter'),
      limit: Joi.number().min(1).max(100).optional()
        .description('Maximum results to return'),
      properties: Joi.array().items(Joi.object({
        id: Joi.string().required(),
        value: Joi.any().optional()
      })).optional()
        .description('Additional properties for matching'),
      context: Joi.object().optional()
        .description('Additional context for matching')
    })
  ).required().min(1).max(50)
    .description('Queries to process')
});

const suggestionSchema = Joi.object({
  prefix: Joi.string().min(1).max(100).required()
    .description('Prefix for suggestions'),
  type: Joi.string().valid('entity', 'type', 'property').optional()
    .description('Type of suggestions'),
  limit: Joi.number().min(1).max(50).optional()
    .description('Maximum suggestions to return'),
  context: Joi.object().optional()
    .description('Additional context for suggestions')
});

const extendSchema = Joi.object({
  ids: Joi.array().items(Joi.string().min(1).max(200)).required().min(1).max(100)
    .description('Entity IDs to extend'),
  properties: Joi.array().items(Joi.object({
    id: Joi.string().required(),
    name: Joi.string().optional(),
    type: Joi.string().optional(),
    description: Joi.string().optional()
  })).required().min(1).max(20)
    .description('Properties to extend with'),
  context: Joi.object().optional()
    .description('Additional context for extension')
});

const previewSchema = Joi.object({
  id: Joi.string().min(1).max(200).required()
    .description('Entity ID for preview'),
  context: Joi.object().optional()
    .description('Additional context for preview')
});

// Advanced validation with custom messages
const advancedValidation = {
  queries: Joi.object().pattern(
    Joi.string(),
    Joi.object({
      query: Joi.string().required().messages({
        'string.empty': 'Query cannot be empty',
        'any.required': 'Query is required'
      }),
      // ... other fields
    })
  )
};

module.exports = {
  reconciliationSchema,
  suggestionSchema,
  extendSchema,
  previewSchema,
  advancedValidation
};