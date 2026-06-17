import 'package:cloud_firestore/cloud_firestore.dart';

class Assets {
  final String id;
  final String eventType;
  final String name;
  final String memberType;
  final Timestamp timestamp;
  final String? photoUrl;
  final String assetTagId;
  final String assetTagName;
  final String assetAssignee;
  final String assetDepartment;
  final String assetStatus;
  final String assetDateCreated;

  Assets({
    required this.id,
    required this.eventType,
    required this.name,
    required this.memberType,
    required this.timestamp,
    this.photoUrl,
    required this.assetTagId,
    required this.assetTagName,
    required this.assetAssignee,
    required this.assetDepartment,
    required this.assetStatus,
    required this.assetDateCreated,
  });

  factory Assets.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Assets(
      id: doc.id,
      eventType: data['event_type'] ??
          data['eventType'] ??
          data['asset_status'] ??
          'unknown',
      name: data['owner_name'] ??
          data['name'] ??
          data['asset_tag_name'] ??
          'Unknown',
      memberType: data['member_type'] ??
          data['memberType'] ??
          data['asset_department_name'] ??
          'Guest',
      timestamp: _timestampFromData(
        data['timestamp'] ?? data['createdAt'],
      ),
      photoUrl: data['photo_url'] ?? data['photoUrl'],
      assetTagId: data['asset_tag_id'] ?? '',
      assetTagName: data['asset_tag_name'] ?? '',
      assetAssignee: data['asset_assignee_owner'] ?? '',
      assetDepartment: data['asset_department_name'] ?? '',
      assetStatus: data['asset_status'] ?? '',
      assetDateCreated: data['asset_created_date'] ?? '',
    );
  }

  static Timestamp _timestampFromData(dynamic value) {
    if (value is Timestamp) return value;
    if (value is DateTime) return Timestamp.fromDate(value);
    return Timestamp.now();
  }
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<int> getTotalRecords() async {
    final snapshot = await _db.collection('assets').count().get();
    return snapshot.count ?? 0;
  }

  Stream<List<Assets>> getEventsRealtime({int limit = 100}) {
    return _db
        .collection('assets')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Assets.fromFirestore(doc)).toList());
  }
}
