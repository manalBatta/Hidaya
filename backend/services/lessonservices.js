import LessonModel from "../models/Lessons.js";
import UserModel from "../models/User.js";
import mongoose from "mongoose";

class LessonServices {
  static async GetAllLessons() {
    try {
      console.log("Fetching all lessons from the database");
      const lessons = await LessonModel.find({})
      .select("_id lessonId title description category level icon estimatedTime createdAt")
      .lean();
      if (!lessons || lessons.length === 0) {
        console.log("No lessons found");
      }
      return lessons;
    } catch (err) {
      console.error("Error in GetAllLessons:", err);
      throw err;
    }
  }

  static async GetLessonById(lessonId) {
    console.log("Fetching lesson by ID:", lessonId);
    try {
      const lesson = await LessonModel.findOne({ lessonId: lessonId });
      return lesson;
    } catch (err) {
      console.error("Error in GetLessonById:", err);
      throw err;
    }
  }

  static async UpdateLessonProgressInUser(userId, lessonId, currentStep) {
    console.log(`Updating lesson progress for user ${userId}, lesson ${lessonId}, step ${currentStep}`);
    try {
      const lesson = await LessonModel.findOne({ lessonId: lessonId });
      if (!lesson) {
        console.log("Lesson not found");
        return null;
      }
      //Get the number of steps for this lesson
          const totalSteps = lesson.steps.length;
      // Validate currentStep against totalSteps
          const isCompleted = currentStep >= totalSteps;
      //find the user to update the progress
      const user = await UserModel.findOne({ userId: userId });
      if (!user) {
        console.log("User not found");
        return null;
      }
      // Update user's lesson progress
          const lessonProgress = user.lessonsProgress.find(lp => lp.lessonId.toString() === lessonId);
       if (!lessonProgress) {
      user.lessonsProgress.push({
        lessonId: lessonId,
        currentStep: currentStep,
        completed: isCompleted
      });
    } else {
      lessonProgress.currentStep = currentStep;
      lessonProgress.completed = isCompleted;
    }
        await user.save();
      console.log("Lesson progress updated successfully");
       return {
        userId: userId,
      lessonId: lessonId,
      currentStep: currentStep,
      completed: isCompleted
    };

    } catch (err) {
      console.error("Error in UpdateLessonProgressInUser:", err);
      throw err;
    }
  }

}




export default LessonServices;
