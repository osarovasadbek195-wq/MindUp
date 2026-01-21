import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/task.dart';
import '../../data/services/isar_service.dart';
import '../../data/services/openai_service.dart';
import '../../data/services/gemini_service.dart';
import '../../core/cascade_engine.dart';
import '../../core/utils/logger.dart';

// --- Events ---
abstract class HomeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadTasks extends HomeEvent {
  final DateTime date;
  LoadTasks(this.date);
}

class AddSmartTask extends HomeEvent {
  final String prompt;
  final String subject;
  AddSmartTask(this.prompt, this.subject);
}

class CompleteTask extends HomeEvent {
  final Task task;
  final bool isSuccess; // To'g'ri topdimi yoki yo'q?
  CompleteTask(this.task, this.isSuccess);
}

// --- States ---
abstract class HomeState extends Equatable {
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final List<Task> tasks;
  final DateTime selectedDate;
  
  HomeLoaded(this.tasks, this.selectedDate);
  
  @override
  List<Object> get props => [tasks, selectedDate];
}
class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

// --- Bloc ---
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final IsarService isarService;
  final OpenAIService? openAIService;
  final GeminiService? geminiService;

  HomeBloc({
    required this.isarService,
    this.openAIService,
    this.geminiService,
  }) : super(HomeInitial()) {
    
    on<LoadTasks>((event, emit) async {
      emit(HomeLoading());
      try {
        final tasks = await isarService.getTasksForDate(event.date);
        emit(HomeLoaded(tasks, event.date));
      } catch (e) {
        AppLogger.error("Vazifalarni yuklashda xatolik", error: e);
        emit(HomeError("Vazifalarni yuklashda xatolik: $e"));
      }
    });

    on<AddSmartTask>((event, emit) async {
      final currentState = state;
      if (currentState is HomeLoaded) {
        emit(HomeLoading());
        try {
          List<Task> newTasks = [];
          
          // 1. AI dan vazifalarni olish
          // Avval Gemini ni sinab ko'ramiz (bepul va tezroq bo'lishi mumkin)
          if (geminiService != null) {
             try {
               newTasks = await geminiService!.generateTasks(event.prompt, event.subject);
             } catch (e) {
               AppLogger.warning("Gemini ishlamadi, OpenAI ga o'tilmoqda: $e");
               if (openAIService != null) {
                 newTasks = await openAIService!.generateTasks(event.prompt, event.subject);
               } else {
                 throw e;
               }
             }
          } else if (openAIService != null) {
             newTasks = await openAIService!.generateTasks(event.prompt, event.subject);
          } else {
            throw Exception("AI xizmatlari mavjud emas");
          }
          
          // 2. Bazaga saqlash
          await isarService.saveTasks(newTasks);
          
          // 3. Qayta yuklash
          add(LoadTasks(currentState.selectedDate)); 
        } catch (e) {
          AppLogger.error("AI xatosi", error: e);
          emit(HomeError("AI xatosi: $e"));
          // Xatodan keyin qayta yuklashga urinib ko'ramiz
          add(LoadTasks(currentState.selectedDate));
        }
      }
    });

    on<CompleteTask>((event, emit) async {
      final currentState = state;
      if (currentState is HomeLoaded) {
        try {
          // 1. Yangi muddatni hisoblash
          final updatedTask = CascadeEngine.processReview(event.task, event.isSuccess);
          
          // 2. Bazaga saqlash
          await isarService.saveTask(updatedTask);
          
          // 3. Ro'yxatni yangilash
          add(LoadTasks(currentState.selectedDate));
        } catch (e) {
          AppLogger.error("Vazifani yangilashda xatolik", error: e);
          emit(HomeError("Vazifani yangilashda xatolik: $e"));
        }
      }
    });
  }
}
