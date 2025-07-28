import 'package:shared_preferences/shared_preferences.dart';

class CourseStorageService {
  static const String _currentChapterKey = 'current_chapter_';
  static const String _startedLessonsKey = 'started_lessons';
  static const String _selectedAnswersKey = 'selected_answers_';
  static const String _currentQuestionKey = 'current_question';

  // Current Chapter methods
  static Future<void> saveCurrentChapter(String lessonId, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_currentChapterKey$lessonId', chapter);
  }

  static Future<int> getCurrentChapter(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_currentChapterKey$lessonId') ?? 0;
  }

  // Started Lessons methods
  static Future<void> saveStartedLessons(Set<String> lessonIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_startedLessonsKey, lessonIds.toList());
  }

  static Future<Set<String>> getStartedLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final lessons = prefs.getStringList(_startedLessonsKey) ?? [];
    return lessons.toSet();
  }
  
  // Selected Answers methods
  static Future<void> saveSelectedAnswers(String lessonId, Map<int, int> answers) async {
    final prefs = await SharedPreferences.getInstance();
    final answersList = answers.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('$_selectedAnswersKey$lessonId', answersList);
  }

  static Future<Map<int, int>> getSelectedAnswers(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    final answersList = prefs.getStringList('$_selectedAnswersKey$lessonId') ?? [];
    
    final Map<int, int> answers = {};
    for (final answer in answersList) {
      final parts = answer.split(':');
      if (parts.length == 2) {
        final questionIndex = int.tryParse(parts[0]);
        final answerIndex = int.tryParse(parts[1]);
        if (questionIndex != null && answerIndex != null) {
          answers[questionIndex] = answerIndex;
        }
      }
    }
    return answers;
  }

  // Current Question methods
  static Future<void> saveCurrentQuestion(int question) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentQuestionKey, question);
  }

  static Future<int> getCurrentQuestion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentQuestionKey) ?? 0;
  }

  // Clear progress methods
  static Future<void> clearLessonProgress(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_currentChapterKey$lessonId');
    await prefs.remove('$_selectedAnswersKey$lessonId');
    
    // Remove from started lessons
    final startedLessons = await getStartedLessons();
    startedLessons.remove(lessonId);
    await saveStartedLessons(startedLessons);
  }

  static Future<void> clearAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith(_currentChapterKey) ||
          key.startsWith(_selectedAnswersKey) ||
          key == _startedLessonsKey ||
          key == _currentQuestionKey) {
        await prefs.remove(key);
      }
    }
  }
}
