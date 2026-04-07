const UserAddress = require("../models/UserAddress");

exports.addAddress = async (req, res) => {
  try {
    const newAddress = new UserAddress(req.body);
    await newAddress.save();
    res.status(201).json(newAddress);
  } catch (error) {
    res.status(400).json({ message: "Error", error });
  }
};

exports.getUserAddresses = async (req, res) => {
  try {
    const addresses = await UserAddress.find({ user_id: req.params.userId });
    res.status(200).json(addresses);
  } catch (error) {
    res.status(500).json({ message: "Error", error });
  }
};
