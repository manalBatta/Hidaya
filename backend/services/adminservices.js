import moment from 'moment-timezone';
import User from '../models/User.js';
import Question from '../models/Questions.js';
import Story from '../models/Stories.js';
 import Flag from '../models/Flags.js';
const timezone = 'Asia/Palestine';

const categories = [
    'Worship',
    'Prayer',
    'Fasting',
    'Hajj & Umrah',
    'Islamic Finance',
    'Family & Marriage',
    'Daily Life',
    'Quran & Sunnah',
    'Islamic History',
    'Etiquette',
    'Other',
  ];



 class AdminServices {
    static async  getCumulativeMonthlyUsers(users) {
        const monthlyCounts = {};
         //reset the monthlyCounts object
         const monthOrder = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
         monthOrder.forEach(month => monthlyCounts[month] = 0);

        // count the users for each month
        users.forEach(user => {
          const month = moment(user.createdAt).format('MMM');
          monthlyCounts[month] = (monthlyCounts[month] || 0) + 1;
        });
      
        // sort the months
      
        let cumulative = 0;
        let previousMonthCount = 0;
      
        const result = monthOrder.map(month => {
            const currentMonthCount = monthlyCounts[month];
            cumulative += currentMonthCount;
            let percentChange = null;
            if (previousMonthCount > 0) {
                percentChange = ((currentMonthCount - previousMonthCount) / previousMonthCount * 100).toFixed(2);
              } else if (currentMonthCount > 0) {
                percentChange = "100.00";
              } else {
                percentChange = "0.00";
              }
              const monthData = {
                month,
                users: cumulative,
                newUsers: currentMonthCount,
                percentChange: `${percentChange}%`
              };
          
              previousMonthCount = currentMonthCount;
              return monthData
          });
        console.log(result);
        return result;
        
    }

    static async getQuestionCategories(allQuestions) {
        const categoryCountMap = {};
        categories.forEach(cat => categoryCountMap[cat] = 0);
         
    
        allQuestions.forEach(question => {
            const categoriesList = Array.isArray(question.category)
                ? question.category
                : [question.category]; // handle the case where category is a string directly
    
                categoriesList.forEach(category => {
                    if (category && categoryCountMap.hasOwnProperty(category)) {
                        categoryCountMap[category]++;
                    }
                });
        
        });
    
        const result = categories.map(category => ({
            category,
            count: categoryCountMap[category] || 0
        }));
        console.log(result);
        return result;
    }
    static async getGenderDistribution(allUsers) {
        const genderDistribution = {};
        genderDistribution.male = 0;
        genderDistribution.female = 0;
        genderDistribution.other = 0;
        allUsers.forEach(user => {
            if (user.gender === 'Male') {
                genderDistribution.male++;  
            } else if (user.gender === 'Female') {
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
        console.log(startOfThisWeek, endOfLastWeek);
        console.log(startOfLastWeek);

        const startOfToday = moment.tz(timezone).startOf('day').toDate();
        const startOfYesterday = moment.tz(timezone).subtract(1, 'day').startOf('day').toDate();
        const endOfYesterday = moment.tz(timezone).subtract(1, 'day').endOf('day').toDate();
        console.log(startOfToday, startOfYesterday, endOfYesterday);
        console.log(startOfToday.toString());
        console.log(startOfYesterday.toString());
        console.log(endOfYesterday.toString());



        dashinfo.totalusers = await User.countDocuments();
        dashinfo.totalquestions = await Question.countDocuments();
        const questionToday = await Question.countDocuments({createdAt: { $gte: startOfYesterday }});
        const questionYesterday = await Question.countDocuments({createdAt: { $gte: startOfYesterday, $lte: endOfYesterday }});
        dashinfo.dailyincreaseinquestions = questionToday - questionYesterday;
        console.log("questionToday: "+questionToday, "questionYesterday: "+questionYesterday);
        


        dashinfo.totalstories = await Story.countDocuments();
        dashinfo.totalflags = await Flag.countDocuments();
        dashinfo.totalcertifiedvolunteers = await User.countDocuments({role: 'certified_volunteer'});
        const CertifiedThisWeek = await User.countDocuments({
            role: 'certified_volunteer',
            createdAt: { $gte: startOfLastWeek }
          });
        
          const CertifiedLastWeek = await User.countDocuments({
            role: 'certified_volunteer',
            createdAt: { $gte: startOfLastWeek, $lte: endOfLastWeek }
          });
          console.log(CertifiedThisWeek, CertifiedLastWeek);

          dashinfo.weeklyincreaseincertifiedvolunteers = CertifiedThisWeek - CertifiedLastWeek;





        dashinfo.totalpendingvolunteers = await User.countDocuments({role: 'volunteer_pending'});
         const pendingToday = await User.countDocuments({role: 'volunteer_pending', createdAt: { $gte: startOfYesterday }});
         const pendingYesterday = await User.countDocuments({role: 'volunteer_pending', createdAt: { $gte: startOfYesterday, $lte: endOfYesterday }});
         dashinfo.dailyincreaseinpendingvolunteers = pendingToday - pendingYesterday;
         



        dashinfo.totalansweredquestions = await Question.countDocuments({ topAnswerId: { $exists: true, $ne: null, $ne: "" }  });
        dashinfo.totalunansweredquestions = await Question.countDocuments({   $or: [
            { topAnswerId: "" },
            { topAnswerId: { $exists: false } },
            { topAnswerId: null }
          ]
        });
       
        return dashinfo;
    }
    static async getTodayActivity() {
        const today = new Date();
        const todayActivity = {};
        todayActivity.totalusers = await User.countDocuments({ createdAt: { $gte: today } });
        todayActivity.totalquestions = await Question.countDocuments({ createdAt: { $gte: today } });
        todayActivity.totalstories = await Story.countDocuments({ createdAt: { $gte: today } });
        todayActivity.totalflags = await Flag.countDocuments({ createdAt: { $gte: today } });
        console.log(todayActivity);
        return todayActivity;
    }
    static async GetTopContent(){
        const topcontent = {};
        const [topLikedStory] = await Story.aggregate([
            {
                $addFields: {
                    likeCountNum: { $toInt: "$likeCount" }
                }
            },
            { $sort: { likeCountNum: -1 } },
            { $limit: 1 }
        ]);   
        const [topSavedStory] = await Story.aggregate([
            {
                $addFields: {
                    saveCountNum: { $toInt: "$SaveCount" }
                }
            },
            { $sort: { saveCountNum: -1 } },
            { $limit: 1 }
        ]);   
        topcontent.toplikedstories = topLikedStory || null;
        topcontent.topsavedstories = topSavedStory || null;

        const users = await User.find({}, 'savedQuestions');
        const questionSaveMap = {};
        users.forEach(user => {
            user.savedQuestions.forEach(questionId => {
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
        mostSavedQuestion = await Question.findOne({ questionId: mostSavedQuestionId });
    }
    topcontent.mostsavedquestion = mostSavedQuestion || null;

        console.log(topcontent);
          return topcontent;

    }

}   








 export default AdminServices;
 