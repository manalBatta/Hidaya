
const mongoose = require('mongoose');
const { Schema } = mongoose;

const flagSchema = new Schema({
  flagId: { type: String, required: true, unique: true },
  itemType: { 
    type: String, 
    required: true, 
    enum: ['question', 'answer', 'message'] 
  },
  itemId: { type: String, required: true },
  reportedBy: { type: String, required: true },
  reason: { type: String, required: true },
  status: { 
    type: String, 
    required: true, 
    enum: ['pending', 'reviewed', 'resolved'], 
    default: 'pending' 
  },
  createdAt: { type: Date, required: true, default: Date.now }
});

module.exports = mongoose.model('Flag', flagSchema, 'Flags');
