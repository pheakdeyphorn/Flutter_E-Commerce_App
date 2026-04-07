const Wishlist = require("../models/Wishlist");

// បន្ថែម ឬដកទំនិញពី Wishlist (Toggle)
exports.toggleWishlist = async (req, res) => {
  const { user_id, product_id } = req.body;
  try {
    let wishlist = await Wishlist.findOne({ user_id });
    if (!wishlist) {
      wishlist = new Wishlist({ user_id, products: [product_id] });
    } else {
      const index = wishlist.products.indexOf(product_id);
      if (index === -1) {
        wishlist.products.push(product_id); // បើមិនទាន់មាន គឺថែម
      } else {
        wishlist.products.splice(index, 1); // បើមានហើយ គឺដកចេញ
      }
    }
    await wishlist.save();
    res.status(200).json(wishlist);
  } catch (error) {
    res.status(500).json({ message: "Wishlist error", error });
  }
};

// ទាញយក Wishlist របស់ User ម្នាក់
exports.getUserWishlist = async (req, res) => {
  try {
    const wishlist = await Wishlist.findOne({
      user_id: req.params.userId,
    }).populate("products");
    res.status(200).json(wishlist || { products: [] });
  } catch (error) {
    res.status(500).json({ message: "Error", error });
  }
};
