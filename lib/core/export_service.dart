import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'models.dart';

/// Service for exporting data to CSV and other formats
class ExportService {
  static final ExportService _instance = ExportService._internal();

  factory ExportService() => _instance;

  ExportService._internal();

  /// Export bugs to CSV file
  Future<void> exportBugsToCsv(List<Bug> bugs, {List<Project>? projects}) async {
    try {
      // Prepare CSV headers
      final headers = [
        'Tracking ID',
        'Title',
        'Description',
        'Status',
        'Severity',
        'Project',
        'Assignee',
        'Reporter',
        'Environment',
        'Created At',
        'Updated At',
        'Steps to Reproduce',
        'Expected Behavior',
        'Actual Behavior',
      ];

      // Prepare rows
      final rows = <List<String>>[headers];

      for (final bug in bugs) {
        final projectName = projects != null && bug.projectId != null
            ? projects.firstWhere(
                (p) => p.id == bug.projectId,
                orElse: () => Project(id: '', name: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
              ).name
            : bug.projectId ?? 'N/A';

        rows.add([
          bug.trackingId,
          bug.title,
          _escapeCsv(bug.description),
          bug.status,
          bug.severity,
          projectName,
          bug.assigneeId ?? 'Unassigned',
          bug.reporterId,
          bug.environment ?? 'N/A',
          bug.createdAt.toIso8601String(),
          bug.updatedAt.toIso8601String(),
          _escapeCsv(bug.stepsToReproduce ?? ''),
          _escapeCsv(bug.expectedBehavior ?? ''),
          _escapeCsv(bug.actualBehavior ?? ''),
        ]);
      }

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(rows);

      // Save to file
      final file = await _saveCsvToFile(csvString, 'bugs_export_${DateTime.now().millisecondsSinceEpoch}.csv');

      // Share the file
      await Share.shareXFiles([XFile(file.path, mimeType: 'text/csv')]);
    } catch (e) {
      debugPrint('Error exporting bugs to CSV: $e');
      rethrow;
    }
  }

  /// Export projects to CSV file
  Future<void> exportProjectsToCsv(List<Project> projects) async {
    try {
      final headers = [
        'ID',
        'Name',
        'Description',
        'Created By',
        'Created At',
        'Updated At',
      ];

      final rows = <List<String>>[headers];

      for (final project in projects) {
        rows.add([
          project.id,
          project.name,
          _escapeCsv(project.description ?? ''),
          project.createdBy ?? 'N/A',
          project.createdAt.toIso8601String(),
          project.updatedAt.toIso8601String(),
        ]);
      }

      final csvString = const ListToCsvConverter().convert(rows);
      final file = await _saveCsvToFile(csvString, 'projects_export_${DateTime.now().millisecondsSinceEpoch}.csv');

      await Share.shareXFiles([XFile(file.path, mimeType: 'text/csv')]);
    } catch (e) {
      debugPrint('Error exporting projects to CSV: $e');
      rethrow;
    }
  }

  /// Export combined data (bugs + projects) to CSV
  Future<void> exportCombinedToCsv({
    required List<Bug> bugs,
    required List<Project> projects,
  }) async {
    try {
      final headers = [
        'Type',
        'ID',
        'Tracking ID',
        'Title',
        'Description',
        'Status',
        'Severity',
        'Project',
        'Created At',
        'Updated At',
      ];

      final rows = <List<String>>[headers];

      // Add projects
      for (final project in projects) {
        rows.add([
          'Project',
          project.id,
          '',
          project.name,
          _escapeCsv(project.description ?? ''),
          '',
          '',
          '',
          project.createdAt.toIso8601String(),
          project.updatedAt.toIso8601String(),
        ]);
      }

      // Add bugs
      for (final bug in bugs) {
        final projectName = projects.isNotEmpty && bug.projectId != null
            ? projects.firstWhere(
                (p) => p.id == bug.projectId,
                orElse: () => Project(id: '', name: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
              ).name
            : bug.projectId ?? 'N/A';

        rows.add([
          'Bug',
          bug.id,
          bug.trackingId,
          bug.title,
          _escapeCsv(bug.description),
          bug.status,
          bug.severity,
          projectName,
          bug.createdAt.toIso8601String(),
          bug.updatedAt.toIso8601String(),
        ]);
      }

      final csvString = const ListToCsvConverter().convert(rows);
      final file = await _saveCsvToFile(csvString, 'full_export_${DateTime.now().millisecondsSinceEpoch}.csv');

      await Share.shareXFiles([XFile(file.path, mimeType: 'text/csv')]);
    } catch (e) {
      debugPrint('Error exporting combined data to CSV: $e');
      rethrow;
    }
  }

  /// Export to JSON format
  Future<void> exportToJson({
    required List<Bug> bugs,
    required List<Project> projects,
  }) async {
    try {
      final data = {
        'export_date': DateTime.now().toIso8601String(),
        'projects': projects.map((p) => p.toMap()).toList(),
        'bugs': bugs.map((b) => b.toMap()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final file = await _saveTextToFile(jsonString, 'export_${DateTime.now().millisecondsSinceEpoch}.json');

      await Share.shareXFiles([XFile(file.path, mimeType: 'application/json')]);
    } catch (e) {
      debugPrint('Error exporting to JSON: $e');
      rethrow;
    }
  }

  /// Save CSV string to file
  Future<File> _saveCsvToFile(String csvString, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csvString);
    return file;
  }

  /// Save text to file
  Future<File> _saveTextToFile(String text, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(text);
    return file;
  }

  /// Escape CSV special characters
  String _escapeCsv(String text) {
    // Replace newlines and commas that might break CSV
    return text
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .replaceAll(',', ';')
        .replaceAll('"', "''");
  }

  /// Generate CSV content without sharing (for testing/debugging)
  String generateBugsCsvContent(List<Bug> bugs, {List<Project>? projects}) {
    final headers = [
      'Tracking ID',
      'Title',
      'Status',
      'Severity',
      'Project',
      'Created At',
    ];

    final rows = <List<String>>[headers];

    for (final bug in bugs) {
      final projectName = projects != null && bug.projectId != null
          ? projects.firstWhere(
              (p) => p.id == bug.projectId,
              orElse: () => Project(id: '', name: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
            ).name
          : bug.projectId ?? 'N/A';

      rows.add([
        bug.trackingId,
        bug.title,
        bug.status,
        bug.severity,
        projectName,
        bug.createdAt.toIso8601String(),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}
