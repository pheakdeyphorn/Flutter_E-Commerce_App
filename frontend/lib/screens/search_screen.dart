import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/screens/product_detail_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/product_grid_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _allProduct = [];
  List<Product> _displayList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  //prevent memory leaks
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final products = await ApiService.fetchProducts();
      setState(() {
        _allProduct = products;
        _displayList = products;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Search error: $error');
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayList = _allProduct;
      } else {
        _displayList = _allProduct
            .where(
              (product) =>
                  product.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme; // Access current colors

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _onSearchChanged,
          // Uses the correct text color for the current AppBar theme
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Search for products',
            hintStyle: TextStyle(color: colorScheme.onSurface),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: colorScheme.onSurface),
            suffixIcon: IconButton(
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
              icon: Icon(Icons.clear, color: colorScheme.onSurface),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _displayList.isEmpty
          ? const Center(child: Text("No products found."))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: _displayList.length,
              itemBuilder: (context, index) {
                final product = _displayList[index];
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
    );
  }
}
