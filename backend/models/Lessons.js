const mongoose = require('mongoose');
const { Schema } = mongoose;

const lessonSchema = new Schema({
  lessonId: { type: String, required: true, unique: true },
  title: { type: String, required: true },
  category: { type: String, required: true },
  language: { type: String, required: true },
  contentType: { type: String, required: true },
  summary: { type: String, required: true },
  mediaUrl: { type: String, required: true },
  level: { 
    type: String, 
    required: true, 
    enum: ['beginner', 'intermediate', 'advanced'] 
  },
  rate: { type: Number, required: true, default: 0 },       
  rateCount: { type: Number, required: true, default: 0 },  
  views: { type: Number, required: true, default: 0 },      
  createdAt: { type: Date, required: true, default: Date.now }
});

module.exports = mongoose.model('Lesson', lessonSchema, 'Lessons');
