import moment from 'moment-timezone';
import User from '../models/User.js';
import Question from '../models/Questions.js';
import Story from '../models/Stories.js';
 import Flag from '../models/Flags.js';
 import Answer from '../models/Answers.js';
 import { v4 as uuidv4 } from 'uuid';
const timezone = 'Asia/Palestine';

const categories = [
  "Worship",
  "Prayer",
  "Fasting",
  "Hajj & Umrah",
  "Islamic Finance",
  "Family & Marriage",
  "Daily Life",
  "Quran & Sunnah",
  "Islamic History",
  "Etiquette",
  "Other",
];

class AdminServices {
  static async getCumulativeMonthlyUsers(users) {
    const monthlyCounts = {};
    //reset the monthlyCounts object
    const monthOrder = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    monthOrder.forEach((month) => (monthlyCounts[month] = 0));

    // count the users for each month
    users.forEach((user) => {
      const month = moment(user.createdAt).format("MMM");
      monthlyCounts[month] = (monthlyCounts[month] || 0) + 1;
    });

    // sort the months

    let cumulative = 0;
    let previousMonthCount = 0;

    const result = monthOrder.map((month) => {
      const currentMonthCount = monthlyCounts[month];
      cumulative += currentMonthCount;
      let percentChange = null;
      if (previousMonthCount > 0) {
        percentChange = (
          ((currentMonthCount - previousMonthCount) / previousMonthCount) *
          100
        ).toFixed(2);
      } else if (currentMonthCount > 0) {
        percentChange = "100.00";
      } else {
        percentChange = "0.00";
      }
      const monthData = {
        month,
        users: cumulative,
        newUsers: currentMonthCount,
        percentChange: `${percentChange}%`,
      };

      previousMonthCount = currentMonthCount;
      return monthData;
    });
    console.log(result);
    return result;
  }

  static async getQuestionCategories(allQuestions) {
    const categoryCountMap = {};
    categories.forEach((cat) => (categoryCountMap[cat] = 0));

    allQuestions.forEach((question) => {
      const categoriesList = Array.isArray(question.category)
        ? question.category
        : [question.category]; // handle the case where category is a string directly

      categoriesList.forEach((category) => {
        if (category && categoryCountMap.hasOwnProperty(category)) {
          categoryCountMap[category]++;
        }
      });
    });

    const result = categories.map((category) => ({
      category,
      count: categoryCountMap[category] || 0,
    }));
    console.log(result);
    return result;
  }
  static async getGenderDistribution(allUsers) {
    const genderDistribution = {};
    genderDistribution.male = 0;
    genderDistribution.female = 0;
    genderDistribution.other = 0;
    allUsers.forEach((user) => {
      if (user.gender === "Male") {
        genderDistribution.male++;
      } else if (user.gender === "Female") {
        genderDistribution.female++;
      } else {
        genderDistribution.other++;
      }
    });
    console.log(genderDistribution);
    return genderDistribution;
  }
  static async getDashboardStats() {
    const dashinfo = {};
    const today = new Date();
    const currentDay = today.getDay(); // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
    const startOfThisWeek = new Date(today);
    startOfThisWeek.setDate(today.getDate() - currentDay); // Sunday
    startOfThisWeek.setHours(0, 0, 0, 0);

    const startOfLastWeek = new Date(startOfThisWeek);
    startOfLastWeek.setDate(startOfThisWeek.getDate() - 7);

    const endOfLastWeek = new Date(startOfThisWeek);
    endOfLastWeek.setSeconds(-1);

    const startOfToday = moment.tz(timezone).startOf("day").toDate();
    const startOfYesterday = moment
      .tz(timezone)
      .subtract(1, "day")
      .startOf("day")
      .toDate();
    const endOfYesterday = moment
      .tz(timezone)
      .subtract(1, "day")
      .endOf("day")
      .toDate();

    dashinfo.totalusers = await User.countDocuments();

    // Calculate monthly increase in users
    const startOfThisMonth = moment.tz(timezone).startOf("month").toDate();
    const startOfLastMonth = moment
      .tz(timezone)
      .subtract(1, "month")
      .startOf("month")
      .toDate();
    const endOfLastMonth = moment
      .tz(timezone)
      .subtract(1, "month")
      .endOf("month")
      .toDate();

    const usersThisMonth = await User.countDocuments({
      createdAt: { $gte: startOfThisMonth },
    });
    const usersLastMonth = await User.countDocuments({
      createdAt: { $gte: startOfLastMonth, $lte: endOfLastMonth },
    });

    dashinfo.monthlyincreaseinusers = usersThisMonth - usersLastMonth;
    dashinfo.totalquestions = await Question.countDocuments();
    const questionToday = await Question.countDocuments({
      createdAt: { $gte: startOfYesterday },
    });
    const questionYesterday = await Question.countDocuments({
      createdAt: { $gte: startOfYesterday, $lte: endOfYesterday },
    });
    dashinfo.dailyincreaseinquestions = questionToday - questionYesterday;
    console.log(
      "questionToday: " + questionToday,
      "questionYesterday: " + questionYesterday
    );

    dashinfo.totalstories = await Story.countDocuments();
    dashinfo.totalflags = await Flag.countDocuments();
    dashinfo.totalcertifiedvolunteers = await User.countDocuments({
      role: "certified_volunteer",
    });
    const CertifiedThisWeek = await User.countDocuments({
      role: "certified_volunteer",
      createdAt: { $gte: startOfLastWeek },
    });

    const CertifiedLastWeek = await User.countDocuments({
      role: "certified_volunteer",
      createdAt: { $gte: startOfLastWeek, $lte: endOfLastWeek },
    });
    console.log(CertifiedThisWeek, CertifiedLastWeek);

    dashinfo.weeklyincreaseincertifiedvolunteers =
      CertifiedThisWeek - CertifiedLastWeek;

    dashinfo.totalpendingvolunteers = await User.countDocuments({
      role: "volunteer_pending",
    });
    const pendingToday = await User.countDocuments({
      role: "volunteer_pending",
      createdAt: { $gte: startOfYesterday },
    });
    const pendingYesterday = await User.countDocuments({
      role: "volunteer_pending",
      createdAt: { $gte: startOfYesterday, $lte: endOfYesterday },
    });
    dashinfo.dailyincreaseinpendingvolunteers = pendingToday - pendingYesterday;

    dashinfo.totalansweredquestions = await Question.countDocuments({
      topAnswerId: { $exists: true, $ne: null, $ne: "" },
    });
    dashinfo.totalunansweredquestions = await Question.countDocuments({
      $or: [
        { topAnswerId: "" },
        { topAnswerId: { $exists: false } },
        { topAnswerId: null },
      ],
    });

    return dashinfo;
  }

