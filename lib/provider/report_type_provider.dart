import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_type.dart';
import '../service/report_type_service.dart';

// State class for report types
class ReportTypeState {
  final List<ReportType> reportTypes;
  final bool isLoading;
  final String? error;

  const ReportTypeState({
    this.reportTypes = const [],
    this.isLoading = false,
    this.error,
  });

  ReportTypeState copyWith({
    List<ReportType>? reportTypes,
    bool? isLoading,
    String? error,
  }) {
    return ReportTypeState(
      reportTypes: reportTypes ?? this.reportTypes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ReportTypeNotifier extends StateNotifier<ReportTypeState> {
  ReportTypeNotifier() : super(const ReportTypeState()) {
    _loadReportTypes();
  }

  void _loadReportTypes() {
    state = state.copyWith(isLoading: true, error: null);
    
    ReportTypeService.getActiveReportTypes().listen(
      (reportTypes) => state = state.copyWith(
        reportTypes: reportTypes,
        isLoading: false,
      ),
      onError: (error) => state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      ),
    );
  }

  // Get report type by ID
  ReportType? getReportTypeById(String id) {
    try {
      return state.reportTypes.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }

  // Refresh report types
  void refresh() {
    _loadReportTypes();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Seed default report types
  Future<void> seedDefaultReportTypes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ReportTypeService.seedDefaultReportTypes();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Providers
final reportTypeProvider = StateNotifierProvider<ReportTypeNotifier, ReportTypeState>((ref) {
  return ReportTypeNotifier();
});

// Convenience providers
final reportTypesProvider = Provider<List<ReportType>>((ref) {
  return ref.watch(reportTypeProvider).reportTypes;
});

final reportTypeLoadingProvider = Provider<bool>((ref) {
  return ref.watch(reportTypeProvider).isLoading;
});

final reportTypeErrorProvider = Provider<String?>((ref) {
  return ref.watch(reportTypeProvider).error;
});

// Provider to get a specific report type by ID
final reportTypeByIdProvider = Provider.family<ReportType?, String>((ref, id) {
  final notifier = ref.read(reportTypeProvider.notifier);
  return notifier.getReportTypeById(id);
}); 