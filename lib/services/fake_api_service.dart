import '../models/item.dart';

class FakeApiService {
  static Future<List<Item>> fetchItems() async {
    // ignore: avoid_print
    print('🟡 1. BẮT ĐẦU gọi fetchItems');

    await Future.delayed(const Duration(seconds: 2));

    // ignore: avoid_print
    print('🟢 2. SAU khi Future.delayed xong');

    return const [
      Item(name: 'Táo', price: 10000),
      Item(name: 'Cam', price: 15000),
      Item(name: 'Chuối', price: 8000),
    ];
  }
}
