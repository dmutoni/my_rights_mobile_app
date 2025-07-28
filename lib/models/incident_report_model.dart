import 'package:cloud_firestore/cloud_firestore.dart';

enum IncidentStatus {
  submitted,
  underReview,
  resolved,
  closed }

enum ReportPriority { low, medium, high, urgent }

class EvidenceItem {
  final String type; // photo, document, video, audio
  final String url;
  final String description;

  const EvidenceItem({
    required this.type,
    required this.url,
    required this.description,
  });

  factory EvidenceItem.fromJson(Map<String, dynamic> json) {
    return EvidenceItem(
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
      'description': description,
    };
  }
}

class ReportUpdate {
  final DateTime timestamp;
  final String message;
  final String author;

  const ReportUpdate({
    required this.timestamp,
    required this.message,
    required this.author,
  });

  factory ReportUpdate.fromJson(Map<String, dynamic> json) {
    return ReportUpdate(
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      message: json['message'] ?? '',
      author: json['author'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'message': message,
      'author': author,
    };
  }
}

class IncidentReport {
  final String id;
  final String userId;
  final String
      reportType; // corruption, human_rights_violation, discrimination, abuse_of_power, other
  final String title;
  final String description;
  final String location;
  final DateTime incidentDate;
  final DateTime submittedAt;
  final IncidentStatus status;
  final ReportPriority priority;
  final String trackingNumber;
  final bool isAnonymous;
  final List<EvidenceItem> evidence;
  final String? assignedTo;
  final List<ReportUpdate> updates;

  const IncidentReport({
    required this.id,
    required this.userId,
    required this.reportType,
    required this.title,
    required this.description,
    required this.location,
    required this.incidentDate,
    required this.submittedAt,
    this.status = IncidentStatus.submitted,
    this.priority = ReportPriority.medium,
    required this.trackingNumber,
    required this.isAnonymous,
    this.evidence = const [],
    this.assignedTo,
    this.updates = const [],
  });

  // Create a new incident report
  factory IncidentReport.create({
    required String userId,
    required String reportType,
    required String title,
    required String description,
    required String location,
    required DateTime incidentDate,
    required bool isAnonymous,
  }) {
    final now = DateTime.now();
    final trackingNumber = 'RW${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(7)}';
    
    return IncidentReport(
      id: '', // Will be set by Firestore
      userId: userId,
      reportType: reportType,
      title: title,
      description: description,
      location: location,
      incidentDate: incidentDate,
      submittedAt: now,
      isAnonymous: isAnonymous,
      trackingNumber: trackingNumber,
    );
  }

  // Create from Firestore document
  factory IncidentReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IncidentReport(
      id: doc.id,
      userId: data['userId'] ?? '',
      reportType: data['reportType'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      incidentDate: (data['incidentDate'] as Timestamp).toDate(),
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      status: IncidentStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'submitted'),
        orElse: () => IncidentStatus.submitted,
      ),
      priority: ReportPriority.values.firstWhere(
        (e) => e.name == (data['priority'] ?? 'medium'),
        orElse: () => ReportPriority.medium,
      ),
      trackingNumber: data['trackingNumber'] ?? '',
      isAnonymous: data['isAnonymous'] ?? false,
      evidence: (data['evidence'] as List<dynamic>? ?? [])
          .map((item) => EvidenceItem.fromJson(item))
          .toList(),
      assignedTo: data['assignedTo'],
      updates: (data['updates'] as List<dynamic>? ?? [])
          .map((item) => ReportUpdate.fromJson(item))
          .toList(),
    );
  }

  // Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'reportType': reportType,
      'title': title,
      'description': description,
      'location': location,
      'incidentDate': Timestamp.fromDate(incidentDate),
      'submittedAt': Timestamp.fromDate(submittedAt),
      'status': status.name,
      'priority': priority.name,
      'trackingNumber': trackingNumber,
      'isAnonymous': isAnonymous,
      'evidence': evidence.map((item) => item.toJson()).toList(),
      'assignedTo': assignedTo,
      'updates': updates.map((update) => update.toJson()).toList(),
    };
  }

  // Create a copy with updated fields
  IncidentReport copyWith({
    String? id,
    String? userId,
    String? reportType,
    String? title,
    String? description,
    String? location,
    DateTime? incidentDate,
    DateTime? submittedAt,
    IncidentStatus? status,
    ReportPriority? priority,
    String? trackingNumber,
    bool? isAnonymous,
    List<EvidenceItem>? evidence,
    String? assignedTo,
    List<ReportUpdate>? updates,
  }) {
    return IncidentReport(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reportType: reportType ?? this.reportType,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      incidentDate: incidentDate ?? this.incidentDate,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      evidence: evidence ?? this.evidence,
      assignedTo: assignedTo ?? this.assignedTo,
      updates: updates ?? this.updates,
    );
  }

  @override
  String toString() {
    return 'IncidentReport(id: $id, trackingNumber: $trackingNumber, status: ${status.name})';
  }
} 