const express = require("express");
const router = express.Router();
const orderController = require("../controllers/orderControllers");

// POST /api/orders/checkout - Process a new order
// This matches the user_id, items, and total_price structure in your model
router.post("/checkout", orderController.processCheckout);

// GET /api/orders/user/:userId - Fetch order history for a specific user
router.get("/user/:userId", orderController.getUserOrders);

router.get("/balance/:userId", orderController.getUserBalance);

module.exports = router;
