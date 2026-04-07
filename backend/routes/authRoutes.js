const express = require("express");
const router = express.Router();
const {
  registerUser,
  loginUser,
  getAllUsers,
  deleteProduct,
  getUserProfile,
  updateUserProfile,
} = require("../controllers/authController");

router.post("/register", registerUser);
router.post("/login", loginUser);
router.get("/users", getAllUsers);
router.delete("/:id", deleteProduct);
router.get("/profile/:id", getUserProfile);
router.put("/update/:id", updateUserProfile);

module.exports = router;
