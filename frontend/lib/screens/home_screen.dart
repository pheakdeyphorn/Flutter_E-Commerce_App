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
  late Future<List<dynamic>> _categoriesFuture; // សម្រាប់ទាញ Category ពី API
  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _productsFuture = ApiService.fetchProducts();
      _categoriesFuture = ApiService.fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pheakdey Store'),
        actions: [
          IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder(
        // ចាំឱ្យទិន្នន័យទាំងពីរមកជុំគ្នា
        future: Future.wait([_productsFuture, _categoriesFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final List<Product> allProducts = snapshot.data![0];
          final List<dynamic> dynamicCategories = snapshot.data![1];

          // បង្កើតបញ្ជី Category List ថ្មី (ថែម "All" នៅខាងមុខ)
          List<String> categoryNames = ["All"];
          categoryNames.addAll(
            dynamicCategories.map((c) => c['name'].toString()),
          );

          final filteredProducts = selectedCategory == "All"
              ? allProducts
              : allProducts
                    .where((p) => p.category == selectedCategory)
                    .toList();

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
                // --- ១. DYNAMIC CATEGORY FILTER BAR ---
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    itemCount: categoryNames.length,
                    itemBuilder: (context, index) {
                      final category = categoryNames[index];
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

                // --- ២. TRENDING SECTION (FIXED OVERFLOW) ---
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
                    height:
                        280, // បង្កើនកម្ពស់ពី ២២០ ទៅ ២៨០ ដើម្បីកុំឱ្យ Overflow
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: trendingProducts.length,
                      itemBuilder: (context, index) {
                        final product = trendingProducts[index];
                        return Container(
                          width: 180, // កំណត់ទំហំ Card ឱ្យសមរម្យ
                          margin: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailScreen(product: product),
                              ),
                            ),
                            child: ProductGridItem(product: product),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // --- ៣. ALL PRODUCTS SECTION ---
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "All Products",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                if (regularProducts.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No products found."),
                    ),
                  )
                else
                  GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio:
                          0.72, // កែសម្រួល ratio ឱ្យ Card វែងបន្តិចកុំឱ្យ Overflow ក្នុង Grid
                    ),
                    itemCount: regularProducts.length,
                    itemBuilder: (context, index) {
                      final product = regularProducts[index];
                      return InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product),
                          ),
                        ),
                        child: ProductGridItem(product: product),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
