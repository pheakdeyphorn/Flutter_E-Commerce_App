const express = require("express");
const router = express.Router();
const promotionController = require("../controllers/promotionController");

router.get("/active", promotionController.getActivePromotions);

module.exports = router;
