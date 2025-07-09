const UserModel = require("../models/User");
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

const { v4: uuidv4 } = require('uuid');
class UserServices {
  static async registerUser(userData) {
    try {
      const newUser = new UserModel({
        userId: uuidv4(),
        displayName: userData.username,
        gender: userData.gender,
        email: userData.email,
        password: userData.password,
        country: userData.country,
        city: userData.city || "", // optional
role: (userData.role || 'user').toLowerCase(),
        language: userData.language,
        createdAt: new Date(), 
        volunteerProfile: userData.role === 'volunteer_pending' ? {
          certificate: {
            title: userData.certification_title,
            institution: userData.certification_institution,
            url: userData.certification_url,
            uploadedAt: new Date(),
          },
          languages: userData.spoken_languages || [],
          bio: userData.bio || "",
        } : undefined,
      });
         
      await newUser.save();
return newUser;
    } catch (err) {
      throw err;
    }
  }

  static async checkUser(email){
        try {
            return await UserModel.findOne({email});
        } catch (error) {
            throw error;
        }
    }

    static async verifyPassword(plainPassword,hashedPassword){
          return await bcrypt.compare(plainPassword, hashedPassword);

    }
static async generateAccessToken(tokenData,JWTSecret_Key,JWT_EXPIRE){
        return jwt.sign(tokenData, JWTSecret_Key, { expiresIn: JWT_EXPIRE });
    }





}


module.exports = UserServices;
