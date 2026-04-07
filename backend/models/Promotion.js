const mongoose = require("mongoose");
const promotionSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    image_url: { type: String, required: true },
    discount_code: { type: String },
    is_active: { type: Boolean, default: true },
  },
  { timestamps: true },
);
module.exports = mongoose.model("Promotion", promotionSchema);
