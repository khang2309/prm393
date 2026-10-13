import 'package:flutter/material.dart';

import '../models/task.dart';
import '../widgets/task_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Khai báo danh sách Task rỗng
  final List<Task> _tasks = [];

  // 2. Controller để lấy dữ liệu từ ô nhập
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 3. Hàm thêm Task mới từ ô nhập TextField
  void _addTask() {
    final String text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: text));
        _controller.clear(); // Xóa chữ sau khi thêm
      });
      FocusScope.of(context).unfocus(); // Ẩn bàn phím
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán số task hoàn thành
    final int completedCount = _tasks.where((t) => t.isDone).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Daily Planner - Task Manager'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Thống kê nhanh
            Text('Hoàn thành: $completedCount / ${_tasks.length}'),
            const SizedBox(height: 10),

            // Ô nhập liệu (TextField)
            TextField(
              controller: _controller,
              onSubmitted: (_) => _addTask(),
              decoration: InputDecoration(
                labelText: 'Nhập tên công việc...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTask,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Danh sách hiển thị (ListView)
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(child: Text('Chưa có công việc nào!'))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return TaskItem(
                          task: task,
                          onChanged: (bool? value) {
                            setState(() {
                              task.isDone = value!;
                            });
                          },
                          onDelete: () {
                            setState(() {
                              _tasks.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã xóa "${task.title}"'),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
