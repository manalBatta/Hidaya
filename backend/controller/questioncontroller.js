const UserServices = require('../services/questionsservices');
const QuestionModel = require("../models/Questions");
const AnswerModel = require("../models/Answers");
const UserModel=require("../models/User");


exports.submitquestion = async (req, res, next) => {
  const userId = req.userId; // coming from token middleware

  try {
    console.log("--- req body ---", req.body);
    const {
   text, isPublic, category , tags,aiAnswer
    } = req.body;
if (!text || !category) {
      return res.status(400).json({
        status: false,
        message: "Text and category are required"
      });
    }
    const Newquestion = {
      text,
      isPublic,
      category,
      tags,
      aiAnswer,
      askedBy: req.userId || "anonymous",
    };

   const {newQuestion , user} =await UserServices.SubmitQuestion(Newquestion,userId);

const questionToReturn = newQuestion.toObject();
questionToReturn.askedBy={  
      id: userId,
      displayName: user?.displayName || "Anonymous"

    };
res.status(201).json({
  status: true,
  success: 'Question submitted successfully',
  question: questionToReturn
});
  } catch (err) {
    console.log("---> err -->", err);
    next(err);
  }
};
exports.getpublicquestions = async (req , res , next) => {
const allpublicquestions=await UserServices.GetPublicQuestions();
res.status(200).json({
  status: true,
  success: 'Getting public Questions  successfully',
  question: allpublicquestions
});

};
exports.getquestionandanswers = async (req, res, next) => {
  const { id } = req.params;

  try {
    // Get the question
    const question = await QuestionModel.findOne({ questionId: id }).lean();
    if (!question) return res.status(404).json({ error: 'Question not found' });

    // Get all answers to the question
    const answers = await AnswerModel.find({ questionId: id }).lean();

    // Prepare topAnswer if it exists
    let topAnswer = null;
    if (question.topAnswerId) {
      const rawTopAnswer = await AnswerModel.findOne({ answerId: question.topAnswerId }).lean();

      if (rawTopAnswer) {
        const topAnswerUser = await UserModel.findOne(
          { userId: rawTopAnswer.answeredBy },
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

        topAnswer = {
          answerId: rawTopAnswer.answerId,
          questionId: rawTopAnswer.questionId,
          text: rawTopAnswer.text,
          createdAt: rawTopAnswer.createdAt,
          language: rawTopAnswer.language,
          upvotesCount: rawTopAnswer.upvotesCount,
          answeredBy: topAnswerUser
            ? {
                id: topAnswerUser.userId,
                displayName: topAnswerUser.displayName,
                country: topAnswerUser.country,
                gender: topAnswerUser.gender,
                email: topAnswerUser.email,
                language: topAnswerUser.language,
                role: topAnswerUser.role,
                savedQuestions: topAnswerUser.savedQuestions,
                savedLessons: topAnswerUser.savedLessons,
                createdAt: topAnswerUser.createdAt
              }
            : null
        };
      }
    }

    res.json({
      questionId: question.questionId,
      text: question.text,
      answers,
      topAnswer
    });

  } catch (err) {
    console.error("Error in getquestionandanswers:", err);
    res.status(500).json({ error: 'Internal server error' });
  }
};


exports.getquestionsofaspecificuser = async (req , res , next) => {
  try{
const userId = req.userId;
if (!userId) {
  return res.status(401).json({ status: false, error: "Unauthorized. userId not found." });
}
  console.log("userid is:",userId);

const QuestionsofUser=await UserServices.GetQuestionOfUser(userId);
 res.status(200).json({
      status: true,
      success: "Getting user questions successfully",
      question: QuestionsofUser
    });}
    catch(err){
      console.error("Error fetching user questions:", err);
    next(err); 
  }
    };

exports.savequestion = async (req , res , next) => {
  const userId = req.userId; 
  const { questionId } = req.body;
  if (!questionId) {
    return res.status(400).json({ success: false, message: 'questionId is required' });
  }
  try{
    const result= await UserServices.SaveQuestion(userId,questionId);
 if (!result) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    res.status(200).json({ success: true, message: 'Question saved successfully' });

  }
catch(err){
 console.error('Error saving question:', err);
    res.status(500).json({ success: false, message: 'Server error' });
}
};