const mongoose = require("../config/db");
const bcrypt = require("bcrypt");

const { Schema } = mongoose;

const certificateSchema = new Schema({
  title: String,
  institution: String,
  url: String,
  uploadedAt: Date,
});

const volunteerProfileSchema = new Schema({
  certificate: certificateSchema,
  languages: [String],
  bio: String,
});

const userSchema = new Schema({
  userId: { type: String, required: true },
  displayName: String,
  gender: { type: String, enum: ["Male", "Female"] },
  email: { type: String, unique: true },
  password: String,
  country: String,
  role: {
    type: String,
    enum: ["user", "volunteer_pending", "certified_volunteer", "admin"],
    default: "user",
  },
  language: String,
  savedQuestions: [String],
  savedLessons: [String],
  
  //edited by manal
  // Add ai_session_id for AI chat sessions
  ai_session_id: { type: String },

  createdAt: { type: Date, default: Date.now },
  volunteerProfile: volunteerProfileSchema,
});

userSchema.pre("save", async function () {
  var user = this;
  if (!user.isModified("password")) {
    return;
  }
  try {
    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash(user.password, salt);
    user.password = hash;
  } catch (err) {
    throw err;
  }
});

userSchema.methods.comparePassword = async function (candidatePassword) {
  try {
    console.log("----------------no password", this.password);
    // @ts-ignore
    const isMatch = await bcrypt.compare(candidatePassword, this.password);
    return isMatch;
  } catch (error) {
    throw error;
  }
};

module.exports = mongoose.model("User", userSchema, "Users");
