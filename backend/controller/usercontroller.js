const UserServices = require("../services/userserviceslog&registeration");
const admin = require("firebase-admin");
const { sendNotification } = require("../services/notificationService.js");
const { sendMissedNotifications } = require("./notificationcontroller.js");

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
      onesignalId: user.onesignalId,
    },
  });

  // Send welcome notification and check for missed notifications
  try {
    // Welcome notification using new service
    const welcomeResult = await sendNotification({
      userId: user.userId,
      type: "welcome",
      title: "Welcome to Hidaya! 🎉",
      message: `Hello ${user.displayName}! Welcome back to your Islamic learning journey.`,
      data: {
        userId: user.userId,
      },
    });

    console.log("Welcome notification result:", welcomeResult);

    // Check for missed notifications for volunteers
    if (
      user.role === "certified_volunteer" ||
      user.role === "volunteer_pending"
    ) {
      await sendMissedNotifications(user);
    }
  } catch (notificationError) {
    console.log("Failed to send welcome notification:", notificationError);
    // Don't fail the login if notification fails
  }
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

// Update OneSignal ID for push notifications
exports.updateOneSignalId = async (req, res, next) => {
  try {
    const userId = req.userId;
    const { onesignalId } = req.body;

    if (!onesignalId) {
      return res.status(400).json({
        status: false,
        message: "OneSignal ID is required",
      });
    }

    const updatedUser = await UserServices.updateOneSignalId(
      userId,
      onesignalId
    );

    res.status(200).json({
      status: true,
      success: "OneSignal ID updated successfully",
      user: {
        id: updatedUser.userId,
        onesignalId: updatedUser.onesignalId,
      },
    });
  } catch (err) {
    console.log("---> err in updateOneSignalId -->", err);
    next(err);
  }
};
