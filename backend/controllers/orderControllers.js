const Order = require("../models/Order");
const Product = require("../models/Product");
const User = require("../models/User");
const Payment = require("../models/Payment"); // បន្ថែមនេះ
const Notification = require("../models/Notification"); // បន្ថែមនេះ
const mongoose = require("mongoose");

exports.processCheckout = async (req, res) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const { user_id, items, total_price } = req.body;

    // 1. ឆែក User និងសមតុល្យទឹកប្រាក់
    const user = await User.findById(user_id).session(session);
    if (!user) throw new Error("User not found");
    if (user.wallet_balance < total_price) {
      throw new Error("Insufficient wallet balance. Please top up.");
    }

    // 2. កាត់ស្តុកទំនិញ
    for (const item of items) {
      const product = await Product.findById(item.product_id).session(session);
      if (!product) throw new Error(`Product ${item.product_id} not found`);
      if (product.stock_count < item.quantity) {
        throw new Error(`Not enough stock for ${product.name}`);
      }
      product.stock_count -= item.quantity;
      await product.save({ session });
    }

    // 3. កាត់លុយពី Wallet
    user.wallet_balance -= total_price;
    await user.save({ session });

    // 4. បង្កើត Order
    const newOrder = new Order({
      user_id,
      items,
      total_price,
      status: "Success",
    });
    await newOrder.save({ session });

    // --- ចំណុចបន្ថែមថ្មីសម្រាប់ V2 ---

    // 5. បង្កើត Payment Record ស្វ័យប្រវត្តិ
    const newPayment = new Payment({
      order_id: newOrder._id,
      amount: total_price,
      payment_method: "Wallet",
      status: "Completed",
    });
    await newPayment.save({ session });

    // 6. បង្កើត Notification ជូនដំណឹងទៅ User
    const newNotification = new Notification({
      user_id: user_id,
      title: "Order Successful",
      message: `Your order #${newOrder._id.toString().slice(-6)} has been placed successfully!`,
    });
    await newNotification.save({ session });

    // ----------------------------

    await session.commitTransaction();
    session.endSession();

    res.status(201).json({
      message: "Order placed successfully!",
      order: newOrder,
      remainingBalance: user.wallet_balance,
    });
  } catch (error) {
    await session.abortTransaction();
    session.endSession();
    res.status(400).json({ message: error.message });
  }
};

// Fetch orders for the Profile Screen
exports.getUserOrders = async (req, res) => {
  try {
    const orders = await Order.find({ user_id: req.params.userId })
      .populate("items.product_id")
      .sort({ createdAt: -1 });
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
