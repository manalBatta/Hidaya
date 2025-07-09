
const router = require("express").Router();
const UserController = require('../controller/usercontroller');
const authMiddleware = require('../services/authMiddleware');
router.post("/register",UserController.register);
router.post("/login",UserController.login);
router.put('/profile', authMiddleware, UserController.updateprofile);

//router.post("/login", UserController.login);


module.exports = router;