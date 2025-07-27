import express from "express";
const router = express.Router();
import {
  register,
  login,
  updateprofile,
  verifyEmail,
  changepassword,
  updateOneSignalId,
  forgotpassword,
  changePassword,
  deleteAccount,
  resetpassword,
  changeresetpassword,
} from "../controller/usercontroller.js";
import authMiddleware from "../services/authMiddleware.js";
import {
  submitquestion,
  getpublicquestions,
  getquestionandanswers,
  getquestionsofaspecificuser,
  savequestion,
  deletequestion,
  updatequestion,
  updateAIAnswer,
} from "../controller/questioncontroller.js";
import {
  submitanswerbyvolunteer,
  voteonanswer,
  getanswersofvolunteer,
  getanswerupvotedbyvolunteer,
  deleteAnswer,
} from "../controller/answercontroller.js";
import { reportquestion } from "../controller/flagcontroller.js";
import { getalllesson } from "../controller/lessoncontroller.js";
import notificationRoutes from "./notificationroutes.js";
import {
  getallstories,
  savestory,
  likestory,
  getstorybyid,
} from "../controller/StoryController.js";
<<<<<<< HEAD
import { getusersgrowth ,getquestioncategories,getgenderdistribution,getdashboardstats,gettodayactivity,gettopcontent} from "../controller/AdminController.js";
=======
>>>>>>> e220066e3fe0067d22590e4e5fe2e047ebafcd11

router.post("/register", register);
router.post("/login", login);
router.put("/profile", authMiddleware, updateprofile);
router.put("/onesignal-id", authMiddleware, updateOneSignalId);
router.put("/change-password", authMiddleware, changePassword);
router.delete("/delete-account", authMiddleware, deleteAccount);
// Use notification routes
router.use("/notifications", notificationRoutes);
router.post("/questions", authMiddleware, submitquestion);
router.get("/public-questions", getpublicquestions);
router.get("/questions/:id", getquestionandanswers);
router.post("/answers", authMiddleware, submitanswerbyvolunteer);
router.put("/answers/vote", authMiddleware, voteonanswer);
//router.post("/flags", authMiddleware, FlagController.flagitem);
router.get("/myquestion", authMiddleware, getquestionsofaspecificuser);
router.get("/my-questions", authMiddleware, getquestionsofaspecificuser);
router.post("/saveQuestion", authMiddleware, savequestion);
router.get("/myAnwers", authMiddleware, getanswersofvolunteer);
router.get("/upvotedAnswer", authMiddleware, getanswerupvotedbyvolunteer);
router.get("/api/lessons", getalllesson);
router.delete("/deletequestions/:id", authMiddleware, deletequestion);
router.put("/updatequestions/:id", authMiddleware, updatequestion);
router.patch("/questions/:id/ai-answer", authMiddleware, updateAIAnswer);

router.post("/reportquestion", authMiddleware, reportquestion);
router.get("/verify/:token", verifyEmail);
router.post("/change-password", authMiddleware, changepassword);
router.post("/forgot-password", forgotpassword);
router.get("/reset-password/:token", resetpassword);
router.post("/reset-password", authMiddleware, changeresetpassword);
router.delete("/answers/delete/:answerId", deleteAnswer);
router.get("/story", getallstories);
//save story
router.post("/story/savestory", authMiddleware, savestory);
//like story
router.post("/story/likestory", authMiddleware, likestory);
//get story by id
router.get("/getstorybyid", authMiddleware, getstorybyid);
//admin routes
//admin/usersgrowth
router.get("/admin/user-growth", getusersgrowth);
router.get("/admin/question-categories", getquestioncategories);
router.get("/admin/gender-distribution", getgenderdistribution);
router.get("/admin/dashboard-stats", getdashboardstats);
router.get("/admin/today-activity", gettodayactivity);
router.get("/admin/top-content",gettopcontent);

export default router;
