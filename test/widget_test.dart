import 'package:flutter_test/flutter_test.dart';
import 'package:stroke_detection/main.dart';

void main() {
  testWidgets('Memverifikasi elemen UI statis deteksi stroke awal', (
    WidgetTester tester,
  ) async {
    // Build aplikasi kita
    await tester.pumpWidget(const StrokeDetectionApp());

    // Pastikan judul dan elemen teks ada
    expect(find.text('Deteksi Gejala Stroke'), findsOneWidget);
    expect(find.text('Pratinjau Gambar'), findsOneWidget);
    expect(find.text('Buka Kamera'), findsOneWidget);
    expect(find.text('Pilih Gambar'), findsOneWidget);
    expect(find.text('Hasil Klasifikasi'), findsOneWidget);
  });
}
