// ignore_for_file: prefer_interpolation_to_compose_strings

//final url = 'http://192.168.100.189:5000/';
final url = 'http://localhost:5000/';
final registeration = url + "register";
final login = url + "login";
final profile = url + "profile"; //to update profile
final changePassword = url + "change-password"; //to change password
final questions = url + "questions"; //to get all questions
final publicQuestions = url + "public-questions"; //to get public questions
final saveQuestionUrl = url + "saveQuestion";
final submitAnswerUrl = url + "answers"; //to submit a new answer
final myquestions = url + "my-questions";
final vote = url + 'answers/vote';
final upvotedAnswerUrl = url + 'upvotedAnswer';
final myAnswersUrl = url + "myAnwers";
final startChat = url + 'chat/start';
final sendChat = url + 'chat/send';

final deleteQuestionUrl =
    url +
    "deletequestions/"; // usage: deleteQuestionUrl + questionId to delete a question
final updateQuestionUrl =
    url +
    "updatequestions/"; // usage: updateQuestionUrl + questionId to update a question
final forgotPassword = url + "forgot-password"; //to forgot password

final deleteAns = url + "answers/delete/";
final deletAccounturl = url + "delete-account";
final storyUrl = url + "story";
final saveStoryUrl = url + "story/savestory";
final likeStoryUrl = url + "story/likestory";
final userGrowth = url + "admin/user-growth";
final gender = url + "admin/gender-distribution";
final questionCategories = url + "admin/question-categories";
final dashboardStatsUrl = url + "admin/dashboard-stats";
final todayActivityUrl = url + "admin/today-activity";
final topContentUrl = url + "admin/top-content";
final allUsersUrl = url + "admin/users";
final approveVolunteerUrl = url + "admin/approve-voulnteer";
final adminEditUserUrl = url + "admin/edit-user"; // usage: adminEditUserUrl

// Admin endpoints for questions and answers
final adminAllQuestionsUrl = url + "admin/questions";
final adminAllAnswersUrl = url + "admin/answers";
final adminUpdateQuestionUrl = url + "admin/update-question"; // usage: adminUpdateQuestionUrl + questionId
final flagQuestionUrl = url + "admin/flag-question/"; // usage: flagQuestionUrl + questionId
final adminUpdateAnswerUrl = url + "admin/update-answer"; // usage: adminUpdateAnswerUrl + answerId
final adminHideAnswerUrl = url + "admin/hide-answer"; // usage: adminHideAnswerUrl + answerId
