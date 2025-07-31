import 'dart:io';
import 'dart:async';
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
  StreamSubscription? _reportsSubscription;

  IncidentReportNotifier(this.ref) : super(const IncidentReportState()) {
    // Initialize user reports stream when authenticated
    ref.listen(authProvider, (previous, next) {
      print(
          'Auth state changed: isAuthenticated=${next.isAuthenticated}, user=${next.user?.id}');
      if (next.isAuthenticated && next.user != null) {
        print('Initializing reports stream for user: ${next.user!.id}');
        _initUserReportsStream(next.user!.id);
      } else {
        print('Clearing reports stream - user logged out or not authenticated');
        // Clear subscription when user logs out
        _reportsSubscription?.cancel();
        state = state.copyWith(userReports: []);
      }
    });

    // Also initialize immediately if user is already authenticated
    final currentAuth = ref.read(authProvider);
    if (currentAuth.isAuthenticated && currentAuth.user != null) {
      print(
          'Initializing reports stream immediately for user: ${currentAuth.user!.id}');
      _initUserReportsStream(currentAuth.user!.id);
    }
  }

  void _initUserReportsStream(String userId) {
    print('Initializing user reports stream for user: $userId');

    // Cancel existing subscription
    _reportsSubscription?.cancel();

    print('Setting up Firestore stream for user: $userId');
    _reportsSubscription = IncidentReportService.getUserReports(userId).listen(
      (reports) {
        print('Received ${reports.length} reports for user: $userId');
        print(
            'Reports: ${reports.map((r) => '${r.title} (${r.id})').toList()}');
        state = state.copyWith(userReports: reports);
      },
      onError: (error) {
        print('Error loading user reports: $error');
        state = state.copyWith(error: error.toString());
      },
    );
    print('Stream subscription created');
  }

  // Create a new report
  Future<void> createReport({
    required String title,
    required DateTime date,
    required String location,
    required String description,
    required String reportTypeId,
    required bool isAnonymous,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = ref.read(authProvider).user;
      if (user == null) throw Exception('User not authenticated');

      print('Creating report for user: ${user.id}');
      print('Report details: title=$title, reportTypeId=$reportTypeId');

      final report = IncidentReport.create(
        userId: user.id,
        title: title,
        date: date,
        location: location,
        description: description,
        reportTypeId: reportTypeId,
        isAnonymous: isAnonymous,
      );

      print('Report created with tracking number: ${report.trackingNumber}');
      final createdReport = await IncidentReportService.createReport(report);
      print('Report saved to Firestore with ID: ${createdReport.id}');

      state = state.copyWith(
        isLoading: false,
        currentReport: createdReport,
      );
    } catch (e) {
      print('Error creating report: $e');
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
    } catch (e, stackTrace) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      print('Error uploading evidence: $e $stackTrace');
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

  // Refresh user reports
  void refreshUserReports() {
    final user = ref.read(authProvider).user;
    if (user != null) {
      _initUserReportsStream(user.id);
    }
  }

  @override
  void dispose() {
    _reportsSubscription?.cancel();
    super.dispose();
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

  // get selected report
  IncidentReport? get selectedReport {
    return state.currentReport;
  }

  // set selected report
  void setSelectedReport(IncidentReport? report) {
    state = state.copyWith(currentReport: report);
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
