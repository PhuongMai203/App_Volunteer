class Category {
  final int id;
  final String name;
  final int? iconCode;

  Category({
    required this.id,
    required this.name,
    this.iconCode,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      name: map['name'] ?? '',
      iconCode: map['icon'] != null
          ? (map['icon'] is int
          ? map['icon']
          : int.tryParse(map['icon'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': iconCode,
    };
  }
}
