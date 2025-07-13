const AnswerModel = require("../models/Answers");
const VoteModel = require("../models/Votes");
const QuestionModel=require("../models/Questions");
const UserModel = require("../models/User");

const { v4: uuidv4 } = require('uuid');

class AnswerServices {
static async UpVoteOnAnswer(answerId, userId) {
  try {
    const newAnswer = await AnswerModel.findOne({ answerId }).lean();
    if (!newAnswer) return null;

    const questionId = newAnswer.questionId;
     console.log("HELLO !!!!@@@@@@");
    // Find if user already voted on this question
    const existingVote = await VoteModel.findOne({ votedBy: userId, questionId });

    if (existingVote) {
      if (existingVote.answerId === answerId) {
        // 🟥 Case 2: Unvote (same answer clicked again)
        await VoteModel.deleteOne({ voteId: existingVote.voteId });
        await AnswerModel.updateOne({ answerId }, { $inc: { upvotesCount: -1 } });
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
        createdAt: new Date()
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

 static async SubmitAnswer (data){
 console.log("Answer to submit:", data);

    try {
      const newAnswer = new AnswerModel({
        answerId: uuidv4(),
        questionId: data.questionId,
        text: data.text,
        answeredBy: data.answeredBy,
        createdAt: new Date(),
        language:data.language,
        upvotesCount:data.upvotesCount

      });

      await newAnswer.save();
      return {newAnswer};
    } catch (err) {
      throw err;
    }
}

static async GetAnswersOfVolunteer(userId) {
  try {
    if (!userId) {
      throw new Error('Missing userId');
    }

    // Get all answers by this user
    const answers = await AnswerModel.find({ answeredBy: userId }).lean();
    if (!answers.length) return [];

    // Get full user info
    const user = await UserModel.findOne({ userId }).lean();
    if (!user) throw new Error('User not found');

    const fullUser = {
      id: user.userId,
      displayName: user.displayName,
      country: user.country,
      gender: user.gender,
      email: user.email,
      language: user.language,
      role: user.role,
      savedQuestions: user.savedQuestions,
      savedLessons: user.savedLessons,
      createdAt: user.createdAt,
    };

    // Extract unique questionIds
    const questionIds = answers.map(a => a.questionId);
    const questions = await QuestionModel.find({ questionId: { $in: questionIds } }).lean();

    // Create a lookup map for questions
    const questionMap = {};
    for (const q of questions) {
      questionMap[q.questionId] = q;
    }

    // Return enriched answers with full user + question info
    const enrichedAnswers = answers.map(({ questionId, ...answer }) => ({
      ...answer,
      answeredBy: fullUser,
      question: questionMap[questionId] || null,
    }));

    return enrichedAnswers;

  } catch (err) {
    console.error('Error in GetAnswersOfVolunteer:', err);
    throw new Error('Failed to get answers');
  }
}

static async GetTheUpvotedAnswerOfVol(questionId, userId) {
  try {
    const vote = await VoteModel.findOne({ votedBy: userId, questionId }).lean();
    if (!vote) return null;

    return vote.answerId;
  } catch (err) {
    console.error('Error in GetTheUpvotedAnswerOfVol:', err);
    throw new Error('Failed to get upvoted answer');
  }
}








 
  
}

module.exports = AnswerServices;
