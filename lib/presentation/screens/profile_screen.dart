import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/task.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/isar_service.dart';
import '../../data/services/import_export_service.dart';
import '../blocs/home_bloc.dart';
import 'edit_profile_screen.dart';
import 'filtered_tasks_screen.dart';

class ProfileScreen extends StatefulWidget {
  final List<Task> allTasks;

  const ProfileScreen({super.key, required this.allTasks});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ImportExportService? _importExportService;
  bool isExporting = false;
  bool isImporting = false;
  UserProfile? _userProfile;

  ImportExportService get importExportService {
    _importExportService ??= ImportExportService(context.read<IsarService>());
    return _importExportService!;
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final isarService = context.read<IsarService>();
    final profile = await isarService.getUserProfile();
    setState(() {
      _userProfile = profile;
    });
  }

  Future<void> _editProfile() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profile: _userProfile),
      ),
    );
    
    if (result != null && result is UserProfile) {
      setState(() {
        _userProfile = result;
      });
    }
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

  Future<void> _launchTelegram() async {
    final Uri url = Uri.parse('https://t.me/iultimatium');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Telegram')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Stats calculation
    int masterCount = widget.allTasks.where((t) => t.stage == TaskStage.mastered).length;
    int learningCount = widget.allTasks.where((t) => t.stage == TaskStage.learning).length;
    int reviewingCount = widget.allTasks.where((t) => t.stage == TaskStage.review).length;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFF4F7FF), Color(0xFFE4EBF5)],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<UserProfile?>(
            stream: context.read<IsarService>().listenToProfile(),
            builder: (context, snapshot) {
              final profile = snapshot.data ?? UserProfile();
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // User Info Card
                    _buildUserProfileCard(profile),
                    
                    const SizedBox(height: 20),

                    // Stats Row
                    Row(
                      children: [
                        _buildStatCard(context, "Mastered", masterCount.toString(), Colors.purpleAccent, Icons.workspace_premium, () {
                          _showFilteredTasks(TaskStage.mastered);
                        }),
                        const SizedBox(width: 12),
                        _buildStatCard(context, "Reviewing", reviewingCount.toString(), Colors.orangeAccent, Icons.loop, () {
                          _showFilteredTasks(TaskStage.review);
                        }),
                        const SizedBox(width: 12),
                        _buildStatCard(context, "New", learningCount.toString(), Colors.blueAccent, Icons.new_releases, () {
                          _showFilteredTasks(TaskStage.learning);
                        }),
                      ],
                    ),
                    
                    const SizedBox(height: 20),

                    // Data Management
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
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.upload_file, size: 18),
                                  label: Text(isImporting ? 'Importing...' : 'Import'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Icon(Icons.download, size: 18),
                                    label: Text(isExporting ? 'Exporting...' : 'Export'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem<String>(
                                      value: 'json',
                                      child: Row(
                                        children: [Icon(Icons.code, size: 18), SizedBox(width: 8), Text('Export as JSON')],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'csv',
                                      child: Row(
                                        children: [Icon(Icons.grid_on, size: 18), SizedBox(width: 8), Text('Export as CSV')],
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
                    Container(
                      height: 300,
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
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: widget.allTasks.isEmpty 
                            ? const Center(child: Text("No data yet", style: TextStyle(color: Colors.grey)))
                            : PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    color: const Color(0xFFAB47BC), // Purple
                                    value: masterCount.toDouble(),
                                    title: '${((masterCount/widget.allTasks.length)*100).toInt()}%',
                                    radius: 50,
                                    titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  PieChartSectionData(
                                    color: const Color(0xFF42A5F5), // Blue
                                    value: learningCount.toDouble(),
                                    title: '${((learningCount/widget.allTasks.length)*100).toInt()}%',
                                    radius: 40,
                                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  PieChartSectionData(
                                    color: const Color(0xFFFFA726), // Orange
                                    value: reviewingCount.toDouble(),
                                    title: '${((reviewingCount/widget.allTasks.length)*100).toInt()}%',
                                    radius: 45,
                                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
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
                    
                    const SizedBox(height: 30),
                    
                    // Developer Credit
                    InkWell(
                      onTap: _launchTelegram,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Loyiha Asadbek O'sarov tomonidan ishlab chiqarilgan",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "@iultimatium",
                              style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildUserProfileCard(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userProfile?.name ?? "Student",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Level ${profile.level}",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: profile.totalXP / 1000, // Example normalization
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Text(
                  "${profile.totalXP} XP",
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ],
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

  Widget _buildStatCard(BuildContext context, String title, String value, Color color, IconData icon, VoidCallback? onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 110,
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
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilteredTasks(TaskStage stage) {
    final filteredTasks = widget.allTasks.where((t) => t.stage == stage).toList();
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FilteredTasksScreen(
          tasks: filteredTasks,
          stage: stage,
        ),
      ),
    );
  }
}
