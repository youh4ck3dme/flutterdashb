import 'package:isar/isar.dart';

part 'isar_models.g.dart';

@collection
class IsarProject {
  Id? isarId;

  @Index(unique: true, replace: true)
  String? id;

  String? name;
  String? description;
  String? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
}

@collection
class IsarBug {
  Id? isarId;

  @Index(unique: true, replace: true)
  String? id;

  String? trackingId;
  String? title;
  String? description;
  String? projectId;
  String? assigneeId;
  String? reporterId;
  String? severity;
  String? status;
  String? stepsToReproduce;
  String? expectedBehavior;
  String? actualBehavior;
  String? environment;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool synced = true;
}

@collection
class IsarOfflineQueue {
  Id? isarId;

  String? operation; // 'create', 'update_status', 'update_severity'
  String? bugId; // UUID or local tracking id
  String? payload; // JSON data
  DateTime? createdAt;
}

@embedded
class IsarClientTask {
  String? id;
  String? text;
  bool? done;
  String? dueDate;
  DateTime? createdAt;
  DateTime? updatedAt;
}

@collection
class IsarClient {
  Id? isarId;

  @Index(unique: true, replace: true)
  String? id;

  String? companyName;
  String? contactName;
  String? email;
  String? phone;
  String? website;
  String? service;
  String? status;
  String? budget;
  String? notes;
  List<IsarClientTask>? tasks;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  String? syncStatus;
}

@collection
class IsarClientActivity {
  Id? isarId;

  @Index(unique: true, replace: true)
  String? id;

  String? clientId;
  String? type;
  String? title;
  String? content;
  DateTime? createdAt;
}
