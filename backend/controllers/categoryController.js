const Category = require("../models/Category");

// ១. ទាញយក Categories ទាំងអស់
exports.getAllCategories = async (req, res) => {
  try {
    const categories = await Category.find();
    res.status(200).json(categories);
  } catch (error) {
    res.status(500).json({ message: "Error fetching categories", error });
  }
};

// ២. បង្កើត Category ថ្មី (សម្រាប់ប្រើក្នុង Postman)
exports.createCategory = async (req, res) => {
  try {
    const newCategory = new Category(req.body);
    await newCategory.save();
    res.status(201).json(newCategory);
  } catch (error) {
    res.status(400).json({ message: "Error creating category", error });
  }
};
