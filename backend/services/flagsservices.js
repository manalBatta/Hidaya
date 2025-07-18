
const FlagModel = require("../models/Flags");
const QuestionModel = require("../models/Questions");
const AnswerModel = require("../models/Answers");
const { v4: uuidv4 } = require('uuid');
class FlagServices {
  static async SubmitFlag(data) {


    try {
      const newFlag = new FlagModel({
     flagId: data.flagId,
    itemType: data.itemType,
    itemId: data.itemId,
    reportedBy: data.reportedBy,
    reason: data.description,
      status: 'pending',
      createdAt: new Date()
      });

      await newFlag.save();
      await QuestionModel.findOneAndUpdate({ questionId: data.itemId }, { isFlagged: true });
      await AnswerModel.findOneAndUpdate({ answerId: data.itemId }, { isFlagged: true });
      return {newFlag};
    } catch (err) {
      throw err;
    }
  }
 
 
}

module.exports = FlagServices;
/*
     flagId: require('uuid').v4(),
      itemType,
      itemId,
      reportedBy,
      reson,
      status: 'pending',
      createdAt: new Date()





*/ 