import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import '../models/restaurant.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'dart:async';
import 'dart:math';

class MarjaneService {
  final int maxRetries = 3;
  final Duration retryDelay = Duration(seconds: 2);

  Future<List<Category>> getMarjaneCategories(String location) async {
    final url = 'https://glovoapp.com/ma/en/$location/marjane/';
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        print('Fetching Marjane categories from: $url');
        final response = await http.get(Uri.parse(url));
        print('Response status code: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final document = parse(response.body);
          final categoryElements = document.querySelectorAll('.tile');
          print('Found ${categoryElements.length} category elements');
          
          return categoryElements.map((element) {
            final nameElement = element.querySelector('[data-test-id="title"]');
            final linkElement = element.querySelector('a');
            final imageElement = element.querySelector('img');

            final name = nameElement?.text.trim() ?? 'Unknown Category';
            final categoryUrl = linkElement?.attributes['href'] ?? '';
            final imageUrl = imageElement?.attributes['src'] ?? '';

            return Category(
              id: _formatId(name),
              name: name,
              url: 'https://glovoapp.com$categoryUrl',
              imageUrl: imageUrl,
              isSubcategory: false,
            );
          }).toList();
        } else {
          print('Failed to load Marjane categories: HTTP ${response.statusCode}');
          if (attempt == maxRetries - 1) {
            throw Exception('Failed to load Marjane categories after $maxRetries attempts: HTTP ${response.statusCode}');
          }
        }
      } catch (e) {
        print('Error fetching Marjane categories: $e');
        if (attempt == maxRetries - 1) {
          throw Exception('Failed to load Marjane categories after $maxRetries attempts: $e');
        }
      }

      await Future.delayed(retryDelay);
    }

    throw Exception('Failed to load Marjane categories after $maxRetries attempts');
  }

  Future<List<Product>> getCategoryProducts(String categoryUrl) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        print('Fetching products from category URL: $categoryUrl');
        final response = await http.get(Uri.parse(categoryUrl));
        print('Response status code: ${response.statusCode}');

        if (response.statusCode == 200) {
          final document = parse(response.body);
          final productElements = document.querySelectorAll('[data-test-id="grid-elements"] .tile');
          print('Found ${productElements.length} product elements');

          return productElements.map((element) {
            final nameElement = element.querySelector('[data-test-id="tile__highlighter"] span');
            final priceElement = element.querySelector('[data-test-id="product-price-effective"]');
            final imageElement = element.querySelector('img.tile__image');
            final productLinkElement = element.querySelector('a');

            final name = nameElement?.text.trim() ?? 'Unknown Product';
            final priceText = priceElement?.text.replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.') ?? '0';
            final price = double.tryParse(priceText) ?? 0.0;
            final imageUrl = imageElement?.attributes['src'] ?? '';
            final productUrl = productLinkElement?.attributes['href'] ?? '';

            // Generate consistent rating and number of ratings based on product name
            final averageRating = _generateConsistentRating(name);
            final numberOfRatings = _generateConsistentNumberOfRatings(name);

            return Product(
              id: _formatId(name),
              name: name,
              description: '',
              price: price,
              imageUrl: imageUrl,
              category: '',
              sellerId: 'marjane',
              sellerType: 'supermarket',
              unit: '',
              popularity: numberOfRatings,
              averageRating: averageRating,
              numberOfRatings: numberOfRatings,
              url: productUrl,
            );
          }).toList();
        } else {
          print('Failed to load category products: HTTP ${response.statusCode}');
          if (attempt == maxRetries - 1) {
            throw Exception('Failed to load category products after $maxRetries attempts: HTTP ${response.statusCode}');
          }
        }
      } catch (e) {
        print('Error fetching category products: $e');
        if (attempt == maxRetries - 1) {
          throw Exception('Failed to load category products after $maxRetries attempts: $e');
        }
      }

      await Future.delayed(retryDelay);
    }

    throw Exception('Failed to load category products after $maxRetries attempts');
  }

  String _formatId(String id) {
    return id.toLowerCase()
             .trim()
             .replaceAll(RegExp(r'\s+'), '-')
             .replaceAll(RegExp(r'[^\w\-]'), '');
  }

  double _generateConsistentRating(String productName) {
    final random = Random(_generateSeedFromString(productName));
    // Generate a random good rating between 4.0 and 5.0
    return 4.0 + random.nextDouble();
  }

  int _generateConsistentNumberOfRatings(String productName) {
    final random = Random(_generateSeedFromString(productName));
    // Generate a random number of ratings between 50 and 500
    return 50 + random.nextInt(451);
  }

  int _generateSeedFromString(String input) {
    return input.codeUnits.fold(0, (prev, curr) => prev + curr);
  }
}