  static async getTodayActivity() {
    const today = new Date();
    const todayActivity = {};
    todayActivity.newusers = await User.countDocuments({
      createdAt: { $gte: today },
    });
    todayActivity.newquestions = await Question.countDocuments({
      createdAt: { $gte: today },
    });
    todayActivity.newstories = await Story.countDocuments({
      createdAt: { $gte: today },
    });
    todayActivity.newflags = await Flag.countDocuments({
      createdAt: { $gte: today },
    });
    console.log(todayActivity);
    return todayActivity;
  }
  static async GetTopContent() {
    const topcontent = {};
    const [topLikedStory] = await Story.aggregate([
      {
        $addFields: {
          likeCountNum: { $toInt: "$likeCount" },
        },
      },
      { $sort: { likeCountNum: -1 } },
      { $limit: 1 },
    ]);
    const [topSavedStory] = await Story.aggregate([
      {
        $addFields: {
          saveCountNum: { $toInt: "$SaveCount" },
        },
      },
      { $sort: { saveCountNum: -1 } },
      { $limit: 1 },
    ]);
    topcontent.toplikedstories = topLikedStory || null;
    topcontent.topsavedstories = topSavedStory || null;

    const users = await User.find({}, "savedQuestions");
    const questionSaveMap = {};
    users.forEach((user) => {
      user.savedQuestions.forEach((questionId) => {
        questionSaveMap[questionId] = (questionSaveMap[questionId] || 0) + 1;
      });
    });
    let mostSavedQuestionId = null;
    let maxSaves = 0;

    for (const [id, count] of Object.entries(questionSaveMap)) {
      if (count > maxSaves) {
        mostSavedQuestionId = id;
        maxSaves = count;
      }
    }
    let mostSavedQuestion = null;
    if (mostSavedQuestionId) {
      mostSavedQuestion = await Question.findOne({
        questionId: mostSavedQuestionId,
      });
    }
    topcontent.mostsavedquestion = mostSavedQuestion || null;

        console.log(topcontent);
          return topcontent;

    }
    static async getUsersData(){
        const usersdata = await User.find({});//i want to get all the information of the users
        const questions = await Question.find({});
        const answers = await Answer.find({});

        //i want to to get the number of the questions that asked by the user and the question that answered by the volunteer (not only the top answer)
       const userStats=usersdata.map(user => {
        const userId = user.userId;

        const questionsAsked = questions.filter(q => q.askedBy === userId).length;
        const questionsAnswered = answers.filter(a => a.answeredBy === userId).length;

        return {
            ...user.toObject(),
            questionsAsked,
            questionsAnswered,
        };
    });
    console.log(userStats);
        return userStats;
    }

    static async approveVoulnteer(volunteerId){
        console.log(volunteerId);
        const user = await User.findOneAndUpdate(
            { userId: volunteerId },
            { role: 'certified_volunteer' },
            { new: true });//i want to update the role of the user to certified_volunteer
        console.log(user);
        return user;
    }

    static async getFlags(){
        const flags = await Flag.find({});
        console.log(flags);
        return flags;
    }

    static async getallstories(){
        const stories = await Story.find({});
        console.log(stories);
        return stories;
    }
    static async AddNewStory(storyData){
        if(!storyData.title || !storyData.description || !storyData.journeyToIslam ||!storyData.background ||!storyData.afterIslam || !storyData.type || !storyData.mediaUrl || !storyData.name || !storyData.country || !storyData.tags || !storyData.quote){
            throw new Error("Missing required fields");
        }
        const newstory = {
            title: storyData.title,
            description: storyData.description,
            background: storyData.background,
            journeyToIslam: storyData.journeyToIslam,
            afterIslam: storyData.afterIslam,
            type: storyData.type,
            mediaUrl: storyData.mediaUrl,
            name: storyData.name,
            country: storyData.country,
            tags: storyData.tags,
            quote: storyData.quote,
            SaveCount: 0,
            likeCount: 0,
            views: 0,
          };
          const story = await Story.create(newstory);
          if(!story){
            throw new Error("Failed to add story");
          }else{
            console.log(story);
            return {success:true,message:"Story added successfully",story:story};
          }


        
    }
    static async updateStory(storyId,storyData){
        console.log(storyId,storyData);
        const story = await Story.findOneAndUpdate({_id:storyId},storyData,{new:true});
        console.log(story);
        if(!story){
            throw new Error("Failed to update story");
        }else{
            console.log(story);
            return story;
        }


    }


    static async deleteStory(storyId){
        const story = await Story.findOneAndDelete({_id:storyId});
        console.log(story);
        return story;
    }


}   








export default AdminServices;
