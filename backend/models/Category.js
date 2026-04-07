const mongoose = require("mongoose");

const categorySchema = new mongoose.Schema(
  {
    name: { type: String, required: true, unique: true },
    icon_url: { type: String }, // សម្រាប់ដាក់រូប icon តំណាងប្រភេទ
  },
  { timestamps: true },
);

module.exports = mongoose.model("Category", categorySchema);
