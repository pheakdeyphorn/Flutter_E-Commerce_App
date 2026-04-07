const express = require("express");
const router = express.Router();
const wishlistController = require("../controllers/wishlistController");

router.post("/toggle", wishlistController.toggleWishlist);
router.get("/user/:userId", wishlistController.getUserWishlist);

module.exports = router;
