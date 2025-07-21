const UserModel = require("../models/User");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const crypto = require("crypto");
const sendVerificationEmail = require("../utils/sendEmail");
const { v4: uuidv4 } = require("uuid");
class UserServices {
  static async registerUser(userData) {
    try {
      const rawToken = uuidv4();
const hashedToken = crypto.createHash("sha256").update(rawToken).digest("hex");

      const newUser = new UserModel({
        userId: uuidv4(),
        displayName: userData.displayName,
        gender: userData.gender,
        email: userData.email,
        password: userData.password,
        country: userData.country,
        city: userData.city || "", // optional
        role: (userData.role || "user").toLowerCase(),
        language: userData.language,
        createdAt: new Date(),
        verificationToken: hashedToken,
        verificationTokenExpires: new Date(Date.now() + 3600000), 
        // Add ai_session_id if provided
        ai_session_id: userData.ai_session_id || undefined,

        volunteerProfile:
          userData.role === "volunteer_pending"
            ? {
                certificate: {
                  title: userData.certification_title,
                  institution: userData.certification_institution,
                  url: userData.certification_url,
                  uploadedAt: new Date(),
                },
                languages: userData.spoken_languages || [],
                bio: userData.bio || "",
              }
            : undefined,
      });

      await newUser.save();
      sendVerificationEmail(newUser.email, rawToken);
      return newUser;
    } catch (err) {
      throw err;
    }
  }

  static async checkUser(email) {
    try {
      return await UserModel.findOne({ email });
    } catch (error) {
      throw error;
    }
  }

  static async verifyPassword(plainPassword, hashedPassword) {
    return await bcrypt.compare(plainPassword, hashedPassword);
  }
  static async generateAccessToken(tokenData, JWTSecret_Key, JWT_EXPIRE) {
    return jwt.sign(tokenData, JWTSecret_Key, { expiresIn: JWT_EXPIRE });
  }

  static async updateUserById(userId, updateData) {
    try {
      const updatedUser = await UserModel.findOneAndUpdate(
        { userId },
        { $set: updateData },
        { new: true, runValidators: true }
      );

      if (!updatedUser) {
        throw new Error("User not found");
      }

      return updatedUser;
    } catch (err) {
      throw err;
    }
  }

  static async verifyEmail(token) {
    if (!token) throw new Error("Token is required");
  
    const hashedToken = crypto.createHash("sha256").update(token).digest("hex");
  
    const user = await UserModel.findOne({
      verificationToken: hashedToken,
      verificationTokenExpires: { $gt: Date.now() },
    });
  
    if (!user) {
      const error = new Error("Invalid or expired verification token");
      error.statusCode = 400;
      throw error;
    }
  
    if (user.isEmailVerified) {
      const error = new Error("Email already verified");
      error.statusCode = 400;
      throw error;
    }
  
    user.isEmailVerified = true;
    user.verificationToken = undefined;
    user.verificationTokenExpires = undefined;
  
    await user.save();
  
    return user;
  }

  static async getUserById(userId) {
    try {
      return await UserModel.findOne({ userId });
    } catch (err) {
      throw err;
    }
  }

  static async hashPassword(password) {
    return await bcrypt.hash(password, 10);
  }

  static async getUserByEmail(email) {
    try {
      return await UserModel.findOne({ email });
    } catch (err) {
      throw err;
    }
  }







}

module.exports = UserServices;
