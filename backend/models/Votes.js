
const mongoose = require('mongoose');
const { Schema } = mongoose;

const voteSchema = new Schema({
  voteId: { type: String, required: true, unique: true },
  answerId: { type: String, required: true },
  votedBy: { type: String, required: true },
  createdAt: { type: Date, required: true, default: Date.now }
});

module.exports = mongoose.model('Vote', voteSchema, 'Votes');
