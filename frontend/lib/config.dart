// ignore_for_file: prefer_interpolation_to_compose_strings

final url = 'http://192.168.100.189:5000/';
final registeration = url + "register";
final login = url + "login";
final profile = url + "profile"; //to update profile
final questions = url + "questions"; //to get all questions
final publicQuestions = url + "public-questions"; //to get public questions
final saveQuestionUrl = url + "saveQuestion";
final submitAnswerUrl = url + "answers"; //to submit a new answer
final myquestions = url + "myquestion";
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
final deleteAns = url + "answers/delete/";
