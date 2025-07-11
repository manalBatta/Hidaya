const AnswerModel = require("../models/Answers");
const VoteModel = require("../models/Votes");

const { v4: uuidv4 } = require('uuid');

class AnswerServices {
  static async UpVoteOnAnswer(answerId,userId) {

    try {
     const updatedAnswer = await AnswerModel.findOneAndUpdate(
      { answerId: answerId },
      { $inc: { upvotesCount: 1 } },
      { new: true } 
    ).lean();

//Add the new vote to votes table
const newvote={
      voteId:uuidv4(), 
        answerId: answerId,
        votedBy: userId,
        createdAt: new Date()
};
      await VoteModel.create(newvote);

      return updatedAnswer.upvotesCount;
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







 
  
}

module.exports = AnswerServices;
