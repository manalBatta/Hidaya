
const QuestionModel = require("../models/Questions");
const UserModel = require("../models/User");

const { v4: uuidv4 } = require('uuid');
class QuestionServices {
  static async SubmitQuestion(data,id) {
    const user = await UserModel.findOne({ userId: id });
    console.log("User ID passed to SubmitQuestion:", user);

    try {
      const newQuestion = new QuestionModel({
        questionId: uuidv4(),
        text: data.text,
        isPublic: data.isPublic ?? true,
        askedBy: id,
        aiAnswer: data.aiAnswer || "", 
        topAnswerId: data.topAnswerId || "", 
        tags: data.tags || [],
        category: data.category || "",
        createdAt: new Date()
      });

      await newQuestion.save();
      console.log("Saved question:", newQuestion);

      return {newQuestion , user };
    } catch (err) {
      throw err;
    }
  }
  static async GetPublicQuestions (){
   const publicQuestions = await QuestionModel.find({ isPublic: true }).sort({ createdAt: -1 });
    return publicQuestions;
  }
  
}

module.exports = QuestionServices;