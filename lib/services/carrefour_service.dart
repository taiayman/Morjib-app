import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'dart:async';
import 'dart:math';

class CarrefourService {
  final int maxRetries = 3;
  final Duration retryDelay = Duration(seconds: 2);

  Future<List<Category>> getCarrefourCategories(String location) async {
    final url = 'https://glovoapp.com/ma/en/$location/carrefour-market-cas-global/';
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        print('Fetching Carrefour categories from: $url');
        final response = await http.get(Uri.parse(url));
        print('Response status code: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final document = parse(response.body);
          final categoryElements = document.querySelectorAll('.carousel__content__element');
          print('Found ${categoryElements.length} category elements');
          
          return categoryElements.map((element) {
            final linkElement = element.querySelector('a');
            final imageElement = element.querySelector('img.store-product-image');
            final titleElement = element.querySelector('.tile__description');

            final name = titleElement?.text.trim() ?? 'Unknown Category';
            
            // Skip categories with numbers in their titles
            if (RegExp(r'\d').hasMatch(name)) {
              return null;
            }
            
            final categoryUrl = linkElement?.attributes['href'] ?? '';
            final imageUrl = imageElement?.attributes['src'] ?? '';

            return Category(
              id: _formatId(name),
              name: name,
              url: 'https://glovoapp.com$categoryUrl',
              imageUrl: imageUrl,
              isSubcategory: false,
            );
          }).whereType<Category>().toList();  // Filter out null values
        } else {
          print('Failed to load Carrefour categories: HTTP ${response.statusCode}');
          if (attempt == maxRetries - 1) {
            throw Exception('Failed to load Carrefour categories after $maxRetries attempts: HTTP ${response.statusCode}');
          }
        }
      } catch (e) {
        print('Error fetching Carrefour categories: $e');
        if (attempt == maxRetries - 1) {
          throw Exception('Failed to load Carrefour categories after $maxRetries attempts: $e');
        }
      }

      await Future.delayed(retryDelay);
    }

    throw Exception('Failed to load Carrefour categories after $maxRetries attempts');
  }

  Future<List<Product>> getCategoryProducts(String categoryUrl) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        print('Fetching products from category URL: $categoryUrl');
        final response = await http.get(Uri.parse(categoryUrl));
        print('Response status code: ${response.statusCode}');

        if (response.statusCode == 200) {
          final document = parse(response.body);
          final productElements = document.querySelectorAll('.tile');
          print('Found ${productElements.length} product elements');

          return productElements.map((element) {
            final nameElement = element.querySelector('.tile__description span');
            final priceElement = element.querySelector('.product-price__effective');
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
              sellerId: 'carrefour',
              sellerType: 'supermarket',
              unit: '',
              popularity: numberOfRatings,
              averageRating: averageRating,
              numberOfRatings: numberOfRatings,
              url: 'https://glovoapp.com$productUrl',
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