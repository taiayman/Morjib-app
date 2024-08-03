import '../models/product.dart';

class MockDataService {
  List<Product> getFakeProducts() {
    return List.generate(
      10,
      (index) => Product(
        id: 'product_$index',
        name: 'Product $index',
        description: 'Description for product $index',
        price: (index + 1) * 10.0,
        imageUrl: 'https://tse2.mm.bing.net/th?id=OIP.AyMPFLnEFrpVus--j2IxYQHaI4&pid=Api&P=0&h=180',
        category: 'Category $index',
        sellerId: 'seller_$index',
        sellerType: 'mock_seller',
        unit: 'Unit $index',
        popularity: index,
      ),
    );
  }
}
