
const mongoose = require('mongoose');
const { Schema } = mongoose;

const questionSchema = new Schema({
  questionId: { type: String, required: true, unique: true }, 
  text: { type: String, required: true }, 
  isPublic: { type: Boolean, default: true }, 
  askedBy: { type: String, required: true }, 
  createdAt: { type: Date, default: Date.now },
  aiAnswer: { type: String }, 
  topAnswerId: { type: String }, 
  tags: [{ type: String }], 
  category: { type: String } 
});

module.exports = mongoose.model('Question', questionSchema,'Questions');
//module.exports = mongoose.model('User', userSchema, 'Users');
