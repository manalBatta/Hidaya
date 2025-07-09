const UserServices = require('../services/userserviceslog&registeration');

exports.register = async (req, res, next) => {
  try {
    console.log("--- req body ---", req.body);

    const {
      displayname,
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
      displayname,
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
        tokenData = { _id: user._userId, email: user.email, role:user.role };
    
        const token = await UserServices.generateAccessToken(tokenData,"secret","1h")
        res.status(200).json({ status: true, success: "sendData", token: token ,  user: {
    id: user._id,
    username: user.username,
    email: user.email,
    role: user.role,
    gender: user.gender,
    country: user.country,
    city: user.city,
    language: user.language,
    bio: user.bio,
    spoken_languages: user.spoken_languages,
    certification_title: user.certification_title,
    certification_institution: user.certification_institution,
    certification_url: user.certification_url,
  }});

}


