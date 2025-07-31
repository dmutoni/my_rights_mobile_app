import '../../service/report_type_service.dart';

class SeedData {
  static Future<void> seedReportTypes() async {
    try {
      await ReportTypeService.seedDefaultReportTypes();
    } catch (e) {
      print('Error seeding report types: $e');
    }
  }
} 