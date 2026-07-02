import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nustar_asset_scanner_app/screens/collection_viewer_screen.dart';
import 'package:nustar_asset_scanner_app/models/assets_model.dart';

void main() {
  Timestamp ts(int year, int month, int day, int hour, int minute, int second) {
    return Timestamp.fromDate(DateTime(year, month, day, hour, minute, second));
  }

  test('getCurrentlyOutAssets returns empty list when events is empty', () {
    expect(getCurrentlyOutAssets([]), isEmpty);
  });

  test('getCurrentlyOutAssets returns only the latest OUT record per asset', () {
    final events = [
      Assets(
        id: '1',
        eventType: 'IN',
        name: 'Laptop A',
        memberType: 'Employee',
        timestamp: ts(2025, 6, 1, 8, 0, 0),
        assetTagId: 'LAP-001',
        assetTagName: 'Laptop A',
        assetAssignee: 'John',
        assetDepartment: 'IT',
        assetStatus: 'Available',
        assetDateCreated: '2025-01-01',
      ),
      Assets(
        id: '2',
        eventType: 'OUT',
        name: 'Laptop A',
        memberType: 'Employee',
        timestamp: ts(2025, 6, 1, 9, 0, 0),
        assetTagId: 'LAP-001',
        assetTagName: 'Laptop A',
        assetAssignee: 'John',
        assetDepartment: 'IT',
        assetStatus: 'In Use',
        assetDateCreated: '2025-01-01',
      ),
      Assets(
        id: '3',
        eventType: 'OUT',
        name: 'Laptop B',
        memberType: 'Employee',
        timestamp: ts(2025, 6, 1, 10, 0, 0),
        assetTagId: 'LAP-002',
        assetTagName: 'Laptop B',
        assetAssignee: 'Jane',
        assetDepartment: 'HR',
        assetStatus: 'In Use',
        assetDateCreated: '2025-01-02',
      ),
    ];

    final result = getCurrentlyOutAssets(events);

    expect(result.length, 2);
    expect(result.map((e) => e.assetTagId).toSet(), {'LAP-001', 'LAP-002'});
  });

  test('getCurrentlyOutAssets excludes asset whose latest record is IN', () {
    final events = [
      Assets(
        id: '1',
        eventType: 'OUT',
        name: 'Laptop A',
        memberType: 'Employee',
        timestamp: ts(2025, 6, 1, 8, 0, 0),
        assetTagId: 'LAP-001',
        assetTagName: 'Laptop A',
        assetAssignee: 'John',
        assetDepartment: 'IT',
        assetStatus: 'In Use',
        assetDateCreated: '2025-01-01',
      ),
      Assets(
        id: '2',
        eventType: 'IN',
        name: 'Laptop A',
        memberType: 'Employee',
        timestamp: ts(2025, 6, 1, 10, 0, 0),
        assetTagId: 'LAP-001',
        assetTagName: 'Laptop A',
        assetAssignee: 'John',
        assetDepartment: 'IT',
        assetStatus: 'Available',
        assetDateCreated: '2025-01-01',
      ),
    ];

    final result = getCurrentlyOutAssets(events);

    expect(result.length, 0);
  });

  test('getCurrentlyOutAssets handles EXIT eventType', () {
    final events = [
      Assets(
        id: '1',
        eventType: 'EXIT',
        name: 'Laptop A',
        memberType: 'Employee',
        timestamp: ts(2025, 6, 1, 8, 0, 0),
        assetTagId: 'LAP-001',
        assetTagName: 'Laptop A',
        assetAssignee: 'John',
        assetDepartment: 'IT',
        assetStatus: 'In Use',
        assetDateCreated: '2025-01-01',
      ),
    ];

    final result = getCurrentlyOutAssets(events);

    expect(result.length, 1);
    expect(result.first.assetTagId, 'LAP-001');
  });

  test('getCurrentlyOutAssets sorts results by timestamp descending', () {
    final events = [
      Assets(
        id: '1',
        eventType: 'OUT',
        name: 'Laptop B',
        memberType: 'Employee',
        timestamp: ts(2025, 6, 1, 10, 0, 0),
        assetTagId: 'LAP-002',
        assetTagName: 'Laptop B',
        assetAssignee: 'Jane',
        assetDepartment: 'HR',
        assetStatus: 'In Use',
        assetDateCreated: '2025-01-02',
      ),
      Assets(
        id: '2',
        eventType: 'OUT',
        name: 'Laptop A',
        memberType: 'Employee',
        timestamp: ts(2025, 6, 1, 9, 0, 0),
        assetTagId: 'LAP-001',
        assetTagName: 'Laptop A',
        assetAssignee: 'John',
        assetDepartment: 'IT',
        assetStatus: 'In Use',
        assetDateCreated: '2025-01-01',
      ),
    ];

    final result = getCurrentlyOutAssets(events);

    expect(result.length, 2);
    expect(result.first.assetTagId, 'LAP-002');
    expect(result.last.assetTagId, 'LAP-001');
  });
}
