
const router = require("express").Router();
const UserController = require('../controller/usercontroller');
const authMiddleware = require('../services/authMiddleware');
const QuestionController=require('../controller/questioncontroller');

router.post("/register",UserController.register);
router.post("/login",UserController.login);
router.put('/profile', authMiddleware, UserController.updateprofile);
router.post("/questions",authMiddleware,QuestionController.submitquestion);
router.get("/public-questions",QuestionController.getpublicquestions);

//router.post("/login", UserController.login);
//public questions

module.exports = router;