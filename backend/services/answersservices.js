const AnswerModel = require("../models/Answers");
const VoteModel = require("../models/Votes");
const QuestionModel = require("../models/Questions");
const UserModel = require("../models/User");

const { v4: uuidv4 } = require("uuid");

class AnswerServices {
  static async UpVoteOnAnswer(answerId, userId) {
    try {
      const newAnswer = await AnswerModel.findOne({ answerId }).lean();
      if (!newAnswer) return null;

      const questionId = newAnswer.questionId;
      // Find if user already voted on this question
      const existingVote = await VoteModel.findOne({
        votedBy: userId,
        questionId,
      });

      if (existingVote) {
        if (existingVote.answerId === answerId) {
          // 🟥 Case 2: Unvote (same answer clicked again)
          await VoteModel.deleteOne({ voteId: existingVote.voteId });
          await AnswerModel.updateOne(
            { answerId },
            { $inc: { upvotesCount: -1 } }
          );
          console.log("HELLO !!!!@@@@@@");
        } else {
          // 🟧 Case 3: Change vote to different answer
          await VoteModel.updateOne(
            { voteId: existingVote.voteId },
            { $set: { answerId, updatedAt: new Date() } }
          );

          await AnswerModel.updateOne(
            { answerId: existingVote.answerId },
            { $inc: { upvotesCount: -1 } }
          );

          await AnswerModel.updateOne(
            { answerId },
            { $inc: { upvotesCount: 1 } }
          );
        }
      } else {
        // 🟩 Case 1: First time vote
        await VoteModel.create({
          voteId: uuidv4(),
          answerId,
          questionId,
          votedBy: userId,
          createdAt: new Date(),
        });

        await AnswerModel.updateOne(
          { answerId },
          { $inc: { upvotesCount: 1 } }
        );
      }

      // 🔄 Always recalculate top answer
      const top = await AnswerModel.find({ questionId })
        .sort({ upvotesCount: -1, createdAt: 1 })
        .limit(1)
        .lean();

      if (top.length > 0) {
        await QuestionModel.updateOne(
          { questionId },
          { $set: { topAnswerId: top[0].answerId } }
        );
      }

      // Return updated state of the answer that was clicked
      return await AnswerModel.findOne({ answerId }).lean();
    } catch (err) {
      throw err;
    }
  }

  static async SubmitAnswer(data) {
    console.log("Answer to submit:", data);

    try {
      const newAnswer = new AnswerModel({
        answerId: uuidv4(),
        questionId: data.questionId,
        text: data.text,
        answeredBy: data.answeredBy,
        createdAt: new Date(),
        language: data.language,
        upvotesCount: data.upvotesCount,
      });

      await newAnswer.save();
      //edited by manal
      // Set as top answer if this is the first answer for the question
      const answerCount = await AnswerModel.countDocuments({
        questionId: data.questionId,
      });
      if (answerCount === 1) {
        await QuestionModel.updateOne(
          { questionId: data.questionId },
          { $set: { topAnswerId: newAnswer.answerId } }
        );
      }
      return { newAnswer };
    } catch (err) {
      throw err;
    }
  }

  static async GetAnswersOfVolunteer(userId) {
    try {
      if (!userId) {
        throw new Error("Missing userId");
      }

      // Get all answers by this user
      const answers = await AnswerModel.find({ answeredBy: userId }).lean();
      if (!answers.length) return [];

      // Get full user info
      const user = await UserModel.findOne({ userId }).lean();
      if (!user) throw new Error("User not found");

      // Extract unique questionIds
      const questionIds = answers.map((a) => a.questionId);
      const questions = await QuestionModel.find({
        questionId: { $in: questionIds },
      }).lean();

      // Create a lookup map for questions
      const questionMap = {};
      for (const q of questions) {
        questionMap[q.questionId] = q;
      }

      // Fetch all askedBy userIds from questions
      const askedByUserIds = questions.map((q) => q.askedBy).filter(Boolean);
      const askedByUsers = await UserModel.find({
        userId: { $in: askedByUserIds },
      }).lean();
      const askedByUserMap = {};
      for (const u of askedByUsers) {
        askedByUserMap[u.userId] = u;
      }

      // Fetch top answers for each question
      const topAnswerIds = questions.map((q) => q.topAnswerId).filter(Boolean);
      const topAnswers = await AnswerModel.find({
        answerId: { $in: topAnswerIds },
      }).lean();
      const topAnswerMap = {};
      const topAnswerUserIds = topAnswers
        .map((a) => a.answeredBy)
        .filter(Boolean);
      const topAnswerUsers = await UserModel.find({
        userId: { $in: topAnswerUserIds },
      }).lean();
      const userMap = {};
      for (const u of topAnswerUsers) {
        userMap[u.userId] = u;
      }
      for (const a of topAnswers) {
        topAnswerMap[a.answerId] = {
          ...a,
          answeredBy: userMap[a.answeredBy] || null,
        };
      }

      // Return enriched answers with full question info + top answer (with full user) + askedBy full info
      const enrichedAnswers = answers.map(({ questionId, ...answer }) => {
        const question = questionMap[questionId] || null;
        let askedByFull = null;
        if (question && question.askedBy) {
          askedByFull = askedByUserMap[question.askedBy] || null;
        }
        return {
          ...answer,
          question,
          topAnswer: question?.topAnswerId
            ? topAnswerMap[question.topAnswerId] || null
            : null,
          askedBy: askedByFull,
        };
      });

      return enrichedAnswers;
    } catch (err) {
      console.error("Error in GetAnswersOfVolunteer:", err);
      throw new Error("Failed to get answers");
    }
  }

  static async GetTheUpvotedAnswerOfVol(questionId, userId) {
    try {
      const vote = await VoteModel.findOne({
        votedBy: userId,
        questionId,
      }).lean();
      if (!vote) return null;

      return vote.answerId;
    } catch (err) {
      console.error("Error in GetTheUpvotedAnswerOfVol:", err);
      throw new Error("Failed to get upvoted answer");
    }
  }

  static async DeleteAnswer(answerId) {
    try {
      // Find the answer to get its questionId
      const answer = await AnswerModel.findOne({ answerId }).lean();
      if (!answer) throw new Error("Answer not found");
      const questionId = answer.questionId;

      // Find the question
      const question = await QuestionModel.findOne({ questionId }).lean();
      if (!question) throw new Error("Question not found");

      // Delete the answer
      const deleted = await AnswerModel.deleteOne({ answerId });

      // If the deleted answer was the top answer, update the question's topAnswerId
      if (question.topAnswerId === answerId) {
        // Find the next top answer (highest upvotes, earliest createdAt)
        const nextTop = await AnswerModel.find({ questionId })
          .sort({ upvotesCount: -1, createdAt: 1 })
          .limit(1)
          .lean();
        if (nextTop.length > 0) {
          await QuestionModel.updateOne(
            { questionId },
            { $set: { topAnswerId: nextTop[0].answerId } }
          );
        } else {
          // No more answers, unset topAnswerId
          await QuestionModel.updateOne(
            { questionId },
            { $set: { topAnswerId: "" } }
          );
        }
      }
      return deleted;
    } catch (err) {
      throw err;
    }
  }
}

module.exports = AnswerServices;
