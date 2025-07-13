const AnswerServices = require('../services/answersservices');
const AnswerModel=require('../models/Answers');
const QuestionModel=require('../models/Questions');
const UserModel=require('../models/User');

exports.voteonanswer = async (req, res, next) => {
  const { answerId } = req.body;
  const userId = req.userId;

  try {
    // Perform vote logic (handle switching/removing/voting inside service)
    const updatedAnswer = await AnswerServices.UpVoteOnAnswer(answerId, userId);
    if (!updatedAnswer) {
      return res.status(404).json({ error: 'Answer not found' });
    }

    // Get full question data
    const question = await QuestionModel.findOne({ questionId: updatedAnswer.questionId }).lean();
    if (!question) {
      return res.status(404).json({ error: 'Question not found' });
    }

    // Attach full user info to the updated answer
    const answerUser = await UserModel.findOne(
      { userId: updatedAnswer.answeredBy },
      {
        userId: 1,
        displayName: 1,
        country: 1,
        gender: 1,
        email: 1,
        language: 1,
        role: 1,
        savedQuestions: 1,
        savedLessons: 1,
        createdAt: 1
      }
    ).lean();

    const fullUpdatedAnswer = {
      ...updatedAnswer,
      answeredBy: answerUser ? {
        id: answerUser.userId,
        displayName: answerUser.displayName,
        country: answerUser.country,
        gender: answerUser.gender,
        email: answerUser.email,
        language: answerUser.language,
        role: answerUser.role,
        savedQuestions: answerUser.savedQuestions,
        savedLessons: answerUser.savedLessons,
        createdAt: answerUser.createdAt
      } : null
    };

    // Get top answer if one exists
    let topAnswer = null;
    if (question.topAnswerId) {
      const rawTopAnswer = await AnswerModel.findOne({ answerId: question.topAnswerId }).lean();
      if (rawTopAnswer) {
        const topUser = await UserModel.findOne({ userId: rawTopAnswer.answeredBy }).lean();
        topAnswer = {
          ...rawTopAnswer,
          answeredBy: topUser ? {
            id: topUser.userId,
            displayName: topUser.displayName,
            country: topUser.country,
            gender: topUser.gender,
            email: topUser.email,
            language: topUser.language,
            role: topUser.role,
            savedQuestions: topUser.savedQuestions,
            savedLessons: topUser.savedLessons,
            createdAt: topUser.createdAt
          } : null
        };
      }
    }

    res.json({
      message: 'Upvote successful',
      updatedAnswer: fullUpdatedAnswer,
      question,
      topAnswer
    });

  } catch (err) {
    console.error('voteonanswer error:', err);
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

exports.getanswersofvolunteer = async(req , res , next ) => {
  try{
const userId = req.userId;
if (!userId) {
  return res.status(401).json({ status: false, error: "Unauthorized. userId not found." });
}
  console.log("userid is:",userId);

const AnswersofVolunteer=await AnswerServices.GetAnswersOfVolunteer(userId);
 res.status(200).json({
      status: true,
      success: "Getting user answers successfully",
      answers: AnswersofVolunteer
    });}
    catch(err){
      console.error("Error fetching user answers:", err);
    next(err); 
  }
};

exports.getanswerupvotedbyvolunteer = async(req , res , next) => {
  try{
const {questionId}=req.body ;
const userId=req.userId;
if (!questionId || !userId) {
      return res.status(400).json({ success: false, message: 'questionId and userId are required' });
    }
    console.log("a",questionId);
        console.log("b",userId);

    const result=await AnswerServices.GetTheUpvotedAnswerOfVol(questionId,userId);
  return res.status(200).json({
      success: true,
      message: result ? 'Upvoted answer found' : 'No upvoted answer found',
      answerId: result || null
    });


  }
    
    catch(err){
          console.error('Error in getUpvotedAnswer:', err);
                return res.status(500).json({ success: false, message: 'Internal server error' });


    }
};









