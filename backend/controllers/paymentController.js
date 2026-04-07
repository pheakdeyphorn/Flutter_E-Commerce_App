const Payment = require("../models/Payment");

// ទាញយកប្រវត្តិបង់ប្រាក់របស់ Order ណាមួយ
exports.getPaymentByOrder = async (req, res) => {
  try {
    const payment = await Payment.findOne({
      order_id: req.params.orderId,
    }).populate("order_id");
    res.status(200).json(payment);
  } catch (error) {
    res.status(500).json({ message: "Error fetching payment", error });
  }
};

// បង្កើត Payment (ហៅចេញពី Checkout Logic ក្នុង Order Controller)
exports.createPaymentRecord = async (data) => {
  try {
    const newPayment = new Payment(data);
    return await newPayment.save();
  } catch (error) {
    console.log("Payment Record Error:", error);
  }
};
