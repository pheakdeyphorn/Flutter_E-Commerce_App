const Notification = require("../models/Notification");

// ទាញយក Notifications ទាំងអស់របស់ User ម្នាក់
exports.getUserNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({
      user_id: req.params.userId,
    }).sort({ createdAt: -1 });
    res.status(200).json(notifications);
  } catch (error) {
    res.status(500).json({ message: "Error fetching notifications", error });
  }
};

// កំណត់ថាអានរួច (Mark as Read)
exports.markAsRead = async (req, res) => {
  try {
    await Notification.findByIdAndUpdate(req.params.id, { is_read: true });
    res.status(200).json({ message: "Marked as read" });
  } catch (error) {
    res.status(500).json({ message: "Error updating notification", error });
  }
};
