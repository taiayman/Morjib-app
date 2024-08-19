class CustomizationGroup {
  final String id;
  final String title;
  final String subtitle;
  final List<CustomizationOption> options;

  CustomizationGroup({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.options,
  });
}

class CustomizationOption {
  final String id;
  final String name;
  final double price;
  bool isSelected;

  CustomizationOption({
    required this.id,
    required this.name,
    required this.price,
    this.isSelected = false,
  });
}