const router = require("express").Router();
const UserController = require("../controller/usercontroller");
const authMiddleware = require("../services/authMiddleware");
const QuestionController = require("../controller/questioncontroller");
const AnswerController = require("../controller/answercontroller");
const FlagController = require("../controller/flagcontroller");
const LessonController = require("../controller/lessoncontroller");

router.post("/register", UserController.register);
router.post("/login", UserController.login);
router.put("/profile", authMiddleware, UserController.updateprofile);
router.post("/questions", authMiddleware, QuestionController.submitquestion);
router.get("/public-questions", QuestionController.getpublicquestions);
router.get("/questions/:id", QuestionController.getquestionandanswers);
router.post(
  "/answers",
  authMiddleware,
  AnswerController.submitanswerbyvolunteer
);
router.put("/answers/vote", authMiddleware, AnswerController.voteonanswer);
router.post("/flags", authMiddleware, FlagController.flagitem);
router.get(
  "/myquestion",
  authMiddleware,
  QuestionController.getquestionsofaspecificuser
);
router.post("/saveQuestion", authMiddleware, QuestionController.savequestion);
router.get("/myAnwers", authMiddleware, AnswerController.getanswersofvolunteer);
router.get(
  "/upvotedAnswer",
  authMiddleware,
  AnswerController.getanswerupvotedbyvolunteer
);
router.get("/api/lessons", LessonController.getalllesson);
router.delete(
  "/deletequestions/:id",
  authMiddleware,
  QuestionController.deletequestion
);
router.put(
  "/updatequestions/:id",
  authMiddleware,
  QuestionController.updatequestion
);
router.patch(
  "/questions/:id/ai-answer",
  authMiddleware,
  QuestionController.updateAIAnswer
);

module.exports = router;
