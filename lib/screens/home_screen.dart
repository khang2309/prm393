import 'package:flutter/material.dart';

import '../models/item.dart';
import '../services/fake_api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.fetcher});

  final Future<List<Item>> Function()? fetcher;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Item>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = (widget.fetcher ?? FakeApiService.fetchItems)();
  }

  void _reload() {
    setState(() {
      _itemsFuture = (widget.fetcher ?? FakeApiService.fetchItems)();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Async Product Loader'),
        actions: [
          IconButton(
            key: const Key('reload-products'),
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Item>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Có lỗi xảy ra: ${snapshot.error}'),
            );
          }

          final items = snapshot.data!;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('${item.price} VND'),
              );
            },
          );
        },
      ),
    );
  }
}
