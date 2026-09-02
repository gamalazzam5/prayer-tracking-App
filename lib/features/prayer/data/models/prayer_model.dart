import '../../../../core/storage/prayer_record.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/prayer_entity.dart';
import '../../domain/entities/prayer_name.dart';
import '../../domain/entities/prayer_status.dart';

/// Translates between the storage-shaped [PrayerRecord] and the domain
/// [PrayerEntity]. The domain never sees strings-as-enums.
class PrayerModel extends PrayerEntity {
  const PrayerModel({
    required super.name,
    required super.time,
    super.status,
  });

  /// Returns null when the row references a prayer we no longer know about, so
  /// a single corrupt entry degrades gracefully instead of throwing.
  static PrayerModel? fromRecord(PrayerRecord record) {
    final name = PrayerName.fromId(record.prayerId);
    final time = DateTime.tryParse(record.timeIso);
    if (name == null || time == null) return null;

    return PrayerModel(
      name: name,
      time: time.toLocal(),
      status: PrayerStatus.fromId(record.statusId),
    );
  }

  factory PrayerModel.fromEntity(PrayerEntity entity) => PrayerModel(
        name: entity.name,
        time: entity.time,
        status: entity.status,
      );

  PrayerRecord toRecord(DateTime date) => PrayerRecord(
        dateKey: DateFormatter.toKey(date),
        prayerId: name.id,
        timeIso: time.toIso8601String(),
        statusId: status?.id,
      );
}
