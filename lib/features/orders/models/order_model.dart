/// Represents a single item within an order
class OrderItem {
  final String listingId;
  final String title;
  final double price;
  final int quantity;

  OrderItem({
    required this.listingId,
    required this.title,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      listingId: json['listingId'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listingId': listingId,
      'title': title,
      'price': price,
      'quantity': quantity,
    };
  }

  OrderItem copyWith({
    String? listingId,
    String? title,
    double? price,
    int? quantity,
  }) {
    return OrderItem(
      listingId: listingId ?? this.listingId,
      title: title ?? this.title,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// Represents a customer order with buyer/seller info and items
class OrderModel {
  final String? id;
  final String userId; // Buyer Firebase UID
  final String sellerId; // Seller Firebase UID
  final String status; // pending, confirmed, shipped, delivered, cancelled
  final double totalAmount;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    this.id,
    required this.userId,
    required this.sellerId,
    required this.status,
    required this.totalAmount,
    required this.items,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString(),
      userId: json['userId'] as String,
      sellerId: json['sellerId'] as String,
      status: json['status'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'sellerId': sellerId,
      'status': status,
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? sellerId,
    String? status,
    double? totalAmount,
    List<OrderItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sellerId: sellerId ?? this.sellerId,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
