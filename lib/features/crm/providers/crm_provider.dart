import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/isar_service.dart';
import '../models/crm_models.dart';

class CrmProvider extends ChangeNotifier {
  final IsarService _isarService = IsarService();
  final Uuid _uuid = const Uuid();

  List<CrmClient> _clients = [];
  bool _loading = false;
  String? _error;

  List<CrmClient> get clients => _clients;
  bool get loading => _loading;
  String? get error => _error;

  CrmProvider() {
    loadClients();
  }

  Future<void> loadClients() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final isarClients = await _isarService.getCachedClients();
      _clients = isarClients.map((ic) => CrmClient.fromIsar(ic)).toList();
    } catch (e) {
      _error = 'Nepodarilo sa načítať CRM klientov: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createClient({
    required String companyName,
    String? contactName,
    String? email,
    String? phone,
    String? website,
    required String service,
    required String status,
    String? budget,
    String? notes,
  }) async {
    final now = DateTime.now();
    final newClient = CrmClient(
      id: _uuid.v4(),
      companyName: companyName,
      contactName: contactName,
      email: email,
      phone: phone,
      website: website,
      service: service,
      status: status,
      budget: budget,
      notes: notes,
      tasks: [],
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
    );

    // Save to local cache
    await _isarService.saveLocalClient(newClient.toIsar());

    // Update in-memory state
    _clients.insert(0, newClient);
    notifyListeners();

    // Log Activity log for client creation
    await addActivity(
      clientId: newClient.id,
      type: 'note',
      title: 'Klient zaregistrovaný',
      content: 'Nový klient bol úspešne pridaný do systému.',
    );

    // TODO: Zápis do offline fronty pre budúci remote sync
    final payload = jsonEncode(newClient.toJson());
    await _isarService.addToQueue('crm_create_client', newClient.id, payload);
  }

  Future<void> updateClient(CrmClient updatedClient) async {
    final now = DateTime.now();
    final clientWithTime = updatedClient.copyWith(
      updatedAt: now,
      syncStatus: 'pending',
    );

    // Save to local cache
    await _isarService.saveLocalClient(clientWithTime.toIsar());

    // Update in-memory state
    final index = _clients.indexWhere((c) => c.id == clientWithTime.id);
    if (index != -1) {
      // Automatic activity log if status changed
      final oldClient = _clients[index];
      if (oldClient.status != clientWithTime.status) {
        await addActivity(
          clientId: clientWithTime.id,
          type: 'status_change',
          title: 'Zmena stavu',
          content:
              'Stav zmenený z "${oldClient.status}" na "${clientWithTime.status}"',
        );
      }

      _clients[index] = clientWithTime;
      notifyListeners();
    }

    // TODO: Zápis do offline fronty pre budúci remote sync
    final payload = jsonEncode(clientWithTime.toJson());
    await _isarService.addToQueue(
      'crm_update_client',
      clientWithTime.id,
      payload,
    );
  }

  Future<void> softDeleteClient(String clientId) async {
    // Save to local cache
    await _isarService.deleteLocalClient(clientId);

    // Update in-memory state
    final index = _clients.indexWhere((c) => c.id == clientId);
    if (index != -1) {
      final updated = _clients[index].copyWith(
        deletedAt: DateTime.now(),
        syncStatus: 'pending',
      );
      _clients[index] = updated;
      notifyListeners();
    }

    // TODO: Zápis do offline fronty pre budúci remote sync
    await _isarService.addToQueue(
      'crm_delete_client',
      clientId,
      jsonEncode({
        'id': clientId,
        'deletedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<void> restoreClient(String clientId) async {
    // Save to local cache
    await _isarService.restoreLocalClient(clientId);

    // Update in-memory state
    final index = _clients.indexWhere((c) => c.id == clientId);
    if (index != -1) {
      final updated = _clients[index].copyWith(
        deletedAt: null,
        syncStatus: 'pending',
      );
      _clients[index] = updated;
      notifyListeners();
    }

    // TODO: Zápis do offline fronty pre budúci remote sync
    await _isarService.addToQueue(
      'crm_restore_client',
      clientId,
      jsonEncode({'id': clientId}),
    );
  }

  Future<void> permanentlyDeleteClient(String clientId) async {
    // Save to local cache
    await _isarService.permanentlyDeleteLocalClient(clientId);

    // Update in-memory state
    _clients.removeWhere((c) => c.id == clientId);
    notifyListeners();

    // TODO: Zápis do offline fronty pre budúci remote sync
    await _isarService.addToQueue(
      'crm_permanent_delete_client',
      clientId,
      jsonEncode({'id': clientId}),
    );
  }

  // --- Task management ---
  Future<void> addTask(String clientId, String text, String? dueDate) async {
    final index = _clients.indexWhere((c) => c.id == clientId);
    if (index == -1) return;

    final now = DateTime.now();
    final newTask = CrmClientTask(
      id: _uuid.v4(),
      text: text,
      done: false,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );

    final updatedTasks = [..._clients[index].tasks, newTask];
    final updatedClient = _clients[index].copyWith(
      tasks: updatedTasks,
      updatedAt: now,
      syncStatus: 'pending',
    );

    await _isarService.saveLocalClient(updatedClient.toIsar());
    _clients[index] = updatedClient;
    notifyListeners();

    // TODO: Zápis do offline fronty pre budúci remote sync
    await _isarService.addToQueue(
      'crm_add_task',
      clientId,
      jsonEncode({'clientId': clientId, 'task': newTask.toJson()}),
    );
  }

  Future<void> updateTask(
    String clientId,
    String taskId, {
    required bool done,
  }) async {
    final clientIndex = _clients.indexWhere((c) => c.id == clientId);
    if (clientIndex == -1) return;

    final client = _clients[clientIndex];
    final now = DateTime.now();

    final updatedTasks = client.tasks.map((t) {
      if (t.id == taskId) {
        return CrmClientTask(
          id: t.id,
          text: t.text,
          done: done,
          dueDate: t.dueDate,
          createdAt: t.createdAt,
          updatedAt: now,
        );
      }
      return t;
    }).toList();

    final updatedClient = client.copyWith(
      tasks: updatedTasks,
      updatedAt: now,
      syncStatus: 'pending',
    );

    await _isarService.saveLocalClient(updatedClient.toIsar());
    _clients[clientIndex] = updatedClient;
    notifyListeners();

    // TODO: Zápis do offline fronty pre budúci remote sync
    final updatedTask = updatedTasks.firstWhere((t) => t.id == taskId);
    await _isarService.addToQueue(
      'crm_update_task',
      clientId,
      jsonEncode({'clientId': clientId, 'task': updatedTask.toJson()}),
    );
  }

  Future<void> deleteTask(String clientId, String taskId) async {
    final clientIndex = _clients.indexWhere((c) => c.id == clientId);
    if (clientIndex == -1) return;

    final client = _clients[clientIndex];
    final now = DateTime.now();

    final updatedTasks = client.tasks.where((t) => t.id != taskId).toList();
    final updatedClient = client.copyWith(
      tasks: updatedTasks,
      updatedAt: now,
      syncStatus: 'pending',
    );

    await _isarService.saveLocalClient(updatedClient.toIsar());
    _clients[clientIndex] = updatedClient;
    notifyListeners();

    // TODO: Zápis do offline fronty pre budúci remote sync
    await _isarService.addToQueue(
      'crm_delete_task',
      clientId,
      jsonEncode({'clientId': clientId, 'taskId': taskId}),
    );
  }

  // --- Client Activity logger ---
  Future<List<CrmClientActivity>> getActivitiesForClient(
    String clientId,
  ) async {
    try {
      final isarActivities = await _isarService.getCachedActivitiesForClient(
        clientId,
      );
      return isarActivities
          .map((ia) => CrmClientActivity.fromIsar(ia))
          .toList();
    } catch (e) {
      print('Chyba načítania CRM aktivít: $e');
      return [];
    }
  }

  Future<void> addActivity({
    required String clientId,
    required String type,
    required String title,
    String? content,
  }) async {
    final newActivity = CrmClientActivity(
      id: _uuid.v4(),
      clientId: clientId,
      type: type,
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );

    await _isarService.saveLocalActivity(newActivity.toIsar());

    // TODO: Zápis do offline fronty pre budúci remote sync
    await _isarService.addToQueue(
      'crm_create_activity',
      clientId,
      jsonEncode(newActivity.toJson()),
    );
  }
}
