import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_type.dart';
import '../service/report_type_service.dart';

// Provider for active report types
final reportTypesProvider = StreamProvider<List<ReportType>>((ref) {
  return ReportTypeService.getActiveReportTypes();
});

// Provider for all report types (including inactive)
final allReportTypesProvider = StreamProvider<List<ReportType>>((ref) {
  return ReportTypeService.getAllReportTypes();
});

// Provider for getting a specific report type by ID
final reportTypeProvider = FutureProvider.family<ReportType?, String>((ref, id) {
  return ReportTypeService.getReportType(id);
});

// Provider for getting a specific report type by name
final reportTypeByNameProvider = FutureProvider.family<ReportType?, String>((ref, name) {
  return ReportTypeService.getReportTypeByName(name);
});

// State notifier for managing report type operations (admin functionality)
class ReportTypeNotifier extends StateNotifier<AsyncValue<void>> {
  ReportTypeNotifier() : super(const AsyncValue.data(null));

  // Create a new report type
  Future<ReportType?> createReportType(ReportType reportType) async {
    state = const AsyncValue.loading();
    try {
      final created = await ReportTypeService.createReportType(reportType);
      state = const AsyncValue.data(null);
      return created;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  // Update a report type
  Future<bool> updateReportType(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await ReportTypeService.updateReportType(id, data);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // Delete a report type
  Future<bool> deleteReportType(String id) async {
    state = const AsyncValue.loading();
    try {
      await ReportTypeService.deleteReportType(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // Initialize default report types
  Future<bool> initializeDefaultReportTypes() async {
    state = const AsyncValue.loading();
    try {
      await ReportTypeService.initializeDefaultReportTypes();
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}

// Provider for report type operations
final reportTypeNotifierProvider = StateNotifierProvider<ReportTypeNotifier, AsyncValue<void>>((ref) {
  return ReportTypeNotifier();
});
