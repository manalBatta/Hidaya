const FlagModel = require("../models/Flags");
const QuestionModel = require("../models/Questions");
const AnswerModel = require("../models/Answers");
const { v4: uuidv4 } = require("uuid");
const notificationService = require("./notificationService");
class FlagServices {
  static async SubmitFlag(data) {
    try {
      const newFlag = new FlagModel({
        flagId: data.flagId,
        itemType: data.itemType,
        itemId: data.itemId,
        reportedBy: data.reportedBy,
        reason: data.description,
        status: "pending",
        createdAt: new Date(),
      });

      await newFlag.save();
      await QuestionModel.findOneAndUpdate(
        { questionId: data.itemId },
        { isFlagged: true }
      );
      await AnswerModel.findOneAndUpdate(
        { answerId: data.itemId },
        { isFlagged: true }
      );

      // Send notification to question owner if a question is flagged
      if (data.itemType === "question") {
        const question = await QuestionModel.findOne({
          questionId: data.itemId,
        });
        if (question && question.askedBy) {
          await notificationService.sendNotification({
            userId: question.askedBy,
            type: "question_flagged",
            title: "Your question was reported",
            message:
              "Your question has been reported and is under review by our team.",
            data: { questionId: data.itemId },
            saveToDatabase: true,
          });
        }
      }

      return { newFlag };
    } catch (err) {
      throw err;
    }
  }
}

module.exports = FlagServices;
/*
     flagId: require('uuid').v4(),
      itemType,
      itemId,
      reportedBy,
      reson,
      status: 'pending',
      createdAt: new Date()





*/
