import mongoose, { model } from "mongoose";
const { Schema } = mongoose;

const stepSchema = new Schema({
  stepNumber: { type: Number, required: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  mediaUrl: { type: String, required: true },
});

const lessonSchema = new Schema({
  lessonId: { type: String, required: true, unique: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  category: { type: String, required: true },
  level: {
    type: String,
    required: true,
    enum: ["beginner", "intermediate", "advanced"],
  },
  icon: { type: String, required: true },
  estimatedTime: { type: Number, required: true },
  createdAt: { type: Date, required: true, default: Date.now },
  steps: { type: [stepSchema], required: true },
});

export default model("Lesson", lessonSchema, "Lessons");
