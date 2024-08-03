import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/search_history_service.dart';
import '../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  String _searchQuery = '';
  List<QueryDocumentSnapshot> _searchResults = [];
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  void _loadSearchHistory() async {
    final history = await _searchHistoryService.getSearchHistory();
    setState(() {
      _searchHistory = history;
    });
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final results = await _firestoreService.searchProducts(query);
    setState(() {
      _searchResults = results;
    });

    await _searchHistoryService.addSearchQuery(query);
    _loadSearchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _performSearch(value);
              },
            ),
          ),
          if (_searchQuery.isEmpty && _searchHistory.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchHistory.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.history),
                    title: Text(_searchHistory[index]),
                    onTap: () {
                      setState(() {
                        _searchQuery = _searchHistory[index];
                      });
                      _performSearch(_searchQuery);
                    },
                  );
                },
              ),
            ),
          if (_searchQuery.isNotEmpty)
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(child: Text('No results found'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: _searchResults.length,
                      itemBuilder: (ctx, i) {
                        final product = _searchResults[i].data() as Map<String, dynamic>;
                       return ProductCard(
  id: _searchResults[i].id,
  name: product['name'] ?? 'Unknown Product',
  price: (product['price'] ?? 0).toDouble(),
  imageUrl: product['image'] ?? '',
  unit: product['unit'] ?? 'item',
  description: product['description'] ?? 'No description available',
  isFavorite: product['isFavorite'] ?? false,
  averageRating: (product['averageRating'] ?? 0).toDouble(),
);
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
