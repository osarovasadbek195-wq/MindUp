import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/services/isar_service.dart';
import '../../data/models/task.dart';

class ImportExportService {
  final IsarService isarService;

  ImportExportService(this.isarService);

  /// Export all tasks to a JSON file and share it
  Future<void> exportTasksToJson() async {
    try {
      final tasks = await isarService.getAllTasks();
      
      // Convert tasks to a list of maps for JSON serialization
      final List<Map<String, dynamic>> tasksJson = tasks.map((task) => {
        'title': task.title,
        'description': task.description,
        'subject': task.subject,
        'createdAt': task.createdAt.toIso8601String(),
        'nextReviewDate': task.nextReviewDate.toIso8601String(),
        'repetitionStep': task.repetitionStep,
        'reviewCount': task.reviewCount,
        'mistakeCount': task.mistakeCount,
        'stage': task.stage.name,
        'lastReviewedAt': task.lastReviewedAt?.toIso8601String(),
      }).toList();

      // Create a temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/mindup_tasks_export.json');
      await file.writeAsString(jsonEncode(tasksJson));

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'MindUp Tasks Export');

    } catch (e) {
      throw Exception('Export failed: $e');
    }
  }

  /// Import tasks from a selected JSON file
  Future<int> importTasksFromJson() async {
    try {
      // Pick a file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        return 0; // No file selected
      }

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final List<dynamic> tasksJson = jsonDecode(content);

      // Parse and create Task objects
      final List<Task> tasksToImport = [];
      for (var item in tasksJson) {
        try {
          final task = Task()
            ..title = item['title']
            ..description = item['description']
            ..subject = item['subject'] ?? 'Imported'
            ..createdAt = DateTime.parse(item['createdAt'])
            ..nextReviewDate = DateTime.parse(item['nextReviewDate'])
            ..repetitionStep = item['repetitionStep'] ?? 0
            ..reviewCount = item['reviewCount'] ?? 0
            ..mistakeCount = item['mistakeCount'] ?? 0
            ..stage = TaskStage.values.firstWhere(
              (e) => e.name == item['stage'],
              orElse: () => TaskStage.learning,
            )
            ..lastReviewedAt = item['lastReviewedAt'] != null 
                ? DateTime.parse(item['lastReviewedAt']) 
                : null;

          tasksToImport.add(task);
        } catch (e) {
          // Skip invalid entries but continue with others
          print('Skipping invalid task entry: $e');
        }
      }

      // Save to database
      if (tasksToImport.isNotEmpty) {
        await isarService.saveTasks(tasksToImport);
      }

      return tasksToImport.length;

    } catch (e) {
      throw Exception('Import failed: $e');
    }
  }

  /// Export tasks to CSV format
  Future<void> exportTasksToCsv() async {
    try {
      final tasks = await isarService.getAllTasks();
      
      // CSV Header
      String csvContent = 'Title,Description,Subject,Created At,Next Review,Step,Reviews,Mistakes,Stage,Last Reviewed\n';
      
      // Add each task as a row
      for (var task in tasks) {
        final title = task.title.replaceAll(',', ';'); // Replace commas to avoid CSV issues
        final description = (task.description ?? '').replaceAll(',', ';');
        final subject = task.subject.replaceAll(',', ';');
        
        csvContent += '$title,$description,$subject,';
        csvContent += '${task.createdAt.toIso8601String()},';
        csvContent += '${task.nextReviewDate.toIso8601String()},';
        csvContent += '${task.repetitionStep},';
        csvContent += '${task.reviewCount},';
        csvContent += '${task.mistakeCount},';
        csvContent += '${task.stage.name},';
        csvContent += '${task.lastReviewedAt?.toIso8601String() ?? ''}\n';
      }

      // Create a temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/mindup_tasks_export.csv');
      await file.writeAsString(csvContent);

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'MindUp Tasks Export (CSV)');

    } catch (e) {
      throw Exception('CSV Export failed: $e');
    }
  }
}
