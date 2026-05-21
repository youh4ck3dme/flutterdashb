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
  String? bugId;     // UUID or local tracking id
  String? payload;   // JSON data
  DateTime? createdAt;
}
