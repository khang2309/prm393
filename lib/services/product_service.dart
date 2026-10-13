import '../data/data_source.dart';
import '../models/product.dart';

class ProductService {
  /// Lấy toàn bộ sản phẩm
  List<Product> getAllProducts() {
    return rawProducts;
  }

  /// Lấy sản phẩm giá rẻ (< 100)
  List<Product> getCheapProducts() {
    return rawProducts.where((p) => p.price < 100).toList();
  }

  /// Lọc sản phẩm theo giá tối đa
  List<Product> filterByMaxPrice(double maxPrice) {
    return rawProducts.where((product) {
      return product.price < maxPrice;
    }).toList();
  }

  /// Xử lý khi người dùng chọn sản phẩm
  void handleAddToCart(Product product) {
    // ignore: avoid_print
    print('Đã chọn mua: ${product.name}');
    // ignore: avoid_print
    print('Giá tiền: ${product.price}');
  }
}
