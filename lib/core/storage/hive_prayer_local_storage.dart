import 'dart:async';

import 'package:hive_ce/hive.dart';

import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import 'prayer_local_storage.dart';
import 'prayer_record.dart';

/// Hive-backed [PrayerLocalStorage].
///
/// Values are stored as plain `Map`s rather than generated `TypeAdapter`s, so
/// the project stays free of `build_runner` while keeping schema control in
/// [PrayerRecord].
class HivePrayerLocalStorage implements PrayerLocalStorage {
  final HiveInterface _hive;
  final String _boxName;

  Box<Map>? _box;
  final StreamController<void> _statusChanges = StreamController<void>.broadcast();

  HivePrayerLocalStorage({
    required HiveInterface hive,
    String boxName = AppConstants.prayersBoxName,
  })  : _hive = hive,
        _boxName = boxName;

  Box<Map> get _requireBox {
    final box = _box;
    if (box == null || !box.isOpen) {
      throw const CacheException('Prayer box accessed before init()');
    }
    return box;
  }

  @override
  Future<void> init() async {
    if (_box?.isOpen ?? false) return;
    try {
      _box = await _hive.openBox<Map>(_boxName);
    } catch (e) {
      throw CacheException('Failed to open the prayers box: $e');
    }
  }

  @override
  Future<void> saveAll(List<PrayerRecord> records) async {
    if (records.isEmpty) return;
    final box = _requireBox;
    try {
      final entries = <String, Map>{};
      for (final record in records) {
        // Preserve a status the user already recorded for this slot.
        final existing = box.get(record.storageKey);
        final existingStatus = existing?['statusId'] as String?;
        entries[record.storageKey] =
            record.copyWith(statusId: existingStatus ?? record.statusId).toMap();
      }
      await box.putAll(entries);
    } catch (e) {
      throw CacheException('Failed to save prayers: $e');
    }
  }

  @override
  List<PrayerRecord> getByDate(String dateKey) {
    try {
      // Keys are `date|prayer`, so a day can be selected by prefix without
      // deserialising every row in the box.
      return _readKeysWhere((key) => key.startsWith('$dateKey|'));
    } catch (e) {
      throw CacheException('Failed to read prayers for $dateKey: $e');
    }
  }

  @override
  List<PrayerRecord> getInRange(String startKey, String endKey) {
    try {
      return _readKeysWhere((key) {
        final datePart = key.split('|').first;
        return datePart.compareTo(startKey) >= 0 &&
            datePart.compareTo(endKey) <= 0;
      });
    } catch (e) {
      throw CacheException('Failed to read prayers in range: $e');
    }
  }

  @override
  List<PrayerRecord> getAll() {
    try {
      return _readWhere((_) => true);
    } catch (e) {
      throw CacheException('Failed to read prayers: $e');
    }
  }

  @override
  Future<PrayerRecord?> updateStatus({
    required String dateKey,
    required String prayerId,
    required String? statusId,
  }) async {
    final box = _requireBox;
    final key = '$dateKey|$prayerId';
    try {
      final stored = box.get(key);
      if (stored == null) return null;

      final updated = PrayerRecord.fromMap(stored)
          .copyWith(statusId: statusId, clearStatus: statusId == null);
      await box.put(key, updated.toMap());
      _statusChanges.add(null);
      return updated;
    } catch (e) {
      throw CacheException('Failed to update $key: $e');
    }
  }

  @override
  Stream<void> get onStatusChanged => _statusChanges.stream;

  @override
  Future<void> close() async {
    // Close the box first: no further write can then reach the controller.
    final box = _box;
    _box = null;
    if (box != null && box.isOpen) await box.close();
    if (!_statusChanges.isClosed) await _statusChanges.close();
  }

  /// Reads every record, sorted by time.
  List<PrayerRecord> _readWhere(bool Function(PrayerRecord) test) {
    final records = <PrayerRecord>[];
    for (final value in _requireBox.values) {
      final record = PrayerRecord.fromMap(value);
      if (test(record)) records.add(record);
    }
    return _sorted(records);
  }

  /// Selects rows by their key before touching the stored value, then returns
  /// them sorted by time so callers always get Fajr → Isha order regardless of
  /// Hive's key ordering.
  List<PrayerRecord> _readKeysWhere(bool Function(String) test) {
    final box = _requireBox;
    final records = <PrayerRecord>[];
    for (final key in box.keys) {
      if (key is! String || !test(key)) continue;
      final value = box.get(key);
      if (value != null) records.add(PrayerRecord.fromMap(value));
    }
    return _sorted(records);
  }

  List<PrayerRecord> _sorted(List<PrayerRecord> records) {
    records.sort((a, b) => a.timeIso.compareTo(b.timeIso));
    return records;
  }
}
