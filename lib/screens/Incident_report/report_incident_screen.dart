import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../shared/widgets/custom_text_fields.dart';
import '../../shared/widgets/custom_button.dart';
import '../../provider/incident_report_provider.dart';
import '../../provider/report_type_provider.dart';
import '../../provider/main_provider.dart';
import '../../shared/widgets/custom_app_bar.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../models/report_type.dart';

class ReportIncidentScreen extends ConsumerStatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  ConsumerState<ReportIncidentScreen> createState() =>
      _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends ConsumerState<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _anonymity = 'Select';
  String? _selectedReportTypeId;
  ReportType? _selectedReportType;

  final List<File> _photos = [];
  final List<File> _videos = [];
  final List<File> _audios = [];

  @override
  void initState() {
    super.initState();
    // Get report type from URL parameters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouterState.of(context).uri;
      final reportTypeId = uri.queryParameters['type'];
      if (reportTypeId != null) {
        _selectedReportTypeId = reportTypeId;
        _selectedReportType = ref.read(reportTypeByIdProvider(reportTypeId));
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photos.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videos.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        _audios.add(File(result.files.single.path!));
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_anonymity == 'Select') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select anonymity preference')),
      );
      return;
    }
    if (_selectedReportTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a report type')),
      );
      return;
    }

    final notifier = ref.read(incidentReportProvider.notifier);

    try {
      // Create the report
      await notifier.createReport(
        title: _titleController.text,
        date: DateTime.parse(_dateController.text),
        location: _locationController.text,
        description: _descriptionController.text,
        reportTypeId: _selectedReportTypeId!,
        isAnonymous: _anonymity == 'Anonymous',
      );

      final report = ref.read(currentReportProvider);
      if (report == null) throw Exception('Failed to create report');

      // Upload evidence files
      try {
        for (var photo in _photos) {
          if (await photo.exists()) {
            await notifier.uploadEvidence('photo', photo);
          }
        }
        for (var video in _videos) {
          if (await video.exists()) {
            await notifier.uploadEvidence('video', video);
          }
        }
        for (var audio in _audios) {
          if (await audio.exists()) {
            await notifier.uploadEvidence('audio', audio);
          }
        }
      } catch (e) {
        print('Error uploading evidence: $e');
        // Continue with report submission even if evidence upload fails
      }

      if (mounted) {
        // Navigate to review screen
        context.go('${AppRouter.incidentReport}/review-report');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(reportLoadingProvider);
    final error = ref.watch(reportErrorProvider);
    // Set the active tab to 'Report' (index 2)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedBottomNavIndexProvider.notifier).state = 2;
    });

    // Show error if any
    if (error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
        ref.read(incidentReportProvider.notifier).clearError();
      });
    }

    return Scaffold(
      appBar:
          const CustomAppBar(title: 'Report Incident', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Display selected report type
              if (_selectedReportType != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIconFromString(_selectedReportType!.icon),
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedReportType!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _selectedReportType!.description,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Title',
                hint: 'Enter a short title for the incident',
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.length < 5) {
                    return 'Title should be at least 5 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Date of Incident',
                hint: 'Select Date',
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Location of Incident',
                hint: 'Enter Location',
                controller: _locationController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description of Incident',
                hint: 'Describe the incident',
                controller: _descriptionController,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the incident';
                  }
                  if (value.length < 20) {
                    return 'Description should be at least 20 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Evidence (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text('Add Photos (${_photos.length})'),
                onTap: _pickImage,
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: Text('Add Videos (${_videos.length})'),
                onTap: _pickVideo,
              ),
              ListTile(
                leading: const Icon(Icons.mic_none_outlined),
                title: Text('Add Audio (${_audios.length})'),
                onTap: _pickAudio,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _anonymity,
                items: const [
                  DropdownMenuItem(
                      value: 'Select', child: Text('Select Anonymity')),
                  DropdownMenuItem(
                      value: 'Anonymous', child: Text('Anonymous')),
                  DropdownMenuItem(
                      value: 'Not Anonymous', child: Text('Not Anonymous')),
                ],
                onChanged: (val) =>
                    setState(() => _anonymity = val ?? 'Select'),
                decoration: const InputDecoration(labelText: 'Anonymity'),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Submit Report',
                isLoading: isLoading,
                onPressed: _submitReport,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'attach_money':
        return Icons.attach_money;
      case 'shield_outlined':
        return Icons.shield_outlined;
      case 'people_outline':
        return Icons.people_outline;
      case 'gavel_outlined':
        return Icons.gavel_outlined;
      case 'security':
        return Icons.security;
      case 'eco':
        return Icons.eco;
      case 'work':
        return Icons.work;
      case 'help_outline':
        return Icons.help_outline;
      default:
        return Icons.report_problem_outlined;
    }
  }
}
