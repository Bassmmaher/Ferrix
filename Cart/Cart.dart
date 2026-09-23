// ==================== 1. PRODUCT MODEL ====================
class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String category;
  int stock;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.category,
    required this.stock,
  });

  @override
  String toString() =>
      '$name ($brand) - \$${price.toStringAsFixed(2)} [${category}]';
}

// ==================== 2. CART ITEM MODEL ====================
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;

  @override
  String toString() =>
      '${product.name} x$quantity = \$${subtotal.toStringAsFixed(2)}';
}

// ==================== 3. SHOPPING CART ====================
class ShoppingCart {
  final String userId;
  final List<CartItem> _items = [];
  double _taxRate = 0.14; // 14% tax
  double _discount = 0.0;

  ShoppingCart({required this.userId});

  List<CartItem> get items => List.unmodifiable(_items);

  void addProduct(Product product, [int quantity = 1]) {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be greater than 0');
    }
    if (product.stock < quantity) {
      throw Exception('Not enough stock for ${product.name}');
    }

    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      final existing = _items[existingIndex];
      final newQty = existing.quantity + quantity;
      if (newQty > product.stock) {
        throw Exception('Cannot add more. Only ${product.stock} in stock.');
      }
      existing.quantity = newQty;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
  }

  void removeProduct(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index == -1) throw Exception('Product not found in cart');

    final item = _items[index];
    if (quantity > item.product.stock) {
      throw Exception('Only ${item.product.stock} available');
    }
    item.quantity = quantity;
  }

  void clear() => _items.clear();

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get discountAmount => subtotal * _discount;
  double get taxableAmount => subtotal - discountAmount;
  double get tax => taxableAmount * _taxRate;
  double get total => taxableAmount + tax;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  void applyDiscount(double discount) {
    if (discount < 0 || discount > 1) {
      throw ArgumentError('Discount must be between 0 and 1');
    }
    _discount = discount;
  }

  Order checkout() {
    if (_items.isEmpty) {
      throw Exception('Cart is empty');
    }

    for (final item in _items) {
      item.product.stock -= item.quantity;
    }

    final order = Order(
      orderId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      items: List.from(_items),
      subtotal: subtotal,
      discount: discountAmount,
      tax: tax,
      total: total,
      createdAt: DateTime.now(),
    );

    clear();
    return order;
  }

  void printCart() {
    print('\n=== Shopping Cart ($userId) ===');
    if (_items.isEmpty) {
      print('Cart is empty.');
      return;
    }
    for (final item in _items) {
      print('  • $item');
    }
    print('--------------------------------');
    print('Subtotal : \$${subtotal.toStringAsFixed(2)}');
    if (_discount > 0) {
      print('Discount : -\$${discountAmount.toStringAsFixed(2)}');
    }
    print('Tax      : \$${tax.toStringAsFixed(2)}');
    print('TOTAL    : \$${total.toStringAsFixed(2)}');
    print('Items    : $itemCount\n');
  }
}

// ==================== 4. ORDER MODEL ====================
class Order {
  final String orderId;
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final DateTime createdAt;

  Order({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.createdAt,
  });

  void printReceipt() {
    print('\n========== RECEIPT ==========');
    print('Order ID : $orderId');
    print('User     : $userId');
    print('Date     : $createdAt');
    print('-----------------------------');
    for (final item in items) {
      print('${item.product.name} x${item.quantity} '
          '\$${item.subtotal.toStringAsFixed(2)}');
    }
    print('-----------------------------');
    print('Subtotal : \$${subtotal.toStringAsFixed(2)}');
    print('Discount : \$${discount.toStringAsFixed(2)}');
    print('Tax      : \$${tax.toStringAsFixed(2)}');
    print('TOTAL    : \$${total.toStringAsFixed(2)}');
    print('=============================\n');
  }
}

// ==================== 5. MAIN FUNCTION ====================
void main() {
  // Sample products
  final iPhone = Product(
    id: 'P001',
    name: 'iPhone 15 Pro',
    brand: 'Apple',
    price: 999.99,
    category: 'Smartphone',
    stock: 10,
  );

  final macbook = Product(
    id: 'P002',
    name: 'MacBook Air M3',
    brand: 'Apple',
    price: 1299.00,
    category: 'Laptop',
    stock: 5,
  );

  final headphones = Product(
    id: 'P003',
    name: 'Sony WH-1000XM5',
    brand: 'Sony',
    price: 349.99,
    category: 'Headphones',
    stock: 20,
  );

  // Create cart for a user
  final cart = ShoppingCart(userId: 'USER-101');

  // Add products
  cart.addProduct(iPhone, 1);
  cart.addProduct(macbook, 2);
  cart.addProduct(headphones, 1);

  // Update quantity
  cart.updateQuantity('P001', 2);

  // Apply 10% discount
  cart.applyDiscount(0.10);

  // Show cart
  cart.printCart();

  // Checkout
  final order = cart.checkout();
  order.printReceipt();

  // Verify stock decreased
  print('iPhone stock left: ${iPhone.stock}');
}