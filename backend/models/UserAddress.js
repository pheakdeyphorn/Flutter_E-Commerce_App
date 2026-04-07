const mongoose = require("mongoose");
const addressSchema = new mongoose.Schema(
  {
    user_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    address_details: { type: String, required: true },
    phone_number: { type: String, required: true },
  },
  { timestamps: true },
);
module.exports = mongoose.model("UserAddress", addressSchema);
