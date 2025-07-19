const express = require("express");
const router = express.Router();
const NotificationController = require("../controller/notificationcontroller.js");
const authMiddleware = require("../services/authMiddleware.js");

// Notification routes
router.get("/", authMiddleware, NotificationController.getNotifications);
router.put(
  "/:notificationId/read",
  authMiddleware,
  NotificationController.markNotificationAsRead
);
router.put(
  "/mark-all-read",
  authMiddleware,
  NotificationController.markAllNotificationsAsRead
);
router.delete(
  "/",
  authMiddleware,
  NotificationController.deleteAllNotifications
);
router.post(
  "/test",
  authMiddleware,
  NotificationController.sendTestNotification
);

module.exports = router;
