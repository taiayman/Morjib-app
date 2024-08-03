class Category {
  final String id;
  final String name;
  final String url;
  final String imageUrl;
  final bool isSubcategory;

  Category({
    required this.id,
    required this.name,
    required this.url,
    required this.imageUrl,
    this.isSubcategory = false,
  });
}