
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


  static async GetPublicQuestions() {
  try {
    const publicQuestions = await QuestionModel.find({ isPublic: true }).sort({ createdAt: -1 });
    const userIds = [...new Set(publicQuestions.map(q => q.askedBy))];

    const users = await UserModel.find(
      { userId: { $in: userIds } },
      { userId: 1, displayName: 1 ,country: 1 }
    );

    const userMap = {};
    users.forEach(user => {
      userMap[user.userId] = user;
    });

    const questionsWithAskedByObj = publicQuestions.map(q => {
      const qObj = q.toObject();
      const user = userMap[q.askedBy];
      qObj.askedBy = user ? { id: user.userId,displayName: user.displayName,country: user.country } : null;
      return qObj;
    });

    return questionsWithAskedByObj;
  } catch (err) {
    console.error("Error in GetPublicQuestions:", err);
    throw err;
  }
}


static async GetQuestionOfUser(userid){
  console.log("userid is:",userid);
  try {
    const questions = await QuestionModel.find({ askedBy: userid });
    return questions;
  } catch (err) {
    console.error("Error in GetQuestionOfUser:", err);
    throw err;
  }
}


}

module.exports = QuestionServices;