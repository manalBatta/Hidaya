const mongoose = require('mongoose');

const certificateSchema = new mongoose.Schema({
  title: String,
  institution: String,
  url: String,
  uploadedAt: Date,
});

const volunteerProfileSchema = new mongoose.Schema({
  certificate: certificateSchema,
  languages: [String],
  bio: String,
});

const userSchema = new mongoose.Schema({
  displayName: String,
  gender: { type: String, enum: ['Male', 'Female'] },
  email: { type: String, unique: true },
  password: String,
  country: String,
  city: String,
  role: { type: String, enum: ['user', 'volunteer_pending', 'certified_volunteer', 'admin'], default: 'user' },
  language: String,
  createdAt: { type: Date, default: Date.now },
  volunteerProfile: volunteerProfileSchema,
});

module.exports = mongoose.model('User', userSchema);
