const UserServices = require("../services/userserviceslog&registeration");
const { sendNotification } = require("../services/notificationService.js");

// Get user notifications
exports.getNotifications = async (req, res, next) => {
  try {
    const userId = req.userId;

    const notifications = await UserServices.getNotifications(userId);

    // Sort notifications by createdAt (newest first)
    const sortedNotifications = notifications.sort(
      (a, b) => new Date(b.createdAt) - new Date(a.createdAt)
    );

    res.status(200).json({
      status: true,
      success: "Notifications retrieved successfully",
      notifications: sortedNotifications,
    });
  } catch (err) {
    console.log("---> err in getNotifications -->", err);
    next(err);
  }
};

// Mark notification as read
exports.markNotificationAsRead = async (req, res, next) => {
  try {
    const userId = req.userId;
    const { notificationId } = req.params;

    await UserServices.markNotificationAsRead(userId, notificationId);

    res.status(200).json({
      status: true,
      success: "Notification marked as read",
    });
  } catch (err) {
    console.log("---> err in markNotificationAsRead -->", err);
    if (err.message === "Notification not found") {
      return res.status(404).json({
        status: false,
        message: "Notification not found",
      });
    }
    next(err);
  }
};

// Mark all notifications as read
exports.markAllNotificationsAsRead = async (req, res, next) => {
  try {
    const userId = req.userId;

    await UserServices.markAllNotificationsAsRead(userId);

    res.status(200).json({
      status: true,
      success: "All notifications marked as read",
    });
  } catch (err) {
    console.log("---> err in markAllNotificationsAsRead -->", err);
    next(err);
  }
};

// Delete all notifications
exports.deleteAllNotifications = async (req, res, next) => {
  try {
    const userId = req.userId;

    await UserServices.deleteAllNotifications(userId);

    res.status(200).json({
      status: true,
      success: "All notifications deleted successfully",
    });
  } catch (err) {
    console.log("---> err in deleteAllNotifications -->", err);
    next(err);
  }
};

// Test notification endpoint
exports.sendTestNotification = async (req, res, next) => {
  try {
    const userId = req.userId;
    const { message = "This is a test notification!" } = req.body;

    // Get user data
    const user = await UserServices.checkUserById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: "User not found",
      });
    }

    const testResult = await sendNotification({
      userId: user.userId,
      type: "test",
      title: "Test Notification 🔔",
      message: message,
      data: {
        userId: userId,
        timestamp: new Date().toISOString(),
      },
    });

    if (testResult.pushSent || testResult.databaseSaved) {
      res.status(200).json({
        status: true,
        success: "Test notification sent successfully",
        result: testResult,
      });
    } else {
      res.status(400).json({
        status: false,
        message: "Failed to send test notification",
        errors: testResult.errors,
      });
    }
  } catch (err) {
    console.log("---> err in sendTestNotification -->", err);
    res.status(500).json({
      status: false,
      message: "Internal server error",
      error: err.message,
    });
  }
};

// Function to send missed notifications to volunteers
async function sendMissedNotifications(user) {
  try {
    const QuestionModel = require("../models/Questions");
    const AnswerModel = require("../models/Answers");

    // Get volunteer's last answer time
    const lastAnswer = await AnswerModel.findOne({
      answeredBy: user.userId,
    })
      .sort({ createdAt: -1 })
      .lean();

    // Check for questions from the last 7 days
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

    // If volunteer answered recently, no need for missed notifications
    if (lastAnswer && lastAnswer.createdAt > oneWeekAgo) {
      return;
    }

    // Find questions that were asked while volunteer was inactive
    const missedQuestions = await QuestionModel.find({
      createdAt: { $gte: oneWeekAgo },
    })
      .sort({ createdAt: -1 })
      .limit(5)
      .lean();

    if (missedQuestions.length > 0) {
      // Send individual notifications for each missed question using the service
      for (const question of missedQuestions) {
        await sendNotification({
          userId: user.userId,
          type: "new_question",
          title: "New Question Available",
          message: `A new question about "${
            question.category
          }" was asked: "${question.text.substring(0, 50)}..."`,
          data: {
            questionId: question.questionId,
            category: question.category,
          },
          saveToDatabase: true,
        });
      }

      // Send summary notification
      const summaryResult = await sendNotification({
        userId: user.userId,
        type: "missed_questions_summary",
        title: "You have missed questions! 📚",
        message: `While you were away, ${missedQuestions.length} new questions were asked. Check your notifications!`,
        data: {
          count: missedQuestions.length,
          userId: user.userId,
        },
        saveToDatabase: true,
      });

      console.log(
        "Missed questions notifications sent to volunteer:",
        summaryResult
      );
    }
  } catch (error) {
    console.log("Failed to send missed notifications:", error);
  }
}

// Export the sendMissedNotifications function for use in other controllers
exports.sendMissedNotifications = sendMissedNotifications;
