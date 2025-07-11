const FlagServices = require('../services/flagsservices');

exports.flagitem= async(req , res , next ) =>{
try{
    const { itemType, itemId, reason } = req.body;
    console.log("request body is:",req.body);
    const reportedBy = req.userId; //from token
    if (!itemType || !itemId || !reason) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const Newflag = {
     flagId: require('uuid').v4(),
      itemType,
      itemId,
      reportedBy,
      reason,
      status: 'pending',
      createdAt: new Date()
    };

   const { newFlag } = await FlagServices.SubmitFlag(Newflag);

    const flagToReturn = newFlag.toObject();
    
res.status(201).json({
  status: true,
  success: 'flag submitted successfully',
  flag: flagToReturn
});}
catch (err) {
    console.log("---> err -->", err);
    next(err);
  }

};