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
    const rawAnswers = await AnswerModel.find({ questionId: id }).lean();

    // Collect unique userIds from answers and topAnswerId (in case it's not in answers list)
    const answerUserIds = rawAnswers.map(ans => ans.answeredBy);
    const topAnswerUserId = question.topAnswerId
      ? rawAnswers.find(a => a.answerId === question.topAnswerId)?.answeredBy
      : null;

    const userIds = [...new Set([...answerUserIds, topAnswerUserId].filter(Boolean))];

    // Fetch user info
    const users = await UserModel.find(
      { userId: { $in: userIds } },
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

    // Map userId => user info
    const userMap = {};
    users.forEach(user => {
      userMap[user.userId] = {
        id: user.userId,
        displayName: user.displayName,
        country: user.country,
        gender: user.gender,
        email: user.email,
        language: user.language,
        role: user.role,
        savedQuestions: user.savedQuestions,
        savedLessons: user.savedLessons,
        createdAt: user.createdAt
      };
    });

    // Build the answers array with full answeredBy info
    const answers = rawAnswers.map(ans => ({
      answerId: ans.answerId,
      questionId: ans.questionId,
      text: ans.text,
      createdAt: ans.createdAt,
      language: ans.language,
      upvotesCount: ans.upvotesCount,
      answeredBy: userMap[ans.answeredBy] || null
    }));

    // Build the topAnswer if available
    let topAnswer = null;
    if (question.topAnswerId) {
      const top = answers.find(ans => ans.answerId === question.topAnswerId);
      if (top) topAnswer = top;
    }

    // Send final response
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

const message=
result==='saved'
? 'Question added to saved list'
: 'Question removed from saved list';



    res.status(200).json({ success: true, message});

  }
catch(err){
 console.error('Error saving question:', err);
    res.status(500).json({ success: false, message: 'Server error' });
}
};