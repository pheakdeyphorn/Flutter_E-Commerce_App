const mongoose = require("mongoose");

const productSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    description: { type: String },
    price: { type: Number, required: true },
    image_url: { type: String },
    category: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Category",
      required: true,
    },
    brand: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Brand",
    },
    stock_count: { type: Number, default: 10 },
    is_trending: { type: Boolean, default: false },
    old_price: { type: Number, default: 0 },
  },
  { timestamps: true },
);

module.exports = mongoose.model("Product", productSchema);
