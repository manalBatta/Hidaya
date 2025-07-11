
const FlagModel = require("../models/Flags");

const { v4: uuidv4 } = require('uuid');
class FlagServices {
  static async SubmitFlag(data) {


    try {
      const newFlag = new FlagModel({
     flagId: data.flagId,
    itemType: data.itemType,
    itemId: data.itemId,
    reportedBy: data.reportedBy,
      reason: data.reason,
      status: data.status,
      createdAt: data.createdAt
      });

      await newFlag.save();
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