const UserServices = require('../services/userserviceslog&registeration');

exports.register = async (req, res, next) => {
  try {
    console.log("--- req body ---", req.body);

    const {
      displayName,
      email,
      password,
      gender,
      country,
      city,
      role,
      language,
      certification_title,
      certification_institution,
      certification_url,
      bio,
      spoken_languages
    } = req.body;

    const NewuserData = {
      displayName,
      email,
      password,
      gender,
      country,
      city,
      role,
      language,
      certification_title,
      certification_institution,
      certification_url,
      bio,
      spoken_languages
    };

   const createdUser =await UserServices.registerUser(NewuserData);

const userToReturn = createdUser.toObject();
delete userToReturn.password;

res.status(201).json({
  status: true,
  success: 'User registered successfully',
  user: userToReturn
});
  } catch (err) {
    console.log("---> err -->", err);
    next(err);
  }
};

exports.login=async (req , res , next) =>{
          const { role, email ,password} = req.body;
           let user = await UserServices.checkUser(email);
        
if (!user) {
      return res.status(404).json({ status: false, message: 'User does not exist' });
    }       
        const isPasswordValid = await UserServices.verifyPassword(password, user.password);
 if (!isPasswordValid) {
      return res.status(401).json({ status: false, message: 'Invalid password' });
    }
    
    if(user.role!==role){
  return res.status(403).json({ status: false, message: 'Access denied: role mismatch' });

    }
         // Creating Token
        let tokenData;
        tokenData = { _id: user.userId, email: user.email, role:user.role };
    
        const token = await UserServices.generateAccessToken(tokenData,"secret","1h")
        res.status(200).json({ status: true, success: "sendData", token: token ,  user: {
    id: user.userId,
    username: user.displayName,
    email: user.email,
    role: user.role,
    gender: user.gender,
    country: user.country,
    language: user.language,
    volunteerProfile: user.volunteerProfile,
  }});

};
exports.updateprofile=async (req , res , next) =>{
try {
    const userId = req.userId; // coming from token middleware
    const {
      displayName,
      gender,
      email,
      country,
      language,
      role,
      savedQuestions,
      savedLessons,
      bio,
      spoken_languages,
      certification_title,
      certification_institution,
      certification_url
    } = req.body;
  
  if (!role) {
      return res.status(400).json({ status: false, message: 'Role is required in request body' });
    }

    // Base data for all users
    let updateData = {
      displayName,
      gender,
      email,
      country,
      language,
      role
    };
  if (role === 'user') {
      updateData.savedQuestions = savedQuestions || [];
      updateData.savedLessons = savedLessons || [];
    }

    if (role === 'certified_volunteer' || role === 'volunteer_pending') {
      updateData.volunteerProfile = {
        bio: bio || '',
        languages: spoken_languages || [],
        certificate: {
          title: certification_title || '',
          institution: certification_institution || '',
          url: certification_url || '',
          uploadedAt: new Date()
        }
      };
    }
console.log("UPDATE DATA", updateData);

const updatedUser = await UserServices.updateUserById(userId, updateData);

    const userToReturn = updatedUser.toObject ? updatedUser.toObject() : updatedUser;
    delete userToReturn.password;

    return res.status(200).json({
      status: true,
      success: 'Profile updated successfully',
      user: userToReturn
    });


  
  }

catch (err) {
    console.log('---> err in updateprofile -->', err);
    next(err);
  }




};

