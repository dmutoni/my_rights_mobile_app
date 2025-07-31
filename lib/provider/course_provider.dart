import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_rights_mobile_app/models/category.dart';
import 'package:my_rights_mobile_app/models/chapter.dart';
import 'package:my_rights_mobile_app/models/course.dart';
import 'package:my_rights_mobile_app/models/lesson.dart';
import 'package:my_rights_mobile_app/models/quiz.dart';
import 'package:my_rights_mobile_app/models/tip.dart';
import 'package:my_rights_mobile_app/service/course_storage_service.dart';
import 'package:my_rights_mobile_app/service/firebase_service.dart';

class CourseState {
  final List<Course> courses;
  final List<Category> categories;
  final List<Tip> tips;
  final bool loading;
  final String? error;

  CourseState({
    this.courses = const [],
    this.categories = const [],
    this.tips = const [],
    this.loading = false,
    this.error,
  });

  CourseState copyWith({
    List<Course>? courses,
    List<Category>? categories,
    List<Tip>? tips,
    bool? loading,
    String? error,
  }) {
    return CourseState(
      courses: courses ?? this.courses,
      categories: categories ?? this.categories,
      tips: tips ?? this.tips,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class CourseNotifier extends StateNotifier<CourseState> {
  final Ref ref;
  CourseNotifier(this.ref) : super(CourseState()) {
    _loadCourses();
    _loadCategories();
    _loadTips();
  }

  void _loadCourses() {
    state = state.copyWith(loading: true);
    FirebaseService.getCollectionStream('courses')
        .map((snapshot) => snapshot.docs.map((doc) => Course.fromJson({...doc.data(), 'id': doc.id})).toList())
        .listen((courses) {
          state = state.copyWith(courses: courses, loading: false);
        }, onError: (error) {
          state = state.copyWith(error: error.toString(), loading: false);
        });
  }

  void _loadCategories() {
    FirebaseService.getDocumentOrdered(collection: 'categories', orderByField: 'name')
        .map((snapshot) => snapshot.docs.map((doc) => Category.fromJson({...doc.data(), 'id': doc.id})).toList())
        .listen((categories) {
          state = state.copyWith(categories: categories);
        }, onError: (error) {
          state = state.copyWith(error: error.toString());
        });
  }
  
  void _loadTips() {
    FirebaseService.getCollectionStream('tips')
        .map((snapshot) => snapshot.docs.map((doc) => Tip.fromJson({...doc.data(), 'id': doc.id})).toList())
        .listen((tips) {
          state = state.copyWith(tips: tips);
        }, onError: (error) {
          state = state.copyWith(error: error.toString());
        });
  }

  Category getCategory(String categoryId) {
    return state.categories.firstWhere((category) => category.id == categoryId);
  }
}

final coursesProvider = StateNotifierProvider<CourseNotifier, CourseState>((ref) {
  return CourseNotifier(ref);
});


final courseDetailProvider = StateProvider.family<Course?, String>((ref, courseId) {
  final courses = ref.watch(coursesProvider);
  return courses.courses.isEmpty ? null : courses.courses.firstWhere((course) => course.id == courseId);
});

// Providers with persistence
class CurrentChapterNotifier extends StateNotifier<int> {
  CurrentChapterNotifier(this.lessonId) : super(0);
  
  final String lessonId;

  void setChapter(int chapter) {
    state = chapter;
    CourseStorageService.saveCurrentChapter(lessonId, chapter);
  }

  void increment() => setChapter(state + 1);

  void decrement() => state > 0 ? setChapter(state - 1) : null;
}

final currentChapterProvider = StateNotifierProvider.family<CurrentChapterNotifier, int, String>((ref, lessonId) => CurrentChapterNotifier(lessonId));

// Initialize current chapter from storage
final currentChapterInitProvider = FutureProvider.family<int, String>((ref, lessonId) async {
  final chapter = await CourseStorageService.getCurrentChapter(lessonId);
  // Update the provider with the stored value
  ref.read(currentChapterProvider(lessonId).notifier).setChapter(chapter);
  return chapter;
});

class CurrentQuestionNotifier extends StateNotifier<int> {
  CurrentQuestionNotifier() : super(0);

  void setQuestion(int question) {
    state = question;
    CourseStorageService.saveCurrentQuestion(question);
  }

  void increment() => setQuestion(state + 1);

  void decrement() => state > 0 ? setQuestion(state - 1) : null;

  void reset() => setQuestion(0);
}

final currentQuestionProvider = StateNotifierProvider<CurrentQuestionNotifier, int>((ref) {
  return CurrentQuestionNotifier();
});

// Initialize current question from storage
final currentQuestionInitProvider = FutureProvider<int>((ref) async {
  final question = await CourseStorageService.getCurrentQuestion();
  ref.read(currentQuestionProvider.notifier).setQuestion(question);
  return question;
});

class SelectedAnswersNotifier extends StateNotifier<Map<int, int>> {
  SelectedAnswersNotifier(this.lessonId) : super({});
  
  final String lessonId;

  void setAnswer(int questionIndex, int answerIndex) {
    state = {...state, questionIndex: answerIndex};
    CourseStorageService.saveSelectedAnswers(lessonId, state);
  }

  void removeAnswer(int questionIndex) {
    final newState = Map<int, int>.from(state);
    newState.remove(questionIndex);
    state = newState;
    CourseStorageService.saveSelectedAnswers(lessonId, state);
  }

  void clearAnswers() {
    state = {};
    CourseStorageService.saveSelectedAnswers(lessonId, state);
  }

  void loadAnswers(Map<int, int> answers) {
    state = answers;
  }
}

final selectedAnswersProvider = StateNotifierProvider.family<SelectedAnswersNotifier, Map<int, int>, String>((ref, lessonId) {
  return SelectedAnswersNotifier(lessonId);
});

// Initialize selected answers from storage
final selectedAnswersInitProvider = FutureProvider.family<Map<int, int>, String>((ref, lessonId) async {
  final answers = await CourseStorageService.getSelectedAnswers(lessonId);
  ref.read(selectedAnswersProvider(lessonId).notifier).loadAnswers(answers);
  return answers;
});

class StartedLessonsNotifier extends StateNotifier<Set<String>> {
  StartedLessonsNotifier() : super({});

  void addLesson(String lessonId) {
    state = {...state, lessonId};
    CourseStorageService.saveStartedLessons(state);
  }

  void removeLesson(String lessonId) {
    final newState = Set<String>.from(state);
    newState.remove(lessonId);
    state = newState;
    CourseStorageService.saveStartedLessons(state);
  }

  void loadLessons(Set<String> lessons) {
    state = lessons;
  }

  void clearAll() {
    state = {};
    CourseStorageService.saveStartedLessons(state);
  }
}

final startedLessonsProvider = StateNotifierProvider<StartedLessonsNotifier, Set<String>>((ref) {
  return StartedLessonsNotifier();
});

// Initialize started lessons from storage
final startedLessonsInitProvider = FutureProvider<Set<String>>((ref) async {
  final lessons = await CourseStorageService.getStartedLessons();
  ref.read(startedLessonsProvider.notifier).loadLessons(lessons);
  return lessons;
});

// Helper provider to ensure all progress is loaded
final progressInitializationProvider = FutureProvider<bool>((ref) async {
  // Initialize started lessons
  await ref.read(startedLessonsInitProvider.future);
  
  // Initialize current question
  await ref.read(currentQuestionInitProvider.future);
  
  return true;
});

// Stream providers for courses by category
final coursesByCategoryProvider = StreamProvider.family<List<Course>, String>((ref, categoryId) {
  return FirebaseService.getDocumentArrayQuery(
    collection: 'courses',
    field: 'categories',
    value: categoryId,
  ).map((snapshot) =>
      snapshot.docs.map((doc) => Course.fromJson({...doc.data(), 'id': doc.id})).toList());
});

// Stream provider for lessons in a course
final courseLessonsProvider = StreamProvider.family<List<Lesson>, String>((ref, courseId) {
  return FirebaseService.getInnerDocument(collection: 'courses', docId: courseId, innerCollection: 'lessons')
      .map((snapshot) => 
          snapshot.docs.map((doc) => Lesson.fromJson({...doc.data(), 'id': doc.id})).toList());
});

// Stream provider for chapters in a lesson
final lessonChaptersProvider = StreamProvider.family<List<Chapter>, ({String courseId, String lessonId})>((ref, params) {
  return FirebaseService.getInnerDocument(collection: 'courses', docId: params.courseId, innerCollection: 'lessons', innerDocId: params.lessonId, anotherCollection: 'chapters', orderByField: 'order')
      .map((snapshot) => 
          snapshot.docs.map((doc) => Chapter.fromJson({...doc.data(), 'id': doc.id})).toList());
});

// Stream provider for quizzes in a lesson
final lessonQuizProvider = StreamProvider.family<List<Quiz>, ({String courseId, String lessonId})>((ref, params) {
  return FirebaseService.getInnerDocument(collection: 'courses', docId: params.courseId, innerCollection: 'lessons', innerDocId: params.lessonId, anotherCollection: 'quiz')
      .map((snapshot) => 
          snapshot.docs.map((doc) => Quiz.fromJson({...doc.data(), 'id': doc.id})).toList());
});

