import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/task.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<Task> allTasks;

  const AnalyticsScreen({super.key, required this.allTasks});

  @override
  Widget build(BuildContext context) {
    // Statistikani hisoblash
    int masterCount = allTasks.where((t) => t.stage == TaskStage.master).length;
    int learningCount = allTasks.where((t) => t.stage == TaskStage.learning).length;
    int reviewingCount = allTasks.length - masterCount - learningCount;
    
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
                
                const SizedBox(height: 40),
                
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
                          child: allTasks.isEmpty 
                          ? const Center(child: Text("No data yet", style: TextStyle(color: Colors.grey)))
                          : PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  color: const Color(0xFFAB47BC), // Purple 400
                                  value: masterCount.toDouble(),
                                  title: '${((masterCount/allTasks.length)*100).toInt()}%',
                                  radius: 60,
                                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFF42A5F5), // Blue 400
                                  value: learningCount.toDouble(),
                                  title: '${((learningCount/allTasks.length)*100).toInt()}%',
                                  radius: 50,
                                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFFFFA726), // Orange 400
                                  value: reviewingCount.toDouble(),
                                  title: '${((reviewingCount/allTasks.length)*100).toInt()}%',
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
