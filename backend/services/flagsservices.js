import FlagModel from "../models/Flags.js";
import AnswerModel from "../models/Answers.js";
import QuestionModel from "../models/Questions.js";
import { v4 as uuidv4 } from "uuid";

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

      if (data.itemType.toLowerCase() === "question") {
        await QuestionModel.findOneAndUpdate(
          { questionId: data.itemId },
          { isFlagged: true }
        );
      }

      if (data.itemType.toLowerCase() === "answer") {
        const answer = await AnswerModel.findOneAndUpdate(
          { answerId: data.itemId },
          { isFlagged: true },
          { new: true }
        );

        if (answer && answer.questionId) {
          await this.recalculateTopAnswer(answer.questionId);
        } else {
          console.warn("Answer not found or missing questionId");
        }
      }

      return { newFlag };
    } catch (err) {
      throw err;
    }
  }

  static async recalculateTopAnswer(questionId) {
    console.log("🔍 Recalculating top answer for question:", questionId);
    const answers = await AnswerModel.find({
      questionId: questionId,
      isFlagged: { $ne: true },
    }).sort({ upvotesCount: -1 });
    const question = await QuestionModel.findOne({ questionId: questionId });

    if (answers.length > 0) {
      question.topAnswerId = answers[0].answerId;
    } else {
      question.topAnswerId = null;
    }

    await question.save();
  }
}

export default FlagServices;
/*
     flagId: require('uuid').v4(),
      itemType,
      itemId,
      reportedBy,
      reson,
      status: 'pending',
      createdAt: new Date()





*/
