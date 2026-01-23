import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/task.dart';
import '../blocs/home_bloc.dart';

class AddTaskScreen extends StatefulWidget {
  final VoidCallback? onTaskAdded;

  const AddTaskScreen({super.key, this.onTaskAdded});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Manual Input Controllers
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _subjectController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _saveManualTask() async {
    if (_formKey.currentState!.validate()) {
      try {
        final task = Task()
          ..title = _questionController.text
          ..description = _answerController.text
          ..subject = _subjectController.text.isNotEmpty ? _subjectController.text : 'General'
          ..createdAt = DateTime.now()
          ..lastReviewedAt = DateTime.now();
        task.repetitionStep = 0;
        task.stage = TaskStage.learning;
        task.mistakeCount = 0;
        task.reviewCount = 0;
        task.nextReviewDate = task.getNextReviewDate();
        
        // Services before async gap
        final homeBloc = context.read<HomeBloc>();
        
        // Use HomeBloc to add the task which handles saving and reloading
        homeBloc.add(AddTask(task));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task added successfully!'), backgroundColor: Colors.green),
          );
          _questionController.clear();
          _answerController.clear();
          widget.onTaskAdded?.call();
          // Optional: Navigate back or keep open for more additions
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding task: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Add New Task', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _subjectController,
                label: 'Subject (Optional)',
                icon: Icons.category,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _questionController,
                label: 'Question / Front',
                icon: Icons.help_outline,
                maxLines: 3,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _answerController,
                label: 'Answer / Back',
                icon: Icons.lightbulb_outline,
                maxLines: 3,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveManualTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Card', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

