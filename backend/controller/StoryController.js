//const StoryModel = require("../models/Stories");
const StoryServices = require("../services/storyservices");

exports.getallstories = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;

    const result = await StoryServices.GetAllStories(page, limit);

    if (!result.status) {
      return res.status(500).json({ status: false, message: result.message });
    }

    res.status(200).json(result);
  } catch (err) {
    console.log("---> err in getallstories -->", err);
    next(err);
  }
};

exports.savestory = async (req, res, next) => {
  console.log("---> req.body in savestory -->", req.body);
  const storyId = req.body.id;
  const userId = req.userId; //from token
  console.log("---> userId in savestory -->", userId);
  console.log("---> storyId in savestory -->", storyId);
  //userId of the user who see the story and save it in the array of savesstory in user table(userId from the token)
  try {
    const result = await StoryServices.SaveStory(userId, storyId);
    res.status(200).json(result);
  } catch (err) {
    console.log("---> err in savestory -->", err);
    next(err);
  }
};

//like story
exports.likestory = async (req, res, next) => {
  const storyId = req.body.id;
  const userId = req.userId;

  try {
    const result = await StoryServices.LikeStory(userId, storyId);
    res.status(200).json(result);
  } catch (err) {
    console.log("---> err in likestory -->", err);
    next(err);
  }
};

//get story by id
exports.getstorybyid = async (req, res, next) => {
  const storyId = req.body.id;
  const userId = req.userId;
  console.log("---> userId in getstorybyid -->", userId);
  console.log("---> storyId in getstorybyid -->", storyId);
  try {
    const result = await StoryServices.GetStoryById(storyId, userId);
    res.status(200).json(result);
  } catch (err) {
    console.log("---> err in getstorybyid -->", err);
    next(err);
  }
};
