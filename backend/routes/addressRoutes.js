const express = require("express");
const router = express.Router();
const addressController = require("../controllers/addressController");

router.post("/", addressController.addAddress);
router.get("/user/:userId", addressController.getUserAddresses);

module.exports = router;
