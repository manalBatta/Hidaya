
const QuestionModel = require("../models/Questions");
const UserModel = require("../models/User");
const AnswerModel = require("../models/Answers");

const { v4: uuidv4 } = require('uuid');
class QuestionServices {
  static async SubmitQuestion(data,id) {
    const user = await UserModel.findOne({ userId: id });
    console.log("User ID passed to SubmitQuestion:", user);

    try {
      const newQuestion = new QuestionModel({
        questionId: uuidv4(),
        text: data.text,
        isPublic: data.isPublic ?? true,
        askedBy: id,
        aiAnswer: data.aiAnswer || "", 
        topAnswerId: data.topAnswerId || "", 
        tags: data.tags || [],
        category: data.category || "",
        createdAt: new Date()
      });

      await newQuestion.save();
      console.log("Saved question:", newQuestion);

      return {newQuestion , user };
    } catch (err) {
      throw err;
    }
  }

  static async GetPublicQuestions(page = 1, limit = 3, userCountry = '', userTags = []) {
    try {
      // Fetch all public questions (no skip/limit yet)
      const allQuestions = await QuestionModel.find({ isPublic: true }).lean();
      const totalCount = allQuestions.length;
     
      // Custom sort logic
      function tagSimilarity(qTags) {
        if (!userTags.length || !qTags || !qTags.length) return 0;
        return qTags.filter(tag => userTags.includes(tag)).length;
      }
      function locationScore(qCountry) {
        if (!qCountry || !userCountry) return 0;
        return qCountry.toLowerCase() === userCountry.toLowerCase() ? 1 : 0;
      }
      function freshnessScore(createdAt) {
        const date = new Date(createdAt);
        return -date.getTime();
      }
      // Enrich with user info for sorting
      const userIds = [...new Set(allQuestions.map(q => q.askedBy))];
      const users = await UserModel.find({ userId: { $in: userIds } }, { userId: 1, country: 1 }).lean();
      const userMap = {};
      users.forEach(u => { userMap[u.userId] = u; });
      // Sort all questions
      allQuestions.sort((a, b) => {
        const aTags = a.tags || [];
        const bTags = b.tags || [];
        const aCountry = userMap[a.askedBy]?.country || '';
        const bCountry = userMap[b.askedBy]?.country || '';
        const tagA = tagSimilarity(aTags);
        const tagB = tagSimilarity(bTags);
        const locA = locationScore(aCountry);
        const locB = locationScore(bCountry);
        const freshA = freshnessScore(a.createdAt);
        const freshB = freshnessScore(b.createdAt);
        const scoreA = tagA * 100 + locA * 50 + Math.floor(freshA / 1000000);
        const scoreB = tagB * 100 + locB * 50 + Math.floor(freshB / 1000000);
        return scoreB - scoreA;
      });
      // Pagination for the questions after sorting
      const skip = (page - 1) * limit;
      const paginatedQuestions = allQuestions.slice(skip, skip + limit);
      // Fetch top answers and enrich as before
      const topAnswerIds = paginatedQuestions.map(q => q.topAnswerId).filter(Boolean);
      const topAnswers = await AnswerModel.find(
        { answerId: { $in: topAnswerIds } },
        {
          answerId: 1,
          questionId: 1,
          text: 1,
          answeredBy: 1,
          createdAt: 1,
          language: 1,
          upvotesCount: 1
        }
      );
      const answerUserIds = [...new Set(topAnswers.map(a => a.answeredBy))];
      const allUserIds = [...new Set([...userIds, ...answerUserIds])];
      const fullUsers = await UserModel.find(
        { userId: { $in: allUserIds } },
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
      );
      const fullUserMap = {};
      fullUsers.forEach(user => {
        fullUserMap[user.userId] = user;
      });
      const answerMap = {};
      topAnswers.forEach(ans => {
        const ansUser = fullUserMap[ans.answeredBy];
        answerMap[ans.answerId] = {
          answerId: ans.answerId,
          questionId: ans.questionId,
          text: ans.text,
          createdAt: ans.createdAt,
          language: ans.language,
          upvotesCount: ans.upvotesCount,
          answeredBy: ansUser
            ? {
                id: ansUser.userId,
                displayName: ansUser.displayName,
                country: ansUser.country,
                gender: ansUser.gender,
                email: ansUser.email,
                language: ansUser.language,
                role: ansUser.role,
                savedQuestions: ansUser.savedQuestions,
                savedLessons: ansUser.savedLessons,
                createdAt: ansUser.createdAt
              }
            : null
        };
      });
      const questionsWithDetails = paginatedQuestions.map(q => {
        const askedUser = fullUserMap[q.askedBy];
        return {
          ...q,
          isFlagged: q.isFlagged,
          askedBy: askedUser
            ? {
                id: askedUser.userId,
                displayName: askedUser.displayName,
                country: askedUser.country,
                gender: askedUser.gender,
                email: askedUser.email,
                language: askedUser.language,
                role: askedUser.role,
                savedQuestions: askedUser.savedQuestions,
                savedLessons: askedUser.savedLessons,
                createdAt: askedUser.createdAt
              }
            : null,
          topAnswer: q.topAnswerId ? answerMap[q.topAnswerId] || null : null,
        };
      });
      return {
        questions: questionsWithDetails,
        totalCount
      };
    } catch (err) {
      console.error("Error in GetPublicQuestions:", err);
      throw err;
    }
  }
   
  

  



static async GetQuestionOfUser(userid) {
  console.log("userid is:", userid);

  try {
    // Get all questions by the user
    const questions = await QuestionModel.find({ askedBy: userid }).sort({ createdAt: -1 }).lean();

    if (!questions.length) return [];

    // Get askedBy user details once
    const askedByUser = await UserModel.findOne(
      { userId: userid },
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

    const enrichedQuestions = [];

    for (const q of questions) {
      let topAnswer = null;

      if (q.topAnswerId) {
        const rawTopAnswer = await AnswerModel.findOne({ answerId: q.topAnswerId }).lean();

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

const { topAnswerId, ...questionWithoutTopAnswerId } = q;

enrichedQuestions.push({
  ...questionWithoutTopAnswerId,
  isFlagged: q.isFlagged, // Ensure isFlagged is included
  askedBy: askedByUser
    ? {
        id: askedByUser.userId,
        displayName: askedByUser.displayName,
        country: askedByUser.country,
        gender: askedByUser.gender,
        email: askedByUser.email,
        language: askedByUser.language,
        role: askedByUser.role,
        savedQuestions: askedByUser.savedQuestions,
        savedLessons: askedByUser.savedLessons,
        createdAt: askedByUser.createdAt
      }
    : null,
  topAnswer
});
;
    }
console.log("uuuu",enrichedQuestions)
    return enrichedQuestions;
  } catch (err) {
    console.error("Error in GetQuestionOfUser:", err);
    throw err;
  }
}


static async SaveQuestion(userId, questionId) {
  const user = await UserModel.findOne({ userId });

  if (!user) return null;

  const index = user.savedQuestions.indexOf(questionId);
   let status;
  if (index === -1) {
    // Not saved yet — add it
    user.savedQuestions.push(questionId);
    status='saved';
  } else {
    // Already saved — remove it
    user.savedQuestions.splice(index, 1);
    status='removed';
  }

  await user.save();
  return status;
}

static async DeleteQuestion(userId,questionId){
  const question = await QuestionModel.findOne({questionId}) //find the question by the questionId
  if(!question){
    return null;
  }
  if(question.askedBy !== userId){
    return null;
  }
  await QuestionModel.deleteOne({questionId}) //delete the question from the question table
  await AnswerModel.deleteMany({ questionId }); //delete the answers of this question from the answer table

  await UserModel.updateMany(
    { savedQuestions: questionId }, //find the users who saved this question
    { $pull: { savedQuestions: questionId } } //remove the question from the savedQuestions array of the users
  );
  return true;

}

static async UpdateQuestion(userId,questionId,text,category,isPublic,aiAnswer){
  const question = await QuestionModel.findOne({questionId});
  if(!question){
    return null;
  }
  if(question.askedBy !== userId){
    return null;
  }
  question.text = text;
  question.category = category;
  question.isPublic = isPublic;
  question.aiAnswer = aiAnswer;
  await question.save();
  return question;
  
}





}

module.exports = QuestionServices;