import 'package:flutter/material.dart';

import 'models/product.dart';
import 'services/product_service.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: QuickShopPage(),
  ));
}

class QuickShopPage extends StatelessWidget {
  QuickShopPage({super.key});

  final ProductService _service = ProductService();

  @override
  Widget build(BuildContext context) {
    // UI chỉ nhận KẾT QUẢ ĐÃ LỌC
    final List<Product> products = _service.filterByMaxPrice(100);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Shop - Sản phẩm giá rẻ (< 100\$)'),
      ),
      body: ListView(
        children: products.map((product) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: Text(product.name),
              subtitle: Text('\$${product.price}'),
              trailing: const Icon(Icons.add_shopping_cart),
              // UI chỉ GỌI logic
              onTap: () {
                _service.handleAddToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã chọn mua: ${product.name} - Giá tiền: \$${product.price}',
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
