
const LessonModel = require('../models/Lessons');
class LessonServices {
static async GetAllLessons() {
  try {
     const lessons = await LessonModel.find({});
      return lessons;
  } catch (err) {
    console.error("Error in GetAllLessons:", err);
    throw err;
  }
}

}
module.exports = LessonServices;