import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/screens/product_detail_screen.dart';
import 'package:frontend/services/api_service.dart';
import '../widgets/product_grid_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> _productsFuture;
  // 1. State variables to track the selected category
  final List<String> categories = [
    "All",
    "Keyboard",
    "Mice",
    "Audio",
    "Storage",
    "Other",
  ];
  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _productsFuture = ApiService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pheakdey Store'),
        // Note: Cart icon removed here because it is now in the bottom navigation bar
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("Connection Error: ${snapshot.error}"),
              ),
            );
          }

          if (snapshot.hasData) {
            final allProducts = snapshot.data!;

            final filteredProducts = selectedCategory == "All"
                ? allProducts
                : allProducts
                      .where((p) => p.category == selectedCategory)
                      .toList();

            // 3. Split filtered data into Trending and Regular lists
            final trendingProducts = filteredProducts
                .where((p) => p.isTrending)
                .toList();
            final regularProducts = filteredProducts
                .where((p) => !p.isTrending)
                .toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CATEGORY FILTER BAR ---
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      key: const PageStorageKey('categoryBar'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // --- TRENDING SECTION ---
                  if (trendingProducts.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Trending Now 🔥",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: trendingProducts.length,
                        itemBuilder: (context, index) {
                          final product = trendingProducts[index];
                          return SizedBox(
                            width: 160, // Boundary for horizontal cards
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetailScreen(product: product),
                                  ),
                                );
                              },
                              child: ProductGridItem(product: product),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // --- ALL PRODUCTS SECTION ---
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "All Products",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (regularProducts.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("No products found in this category."),
                      ),
                    )
                  else
                    GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shrinkWrap: true, // Needed for GridView inside Column
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: regularProducts.length,
                      itemBuilder: (context, index) {
                        final product = regularProducts[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailScreen(product: product),
                              ),
                            );
                          },
                          child: ProductGridItem(product: product),
                        );
                      },
                    ),
                ],
              ),
            );
          }
          return const Center(child: Text("No products available"));
        },
      ),
    );
  }
}
