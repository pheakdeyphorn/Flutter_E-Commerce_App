const Promotion = require("../models/Promotion");

exports.getActivePromotions = async (req, res) => {
  try {
    const promos = await Promotion.find({ is_active: true });
    res.status(200).json(promos);
  } catch (error) {
    res.status(500).json({ message: "Error", error });
  }
};
