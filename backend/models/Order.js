const mongoose = require("mongoose");

const orderSchema = new mongoose.Schema(
  {
    user_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    items: [
      {
        product_id: { type: mongoose.Schema.Types.ObjectId, ref: "Product" },
        quantity: { type: Number, default: 1 },
        price: { type: Number },
      },
    ],
    total_price: { type: Number, required: true },
    status: { type: String, default: "Success" },
  },
  { timestamps: true },
);

module.exports = mongoose.model("Order", orderSchema);
