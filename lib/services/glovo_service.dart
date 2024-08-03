import 'dart:convert';
import 'dart:math';

import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import '../models/restaurant.dart';
import '../models/product.dart';
import '../models/category.dart';
import 'dart:async';

class GlovoService {
  final int maxRetries = 3;
  final Duration retryDelay = Duration(seconds: 2);

  String _formatId(String id) {
    return id.toLowerCase()
             .trim()
             .replaceAll(RegExp(r'\s+'), '-')
             .replaceAll(RegExp(r'[^\w\-]'), '');
  }

  Future<List<Restaurant>> getRestaurantsForLocation(String location) async {
    final url = 'https://glovoapp.com/ma/en/$location/restaurants_1/';
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        print('Attempting to fetch restaurants from URL: $url');
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          },
        );

        if (response.statusCode == 200) {
          final document = parse(response.body);
          final restaurantCards = document.querySelectorAll('[data-test-id="store-item"]');

          if (restaurantCards.isEmpty) {
            print('No restaurant cards found on the page. HTML content: ${response.body.substring(0, 500)}...');
            throw Exception('No restaurants found on the page');
          }

          return restaurantCards.map((card) {
            final nameElement = card.querySelector('[data-test-id="store-card-title"]');
            final imageElement = card.querySelector('[data-test-id="store-image"]');
            final ratingElement = card.querySelector('[data-test-id="store-rating-label"]');
            final ratingCountElement = card.querySelector('[data-test-id="store-rating-total"]');
            final cuisineElement = card.querySelector('[data-test-id="store-filter"]');
            final discountElement = card.querySelector('.store-card-promo__title');
            final promotionElement = card.querySelector('.store-card-promo__text');
            final cocaColaDealElement = card.querySelector('.coca-cola-deal');
            final linkElement = card;

            final name = nameElement?.text.trim() ?? 'Unknown';
            final restaurantUrl = linkElement.attributes['href'] ?? '';
            
            final urlParts = restaurantUrl.split('/');
            final restaurantUrlPart = urlParts.length > 4 ? '${urlParts[3]}/${urlParts[4]}/' : '';

            return Restaurant(
              id: _formatId(name),
              name: name,
              imageUrl: imageElement?.attributes['src'] ?? '',
              rating: int.tryParse(ratingElement?.text.replaceAll('%', '').trim() ?? '0') ?? 0,
              ratingCount: int.tryParse(ratingCountElement?.text.replaceAll(RegExp(r'[()]'), '').trim() ?? '0') ?? 0,
              cuisine: cuisineElement?.text.trim() ?? 'Various',
              address: location,
              discount: int.tryParse(discountElement?.text.replaceAll(RegExp(r'[-%]'), '').trim() ?? '0') ?? 0,
              promotion: promotionElement?.text.trim() ?? '',
              estimatedDeliveryTime: 30,
              hasCocaColaDeal: cocaColaDealElement != null,
              tags: [],
              url: restaurantUrlPart,
            );
          }).toList();
        } else if (response.statusCode == 404) {
          print('Location not found: $url');
          throw Exception('Location not found. Please check the location name.');
        } else {
          print('Failed to load restaurants: HTTP ${response.statusCode}');
          if (attempt == maxRetries - 1) {
            throw Exception('Failed to load restaurants after $maxRetries attempts: HTTP ${response.statusCode}');
          }
        }
      } catch (e) {
        print('Error in getRestaurantsForLocation (attempt ${attempt + 1}): $e');
        if (attempt == maxRetries - 1) {
          throw Exception('Failed to load restaurants after $maxRetries attempts: $e');
        }
      }

      await Future.delayed(retryDelay);
    }

    throw Exception('Failed to load restaurants after $maxRetries attempts');
  }

  Future<List<dynamic>> getRestaurantDetails(String restaurantUrlPart) async {
    final fullUrl = 'https://glovoapp.com/ma/en/$restaurantUrlPart';
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        print('Attempting to fetch restaurant details from URL: $fullUrl');
        final response = await http.get(
          Uri.parse(fullUrl),
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          },
        );

        if (response.statusCode == 200) {
          final document = parse(response.body);
          
          final productElements = document.querySelectorAll('[data-test-id="product-row-content"]');
          
          if (productElements.isNotEmpty) {
            return _parseProducts(productElements);
          } else {
            final categoryElements = document.querySelectorAll('.image-full-card, .image-preview-card');
            
            if (categoryElements.isNotEmpty) {
              return _parseCategories(categoryElements, fullUrl);
            } else {
              throw Exception('No products or categories found on the page');
            }
          }
        } else if (response.statusCode == 404) {
          print('Restaurant not found: $fullUrl');
          throw Exception('Restaurant not found. Please check the restaurant URL.');
        } else {
          print('Failed to load restaurant details: HTTP ${response.statusCode}');
          if (attempt == maxRetries - 1) {
            throw Exception('Failed to load restaurant details after $maxRetries attempts: HTTP ${response.statusCode}');
          }
        }
      } catch (e) {
        print('Error in getRestaurantDetails (attempt ${attempt + 1}): $e');
        if (attempt == maxRetries - 1) {
          throw Exception('Failed to load restaurant details after $maxRetries attempts: $e');
        }
      }

      await Future.delayed(retryDelay);
    }

    throw Exception('Failed to load restaurant details after $maxRetries attempts');
  }

  List<Product> _parseProducts(List<dynamic> productElements) {
    return productElements.map((element) {
      final nameElement = element.querySelector('[data-test-id="product-row-name__highlighter"] span');
      final descriptionElement = element.querySelector('[data-test-id="product-row-description__highlighter"] span');
      final priceElement = element.querySelector('[data-test-id="product-price-effective"]');
      final imageElement = element.querySelector('.product-row__picture');

      final name = nameElement?.text.trim() ?? 'Unknown Product';
      final description = descriptionElement?.text.trim() ?? '';
      final priceText = priceElement?.text.replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.') ?? '0';
      final price = double.tryParse(priceText) ?? 0.0;
      final imageUrl = imageElement?.attributes['src'] ?? '';

      return Product(
        id: _formatId(name),
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        category: '',
        sellerId: '',
        sellerType: 'restaurant',
        unit: '',
        popularity: 0,
      );
    }).toList();
  }

  List<Category> _parseCategories(List<dynamic> categoryElements, String baseUrl) {
    print("Total category elements: ${categoryElements.length}");
    return categoryElements.map((element) {
      print("\n--- Processing new category ---");

      final linkElement = element.querySelector('a');
      final titleElement = element.querySelector('[data-test-id="image-full-card-title"]');

      final name = titleElement?.text?.trim() ?? 'Unknown Category';
      final url = linkElement?.attributes['href'] ?? '';
      
      print("Category name: $name");
      print("Category URL: $url");

      String iconSvg = _generateOrangeIcon();

      final fullUrl = Uri.parse(baseUrl).resolve(url).toString();

      return Category(
        id: _formatId(name),
        name: name,
        url: fullUrl,
        imageUrl: 'data:image/svg+xml;base64,${base64Encode(utf8.encode(iconSvg))}',
        isSubcategory: url.contains('content='),
      );
    }).toList();
  }

  String _generateOrangeIcon() {
    return '''
    <svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100">
      <circle cx="50" cy="50" r="40" fill="#FFA500" />
    </svg>
    ''';
  }

  Future<List<dynamic>> getCategoryContent(String categoryUrl) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        print('Attempting to fetch content from category URL: $categoryUrl');
        final response = await http.get(
          Uri.parse(categoryUrl),
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          },
        );

        if (response.statusCode == 200) {
          final document = parse(response.body);
          final productElements = document.querySelectorAll('[data-test-id="product-row-content"]');
          
          if (productElements.isNotEmpty) {
            return _parseProducts(productElements);
          } else {
            final subcategoryElements = document.querySelectorAll('.image-full-card, .image-preview-card');
            
            if (subcategoryElements.isNotEmpty) {
              return _parseCategories(subcategoryElements, categoryUrl);
            } else {
              throw Exception('No products or subcategories found in this category');
            }
          }
        } else if (response.statusCode == 404) {
          print('Category not found: $categoryUrl');
          throw Exception('Category not found. Please check the category URL.');
        } else {
          print('Failed to load category content: HTTP ${response.statusCode}');
          if (attempt == maxRetries - 1) {
            throw Exception('Failed to load category content after $maxRetries attempts: HTTP ${response.statusCode}');
          }
        }
      } catch (e) {
        print('Error in getCategoryContent (attempt ${attempt + 1}): $e');
        if (attempt == maxRetries - 1) {
          throw Exception('Failed to load category content after $maxRetries attempts: $e');
        }
      }

      await Future.delayed(retryDelay);
    }

    throw Exception('Failed to load category content after $maxRetries attempts');
  }

  Future<List<Restaurant>> getPopularRestaurants(String location, {int limit = 5}) async {
    List<Restaurant> allRestaurants = await getRestaurantsForLocation(location);
    
    // Sort restaurants by rating (descending order)
    allRestaurants.sort((a, b) => b.rating.compareTo(a.rating));
    
    // Add some randomness to the selection
    final random = Random();
    List<Restaurant> popularRestaurants = [];
    
    while (popularRestaurants.length < limit && allRestaurants.isNotEmpty) {
      // Select from the top half of the sorted list to ensure quality
      int index = random.nextInt(allRestaurants.length ~/ 2);
      popularRestaurants.add(allRestaurants.removeAt(index));
    }
    
    // If we still need more restaurants, just add the remaining top-rated ones
    if (popularRestaurants.length < limit) {
      popularRestaurants.addAll(allRestaurants.take(limit - popularRestaurants.length));
    }
    
    // Add a "Popular this week" tag to these restaurants
    for (var restaurant in popularRestaurants) {
      restaurant.tags.add('Popular this week');
    }
    
    return popularRestaurants;
  }

}