const express = require("express");
const router = express.Router();
const notificationController = require("../controllers/notificationController");

router.get("/user/:userId", notificationController.getUserNotifications);
router.put("/read/:id", notificationController.markAsRead);

module.exports = router;
