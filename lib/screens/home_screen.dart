import 'package:flutter/material.dart';

import '../services/counter_stream_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.stream});

  final Stream<int>? stream;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CounterStreamService? _service;
  late Stream<int> _stream;

  @override
  void initState() {
    super.initState();
    if (widget.stream == null) {
      _service = CounterStreamService()..start();
      _stream = _service!.counterStream;
    } else {
      _stream = widget.stream!;
    }
  }

  @override
  void dispose() {
    _service?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Counter Stream')),
      body: Center(
        child: StreamBuilder<int>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return const Text('Có lỗi xảy ra');
            }

            if (!snapshot.hasData) {
              return const Text('Chưa có dữ liệu');
            }

            return Text(
              'Counter: ${snapshot.data}',
              style: const TextStyle(fontSize: 32),
            );
          },
        ),
      ),
    );
  }
}
