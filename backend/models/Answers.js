
const mongoose = require('mongoose');
const { Schema } = mongoose;

const answerSchema = new Schema({
  answerId: { type: String, required: true, unique: true },
  questionId: { type: String, required: true },
  text: { type: String, required: true },
  answeredBy: { type: String, required: true },
  createdAt: { type: Date, required: true },
  language: { type: String, required: true },
  upvotesCount: { type: Number, default: 0 },
  isFlagged: { type: Boolean, default: false }
});

module.exports = mongoose.model('Answer', answerSchema, 'Answers');
