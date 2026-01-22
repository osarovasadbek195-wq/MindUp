import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/task.dart';
import '../../data/services/isar_service.dart';
import '../../data/services/import_export_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/home_bloc.dart';

class AnalyticsScreen extends StatefulWidget {
  final List<Task> allTasks;

  const AnalyticsScreen({super.key, required this.allTasks});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  ImportExportService? _importExportService;
  bool isExporting = false;
  bool isImporting = false;

  ImportExportService get importExportService {
    _importExportService ??= ImportExportService(context.read<IsarService>());
    return _importExportService!;
  }

  Future<void> _handleExportJson() async {
    setState(() => isExporting = true);
    try {
      await importExportService.exportTasksToJson();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tasks exported successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => isExporting = false);
      }
    }
  }

  Future<void> _handleExportCsv() async {
    setState(() => isExporting = true);
    try {
      await importExportService.exportTasksToCsv();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tasks exported to CSV!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV Export failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => isExporting = false);
      }
    }
  }

  Future<void> _handleImport() async {
    setState(() => isImporting = true);
    try {
      final count = await importExportService.importTasksFromJson();
      if (!mounted) return;
      
      if (count > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully imported $count tasks!'), backgroundColor: Colors.green),
        );
        // Refresh the data
        context.read<HomeBloc>().add(LoadTasks(DateTime.now()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tasks imported or file was invalid.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => isImporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Statistikani hisoblash (using new stages)
    int masterCount = widget.allTasks.where((t) => t.stage == TaskStage.mastered).length;
    int learningCount = widget.allTasks.where((t) => t.stage == TaskStage.learning).length;
    int reviewingCount = widget.allTasks.where((t) => t.stage == TaskStage.review).length;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Learning Stats"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFF4F7FF), Color(0xFFE4EBF5)], // Clean Slate Gradient
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Cards Row
                Row(
                  children: [
                    _buildStatCard(context, "Mastered", masterCount.toString(), Colors.purpleAccent, Icons.workspace_premium),
                    const SizedBox(width: 12),
                    _buildStatCard(context, "Reviewing", reviewingCount.toString(), Colors.orangeAccent, Icons.loop),
                    const SizedBox(width: 12),
                    _buildStatCard(context, "New", learningCount.toString(), Colors.blueAccent, Icons.new_releases),
                  ],
                ),
                
                const SizedBox(height: 20),

                // Import/Export Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Data Management",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isImporting ? null : _handleImport,
                              icon: isImporting 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.upload_file, size: 18),
                              label: Text(isImporting ? 'Importing...' : 'Import'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'json') {
                                  _handleExportJson();
                                } else if (value == 'csv') {
                                  _handleExportCsv();
                                }
                              },
                              child: ElevatedButton.icon(
                                onPressed: isExporting ? null : () {},
                                icon: isExporting 
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.download, size: 18),
                                label: Text(isExporting ? 'Exporting...' : 'Export'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'json',
                                  child: Row(
                                    children: [
                                      Icon(Icons.code, size: 18),
                                      SizedBox(width: 8),
                                      Text('Export as JSON'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'csv',
                                  child: Row(
                                    children: [
                                      Icon(Icons.grid_on, size: 18),
                                      SizedBox(width: 8),
                                      Text('Export as CSV'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Chart Container
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                         BoxShadow(
                           color: Colors.black.withValues(alpha: 0.03),
                           blurRadius: 20,
                           offset: const Offset(0, 10),
                         )
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Progress Distribution",
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: Colors.black87
                          ),
                        ),
                        const SizedBox(height: 30),
                        Expanded(
                          child: widget.allTasks.isEmpty 
                          ? const Center(child: Text("No data yet", style: TextStyle(color: Colors.grey)))
                          : PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  color: const Color(0xFFAB47BC), // Purple 400
                                  value: masterCount.toDouble(),
                                  title: '${((masterCount/widget.allTasks.length)*100).toInt()}%',
                                  radius: 60,
                                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFF42A5F5), // Blue 400
                                  value: learningCount.toDouble(),
                                  title: '${((learningCount/widget.allTasks.length)*100).toInt()}%',
                                  radius: 50,
                                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFFFFA726), // Orange 400
                                  value: reviewingCount.toDouble(),
                                  title: '${((reviewingCount/widget.allTasks.length)*100).toInt()}%',
                                  radius: 55,
                                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                              sectionsSpace: 4,
                              centerSpaceRadius: 50,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Legend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem(const Color(0xFFAB47BC), "Master"),
                            const SizedBox(width: 16),
                            _buildLegendItem(const Color(0xFFFFA726), "Review"),
                            const SizedBox(width: 16),
                            _buildLegendItem(const Color(0xFF42A5F5), "New"),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
