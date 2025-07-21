const UserServices = require("../services/userserviceslog&registeration");
const sendVerificationEmail = require("../utils/sendEmail");
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
      spoken_languages,
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
      spoken_languages,
    };

    const createdUser = await UserServices.registerUser(NewuserData);
    await sendVerificationEmail(email, createdUser.verificationToken);
    const userToReturn = createdUser.toObject();
    delete userToReturn.password;

    res.status(201).json({
      status: true,
      success: "User registered successfully",
      user: userToReturn,
    });
  } catch (err) {
    console.log("---> err -->", err);
    next(err);
  }
};

exports.login = async (req, res, next) => {
  const { role, email, password } = req.body;
  let user = await UserServices.checkUser(email);

  if (!user) {
    return res
      .status(404)
      .json({ status: false, message: "User does not exist" });
  }
  const isPasswordValid = await UserServices.verifyPassword(
    password,
    user.password
  );
  if (!isPasswordValid) {
    return res.status(401).json({ status: false, message: "Invalid password" });
  }
  // Allow login if user role is either 'volunteer_pending' or 'certified_volunteer' and requested role is either one
  if (
    (role === "volunteer_pending" || role === "certified_volunteer") &&
    (user.role === "volunteer_pending" || user.role === "certified_volunteer")
  ) {
    // continue, treat as authorized
    
  } else if (user.role !== role) {
    return res
      .status(403)
      .json({ status: false, message: "Access denied: role mismatch" });
  }

  // Creating Token
  let tokenData;
  tokenData = { _id: user.userId, email: user.email, role: user.role };

  const token = await UserServices.generateAccessToken(
    tokenData,
    "secret",
    "1h"
  );
  res.status(200).json({
    status: true,
    success: "sendData",
    token: token,
    user: {
      id: user.userId,
      displayName: user.displayName,
      email: user.email,
      role: user.role,
      gender: user.gender,
      country: user.country,
      language: user.language,
    savedQuestions: user.savedQuestions,
    savedLessons: user.savedLessons,
      volunteerProfile: user.volunteerProfile,
      isEmailVerified: user.isEmailVerified,
    },
  });
};
exports.updateprofile = async (req, res, next) => {
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
      certification_url,
    } = req.body;

    if (!role) {
      return res
        .status(400)
        .json({ status: false, message: "Role is required in request body" });
    }

    // Base data for all users
    let updateData = {
      displayName,
      gender,
      email,
      country,
      language,
      role,
    };
    if (role === "user") {
      updateData.savedQuestions = savedQuestions || [];
      updateData.savedLessons = savedLessons || [];
    }

    if (role === "certified_volunteer" || role === "volunteer_pending") {
      updateData.volunteerProfile = {
        bio: bio || "",
        languages: spoken_languages || [],
        certificate: {
          title: certification_title || "",
          institution: certification_institution || "",
          url: certification_url || "",
          uploadedAt: new Date(),
        },
      };
    }
    console.log("UPDATE DATA", updateData);

    const updatedUser = await UserServices.updateUserById(userId, updateData);

    const userToReturn = updatedUser.toObject
      ? updatedUser.toObject()
      : updatedUser;
    delete userToReturn.password;

    return res.status(200).json({
      status: true,
      success: "Profile updated successfully",
      user: userToReturn,
    });
  } catch (err) {
    console.log("---> err in updateprofile -->", err);
    next(err);
  }
};

exports.verifyEmail = async (req, res, next) => {
  try {
    const { token } = req.params;
    const user = await UserServices.verifyEmail(token);
    res.send(`
      <html>
        <head>
          <title>Email Verified</title>
          <style>
            body {
              background-color: #f5f5f5;
              font-family: sans-serif;
              text-align: center;
              padding-top: 100px;
            }
            .checkmark-circle {
              width: 100px;
              height: 100px;
              border-radius: 50%;
              background: white;
              border: 5px solid #4CAF50;
              display: inline-flex;
              align-items: center;
              justify-content: center;
              margin-bottom: 20px;
            }
            .checkmark {
              font-size: 48px;
              color: #4CAF50;
            }
            .message {
              font-size: 20px;
              color: #333;
            }
          </style>
        </head>
        <body>
          <div class="checkmark-circle">
            <div class="checkmark">✔</div>
          </div>
          <h2 class="message">Email verified successfully</h2>
          <p class="message">You can now login to the app.</p>
        </body>
      </html>
    `);
    res.status(200).json({ status: true, message: "Email verified successfully" });
  } catch (err) {
    console.log("---> err in verifyEmail -->", err);
    next(err);
  }
}; 

exports.changepassword = async (req, res, next) => {
  try {
    console.log("--- req body ---", req.body);
    const { currentPassword, newPassword } = req.body;
    const userId = req.userId;//coming from token middleware
    const user = await UserServices.getUserById(userId);
    const isPasswordValid = await UserServices.verifyPassword(currentPassword, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ status: false, message: "Invalid old password" });
    }
    if (currentPassword === newPassword) {
      return res.status(400).json({ status: false, message: "New password cannot be the same as old password" });
    }
    const hashedNewPassword = await UserServices.hashPassword(newPassword);
    await UserServices.updateUserById(userId, { password: hashedNewPassword });
    res.status(200).json({ status: true, message: "Password changed successfully" });
  } catch (err) {
    console.log("---> err in changepassword -->", err);
    next(err);
  }
};

exports.forgotpassword = async (req, res, next) => {
  try {
    const { email } = req.body;
    const user = await UserServices.getUserByEmail(email);
    if (!user) {
      return res.status(404).json({ status: false, message: "User not found" });
    }
    const token = await UserServices.generateAccessToken(user, "secret", "1h");
    await sendVerificationEmail(email, token);
    res.status(200).json({ status: true, message: "Password reset email sent", token: token });
  } catch (err) {
    console.log("---> err in forgotpassword -->", err);
    next(err);
  }
};