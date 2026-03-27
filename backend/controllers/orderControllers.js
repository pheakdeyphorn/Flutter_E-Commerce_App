const Order = require("../models/Order");
const Product = require("../models/Product");
const User = require("../models/User");
const mongoose = require("mongoose");

exports.processCheckout = async (req, res) => {
  // Use a Transaction to ensure all steps succeed or all fail together
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const { user_id, items, total_price } = req.body;

    // 1. Verify User exists and check wallet balance
    const user = await User.findById(user_id).session(session);
    if (!user) {
      throw new Error("User not found");
    }

    if (user.wallet_balance < total_price) {
      throw new Error("Insufficient wallet balance. Please top up.");
    }

    // 2. Validate items and update Stock
    for (const item of items) {
      const product = await Product.findById(item.product_id).session(session);

      if (!product) {
        throw new Error(`Product with ID ${item.product_id} not found`);
      }

      if (product.stock_count < item.quantity) {
        throw new Error(
          `Not enough stock for ${product.name}. Available: ${product.stock_count}`,
        );
      }

      // Deduct stock
      product.stock_count -= item.quantity;
      await product.save({ session });
    }

    // 3. Deduct from User Wallet
    user.wallet_balance -= total_price;
    await user.save({ session });

    // 4. Create and Save the Order
    const newOrder = new Order({
      user_id,
      items, // Expects array of { product_id, quantity, price }
      total_price,
      status: "Success",
    });

    await newOrder.save({ session });

    // Commit all changes
    await session.commitTransaction();
    session.endSession();

    res.status(201).json({
      message: "Order placed successfully!",
      order: newOrder,
      remainingBalance: user.wallet_balance,
    });
  } catch (error) {
    // If anything fails, undo all database changes
    await session.abortTransaction();
    session.endSession();
    res.status(400).json({ message: error.message });
  }
};

// Fetch orders for the Profile Screen
exports.getUserOrders = async (req, res) => {
  try {
    const orders = await Order.find({ user_id: req.params.userId }).sort({
      createdAt: -1,
    }); // Newest first
    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Add this to orderControllers.js
exports.getUserBalance = async (req, res) => {
  try {
    const user = await User.findById(req.params.userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.status(200).json({ wallet_balance: user.wallet_balance });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
