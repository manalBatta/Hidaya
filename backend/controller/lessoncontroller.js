


const LessonServices=require("../services/lessonservices");

exports.getalllesson = async(req , res , next ) =>{
    try{
  const alllesson = await LessonServices.GetAllLessons();
  res.status(200).json({
    status: true,
    success: "Getting all lessons  successfully",
    lesson: alllesson,
  });
    }
    catch(err){
       console.error("Error fetching lessons:", err);
    res.status(500).json({
      status: false,
      message: "Failed to fetch lessons",
      error: err.message
    });
    }
};