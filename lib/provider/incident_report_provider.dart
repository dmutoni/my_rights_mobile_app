import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incident_report_model.dart';
import '../service/incident_report_service.dart';
import 'auth_provider.dart';

// State class for incident reports
class IncidentReportState {
  final List<IncidentReport> userReports;
  final IncidentReport? currentReport;
  final bool isLoading;
  final String? error;

  const IncidentReportState({
    this.userReports = const [],
    this.currentReport,
    this.isLoading = false,
    this.error,
  });

  IncidentReportState copyWith({
    List<IncidentReport>? userReports,
    IncidentReport? currentReport,
    bool? isLoading,
    String? error,
  }) {
    return IncidentReportState(
      userReports: userReports ?? this.userReports,
      currentReport: currentReport ?? this.currentReport,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class IncidentReportNotifier extends StateNotifier<IncidentReportState> {
  final Ref ref;

  IncidentReportNotifier(this.ref) : super(const IncidentReportState()) {
    // Initialize user reports stream when authenticated
    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated && next.user != null) {
        _initUserReportsStream(next.user!.id);
      }
    });
  }

  void _initUserReportsStream(String userId) {
    IncidentReportService.getUserReports(userId).listen(
      (reports) => state = state.copyWith(userReports: reports),
      onError: (error) => state = state.copyWith(error: error.toString()),
    );
  }

  // Create a new report
  Future<void> createReport({
    required String title,
    required DateTime date,
    required String location,
    required String description,
    required bool isAnonymous,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = ref.read(authProvider).user;
      if (user == null) throw Exception('User not authenticated');
      final report = IncidentReport.create(
        userId: user.id,
        title: title,
        date: date,
        location: location,
        description: description,
        isAnonymous: isAnonymous,
      );
      final createdReport = await IncidentReportService.createReport(report);
      state = state.copyWith(
        isLoading: false,
        currentReport: createdReport,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Upload evidence
  Future<void> uploadEvidence(String type, File file) async {
    if (state.currentReport == null) {
      throw Exception('No current report');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final url = await IncidentReportService.uploadFile(
        state.currentReport!.id,
        type,
        file,
      );

      await IncidentReportService.addEvidence(
        state.currentReport!.id,
        type,
        url,
      );

      // Update current report with new evidence
      final updatedReport =
          await IncidentReportService.getReport(state.currentReport!.id);
      state = state.copyWith(
        isLoading: false,
        currentReport: updatedReport,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Get report by tracking number
  Future<void> getReportByTracking(String trackingNumber) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final report =
          await IncidentReportService.getReportByTrackingNumber(trackingNumber);
      if (report == null) {
        throw Exception('Report not found');
      }

      state = state.copyWith(
        isLoading: false,
        currentReport: report,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Clear current report
  void clearCurrentReport() {
    state = state.copyWith(currentReport: null, error: null);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Update report status
  Future<void> updateReportStatus(String id, IncidentStatus status) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await IncidentReportService.updateReportStatus(id, status);
      final updatedReport = await IncidentReportService.getReport(id);
      state = state.copyWith(
        isLoading: false,
        currentReport: updatedReport,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Providers
final incidentReportProvider =
    StateNotifierProvider<IncidentReportNotifier, IncidentReportState>((ref) {
  return IncidentReportNotifier(ref);
});

// Convenience providers
final userReportsProvider = Provider<List<IncidentReport>>((ref) {
  return ref.watch(incidentReportProvider).userReports;
});

final currentReportProvider = Provider<IncidentReport?>((ref) {
  return ref.watch(incidentReportProvider).currentReport;
});

final reportLoadingProvider = Provider<bool>((ref) {
  return ref.watch(incidentReportProvider).isLoading;
});

final reportErrorProvider = Provider<String?>((ref) {
  return ref.watch(incidentReportProvider).error;
});
