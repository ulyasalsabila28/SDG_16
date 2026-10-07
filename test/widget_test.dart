import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project_kel_laporin_bloom/core/api.dart';

void main() {
  test('label status tersedia', () {
    expect(statusLabel['selesai'], 'Sudah Ditangani');
  });
}
