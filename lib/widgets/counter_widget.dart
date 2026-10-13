import 'package:flutter/material.dart';

class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Count: $count',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              key: const Key('decrement'),
              onPressed: count == 0
                  ? null
                  : () {
                      setState(() {
                        count--;
                      });
                    },
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              key: const Key('increment'),
              onPressed: () {
                setState(() {
                  count++;
                });
              },
              child: const Text('Increase'),
            ),
            const SizedBox(width: 8),
            TextButton(
              key: const Key('reset'),
              onPressed: () {
                setState(() {
                  count = 0;
                });
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}
