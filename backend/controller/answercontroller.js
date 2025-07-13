const AnswerServices = require('../services/answersservices');
const AnswerModel=require('../models/Answers');
exports.voteonanswer = async(req , res , next ) => {
  const { answerId } = req.body;
   const userId = req.userId;
  console.log('Received answerId:', req.body.answerId);

   try{
    const updatedAnswer = await AnswerServices.UpVoteOnAnswer(answerId,userId);
     
    if (!updatedAnswer) {
      return res.status(404).json({ error: 'Answer not found' });
    }

//recalculate the top answer for each question (the answer with maximum number of votes to the same answer make it to the top answer)
const answer = await AnswerModel.findOne({ answerId }).lean();
    if (!answer) {
      return res.status(404).json({ error: 'Answer not found after update' });
    }

    const questionId = answer.questionId;
// Find the top-voted answer for this question
    const topAnswer = await AnswerModel.findOne({ questionId })
      .sort({ upvotesCount: -1 })
      .select('answerId')
      .lean();
       if (topAnswer) {
      // Update the question with the new topAnswerId
      await QuestionModel.updateOne(
        { questionId },
        { $set: { topAnswerId: topAnswer.answerId } }
      );
    }
  res.json({
      message: 'Upvote successful and top answer recalculated',
      updatedAnswer: updatedAnswer.upvotesCount
    });


  res.json({
      message: 'Upvote successful',
      updatedAnswer
    });
   }
   catch(err){
console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
   };




































   
exports.submitanswerbyvolunteer = async(req , res , next ) => {
    try{
    const { questionId, text, language } = req.body;
    const answeredBy = req.userId; //from token
    const upvotesCount=0;
    if (!questionId || !text || !language) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const Newanswer = {
      questionId,
      text,
      answeredBy,
      language,
      upvotesCount,
    };

   const { newAnswer } = await AnswerServices.SubmitAnswer(Newanswer);

    const answerToReturn = newAnswer.toObject();
    
res.status(201).json({
  status: true,
  success: 'answer submitted successfully',
  question: answerToReturn
});}
catch (err) {
    console.log("---> err -->", err);
    next(err);
  }

  } ;













