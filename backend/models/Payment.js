const mongoose = require("mongoose");
const paymentSchema = new mongoose.Schema(
  {
    order_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Order",
      required: true,
    },
    amount: { type: Number, required: true },
    payment_method: { type: String, default: "Wallet" },
    status: { type: String, default: "Completed" },
  },
  { timestamps: true },
);
module.exports = mongoose.model("Payment", paymentSchema);
