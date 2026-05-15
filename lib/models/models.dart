// ── Part ────────────────────────────────────────────────────────
class Part {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String? thumbUrl;
  final String? category;
  final int? stock;
  final String? sku;

  const Part({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.thumbUrl,
    this.category,
    this.stock,
    this.sku,
  });

  factory Part.fromJson(Map<String, dynamic> j) => Part(
    id: j['id'] ?? 0,
    name: j['name'] ?? '',
    description: j['description'] ?? '',
    price: (j['price'] ?? 0).toDouble(),
    imageUrl: j['image_url'],
    thumbUrl: j['thumb_url'],
    category: j['category'],
    stock: j['stock'],
    sku: j['sku'],
  );

  String get displayImage => thumbUrl ?? imageUrl ?? '';
  bool get inStock => (stock ?? 1) > 0;
}

// ── Course ───────────────────────────────────────────────────────
class Course {
  final int id;
  final String title;
  final String? titleEs;
  final String description;
  final String? descriptionEs;
  final double? price;
  final String? duration;
  final String? level;
  final String? imageUrl;
  final String? category;

  const Course({
    required this.id,
    required this.title,
    this.titleEs,
    required this.description,
    this.descriptionEs,
    this.price,
    this.duration,
    this.level,
    this.imageUrl,
    this.category,
  });

  factory Course.fromJson(Map<String, dynamic> j) => Course(
    id: j['id'] ?? 0,
    title: j['title'] ?? '',
    titleEs: j['title_es'],
    description: j['description'] ?? '',
    descriptionEs: j['description_es'],
    price: j['price'] != null ? (j['price']).toDouble() : null,
    duration: j['duration_weeks'] != null ? '${j['duration_weeks']} semanas' : j['schedule'],
    level: j['mode'],
    imageUrl: j['image_url'],
    category: j['mode'],
  );
}

// ── CartItem ─────────────────────────────────────────────────────
class CartItem {
  final Part part;
  int qty;

  CartItem({required this.part, this.qty = 1});

  double get subtotal => part.price * qty;
}

// ── QuoteRequest ─────────────────────────────────────────────────
class QuoteRequest {
  final String name;
  final String email;
  final String phone;
  final String message;
  final String? partName;

  const QuoteRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.message,
    this.partName,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'message': message,
    if (partName != null) 'part_name': partName,
  };
}
