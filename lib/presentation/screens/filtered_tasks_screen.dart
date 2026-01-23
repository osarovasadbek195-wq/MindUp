import 'package:flutter/material.dart';
import '../../data/models/task.dart';
import '../widgets/custom_webview.dart';

class FilteredTasksScreen extends StatefulWidget {
  final List<Task> tasks;
  final TaskStage stage;

  const FilteredTasksScreen({
    super.key,
    required this.tasks,
    required this.stage,
  });

  @override
  State<FilteredTasksScreen> createState() => _FilteredTasksScreenState();
}

class _FilteredTasksScreenState extends State<FilteredTasksScreen> {
  String get _title {
    switch (widget.stage) {
      case TaskStage.mastered:
        return 'Mastered Tasks';
      case TaskStage.review:
        return 'Reviewing Tasks';
      case TaskStage.learning:
        return 'New Tasks';
    }
  }

  Color get _color {
    switch (widget.stage) {
      case TaskStage.mastered:
        return Colors.purple;
      case TaskStage.review:
        return Colors.orange;
      case TaskStage.learning:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: widget.tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIcon(),
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${_title.toLowerCase()} yet',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.tasks.length,
              itemBuilder: (context, index) {
                final task = widget.tasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.description ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Subject: ${task.subject}',
                          style: TextStyle(
                            color: _color,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_circle_outline),
                      onPressed: () {
                        _showTaskInWebView(task);
                      },
                    ),
                    onTap: () {
                      _showTaskDetails(task);
                    },
                  ),
                );
              },
            ),
    );
  }

  IconData _getIcon() {
    switch (widget.stage) {
      case TaskStage.mastered:
        return Icons.workspace_premium;
      case TaskStage.review:
        return Icons.loop;
      case TaskStage.learning:
        return Icons.new_releases;
    }
  }

  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Answer: ${task.description ?? ""}'),
            const SizedBox(height: 8),
            Text('Subject: ${task.subject}'),
            const SizedBox(height: 8),
            Text('Stage: ${task.stage.name}'),
            const SizedBox(height: 8),
            Text('Reviews: ${task.reviewCount}'),
            if (task.nextReviewDate != null)
              Text('Next Review: ${_formatDate(task.nextReviewDate!)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTaskInWebView(Task task) {
    // Search for related resources
    final searchQuery = '${task.title} ${task.subject}';
    final searchUrl = 'https://www.google.com/search?q=$searchQuery';
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CustomWebView(
          url: searchUrl,
          title: 'View: ${task.title}',
          showHelpButton: true,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
