import 'package:flutter_test/flutter_test.dart';
import 'package:stroke_detection/main.dart';

void main() {
  testWidgets('Memverifikasi Splash Screen dan Halaman Utama Deteksi Stroke', (
    WidgetTester tester,
  ) async {
    // Build aplikasi
    await tester.pumpWidget(const StrokeDetectionApp());

    // 1. Verifikasi elemen pada Splash Screen awal
    expect(find.text('STROKE DETECT AI'), findsOneWidget);

    // 2. Simulasi jalannya waktu agar splash screen selesai (3.5 detik)
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pumpAndSettle();

    // 3. Verifikasi halaman utama deteksi stroke telah muncul
    expect(find.text('Deteksi Gejala Stroke'), findsOneWidget);
    expect(find.text('Pratinjau Gambar'), findsOneWidget);
    expect(find.text('Buka Kamera'), findsOneWidget);
    expect(find.text('Pilih Gambar'), findsOneWidget);
    expect(find.text('Hasil Klasifikasi'), findsOneWidget);
  });
}
