import 'package:depi1/features/qibla/domain/entities/qibla_direction_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QiblaDirectionEntity.offsetFromDevice', () {
    test('is zero when the device already faces the qibla', () {
      const direction =
          QiblaDirectionEntity(qiblaBearing: 136, deviceHeading: 136);
      expect(direction.offsetFromDevice, 0);
    });

    test('is the plain difference when the device points north of the qibla',
        () {
      const direction =
          QiblaDirectionEntity(qiblaBearing: 136, deviceHeading: 100);
      expect(direction.offsetFromDevice, 36);
    });

    test('wraps into 0-360 instead of going negative', () {
      const direction =
          QiblaDirectionEntity(qiblaBearing: 10, deviceHeading: 350);
      expect(direction.offsetFromDevice, 20);
    });

    test('wraps a heading past the qibla back around', () {
      const direction =
          QiblaDirectionEntity(qiblaBearing: 350, deviceHeading: 10);
      expect(direction.offsetFromDevice, 340);
    });

    test('never leaves the compass range for any heading', () {
      for (var heading = 0.0; heading < 360; heading += 7) {
        final offset = QiblaDirectionEntity(
          qiblaBearing: 136.1,
          deviceHeading: heading,
        ).offsetFromDevice;
        expect(offset, greaterThanOrEqualTo(0));
        expect(offset, lessThan(360));
      }
    });
  });
}
