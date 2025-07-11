const AnswerServices = require('../services/answersservices');

exports.voteonanswer = async(req , res , next ) => {
  const { answerId } = req.body;
   const userId = req.userId;
  console.log('Received answerId:', req.body.answerId);

   try{
    const updatedAnswer = await AnswerServices.UpVoteOnAnswer(answerId,userId);
     
    if (!updatedAnswer) {
      return res.status(404).json({ error: 'Answer not found' });
    }
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













