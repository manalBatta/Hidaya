const UserServices = require("../services/questionsservices");
const QuestionModel = require("../models/Questions");
const AnswerModel = require("../models/Answers");

exports.submitquestion = async (req, res, next) => {
  const userId = req.userId; // coming from token middleware
  try {
    console.log("--- req body ---", req.body);
    const { text, isPublic, category, tags, aiAnswer } = req.body;
    if (!text || !category) {
      return res.status(400).json({
        status: false,
        message: "Text and category are required",
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

    const { newQuestion, user } = await UserServices.SubmitQuestion(
      Newquestion,
      userId
    );

    const questionToReturn = newQuestion.toObject();
    questionToReturn.askedBy = {
      id: userId,
      displayName: user?.displayName || "Anonymous",
    };
    res.status(201).json({
      status: true,
      success: "Question submitted successfully",
      question: questionToReturn,
    });
  } catch (err) {
    console.log("---> err -->", err);
    next(err);
  }
};
exports.getpublicquestions = async (req, res, next) => {
  const allpublicquestions = await UserServices.GetPublicQuestions();
  res.status(200).json({
    status: true,
    success: "Getting public Questions  successfully",
    question: allpublicquestions,
  });
};
exports.getquestionandanswers = async (req, res, next) => {
  const { id } = req.params;
  try {
    // Get the question
    const question = await QuestionModel.findOne({ questionId: id }).lean();
    if (!question) return res.status(404).json({ error: "Question not found" });

    const answers = await AnswerModel.find({ questionId: id }).lean();

    // Get the top answer, if it exists
    let topAnswer = null;
    if (question.topAnswerId) {
      topAnswer = await AnswerModel.findOne({
        answerId: question.topAnswerId,
      }).lean();
    }

    res.json({
      questionId: question.questionId,
      text: question.text,
      answers: answers,
      topAnswer: topAnswer,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Internal server error" });
  }
};
exports.getquestionsofaspecificuser = async (req, res, next) => {
  try {
    const userId = req.userId;
    if (!userId) {
      return res
        .status(401)
        .json({ status: false, error: "Unauthorized. userId not found." });
    }
    console.log("userid is:", userId);

    const QuestionsofUser = await UserServices.GetQuestionOfUser(userId);
    res.status(200).json({
      status: true,
      success: "Getting user questions successfully",
      question: QuestionsofUser,
    });
  } catch (err) {
    console.error("Error fetching user questions:", err);
    next(err);
  }
};
