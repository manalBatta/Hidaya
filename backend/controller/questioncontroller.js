const UserServices = require('../services/questionsservices');

exports.submitquestion = async (req, res, next) => {
  const userId = req.userId; // coming from token middleware
  try {
    console.log("--- req body ---", req.body);
    const {
   text, isPublic, category , tags
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