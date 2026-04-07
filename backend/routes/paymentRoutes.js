const express = require("express");
const router = express.Router();
const paymentController = require("../controllers/paymentController");

router.get("/order/:orderId", paymentController.getPaymentByOrder);

module.exports = router;
