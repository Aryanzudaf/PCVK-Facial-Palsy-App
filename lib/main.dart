import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const StrokeDetectionApp());
}

class StrokeDetectionApp extends StatelessWidget {
  const StrokeDetectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deteksi Gejala Stroke Awal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Nuansa tema medis (Teal / Hijau-Toska Profesional)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00796B),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF00796B),
          foregroundColor: Colors.white,
        ),
      ),
      home: const StrokeDetectionHomePage(),
    );
  }
}

class StrokeDetectionHomePage extends StatefulWidget {
  const StrokeDetectionHomePage({super.key});

  @override
  State<StrokeDetectionHomePage> createState() =>
      _StrokeDetectionHomePageState();
}

class _StrokeDetectionHomePageState extends State<StrokeDetectionHomePage> {
  // Instance ImagePicker
  final ImagePicker _picker = ImagePicker();

  // State untuk menyimpan data gambar yang dipilih
  XFile? _selectedImage;
  Uint8List? _imageBytes;

  // State untuk status analisis / pemrosesan
  bool _isAnalyzing = false;
  String _statusText = 'Menunggu Input Gambar';
  Color _statusColor = const Color(0xFF64748B);
  String _predictionLabel = '- (Belum ada analisis) -';
  String _confidenceScore = '-- %';
  String _recommendation =
      'Silakan ambil atau pilih foto wajah untuk memulai deteksi awal.';
  bool _hasResult = false;

  // Fungsi untuk mengambil gambar dari Kamera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front, // Utamakan kamera depan untuk wajah
        imageQuality: 85,
      );

      if (photo != null) {
        final Uint8List bytes = await photo.readAsBytes();
        setState(() {
          _selectedImage = photo;
          _imageBytes = bytes;
          _statusText = 'Gambar Siap Dianalisis';
          _statusColor = const Color(0xFF0284C7); // Biru info
          _hasResult = false;
          _predictionLabel = '- (Klik tombol "Mulai Analisis") -';
          _confidenceScore = '-- %';
          _recommendation =
              'Foto berhasil diambil. Tekan tombol "Mulai Analisis Deteksi" di bawah untuk melihat hasil klasifikasi.';
        });

        _showSnackBar('Foto berhasil diambil dari kamera!');
      }
    } catch (e) {
      debugPrint('Error saat membuka kamera: $e');
      if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
        _showSnackBar(
          'Fitur kamera tidak didukung di desktop Windows/browser tertentu. Gunakan tombol "Pilih Gambar" atau jalankan di Android emulator.',
        );
      } else {
        _showSnackBar('Gagal mengakses kamera: $e');
      }
    }
  }

  // Fungsi untuk memilih gambar dari Galeri / File Penyimpanan
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _imageBytes = bytes;
          _statusText = 'Gambar Siap Dianalisis';
          _statusColor = const Color(0xFF0284C7);
          _hasResult = false;
          _predictionLabel = '- (Klik tombol "Mulai Analisis") -';
          _confidenceScore = '-- %';
          _recommendation =
              'Gambar berhasil dipilih. Tekan tombol "Mulai Analisis Deteksi" di bawah untuk melihat hasil klasifikasi.';
        });

        _showSnackBar('Gambar berhasil dipilih dari galeri!');
      }
    } catch (e) {
      debugPrint('Error saat memilih gambar dari galeri: $e');
      _showSnackBar('Gagal membuka galeri: $e');
    }
  }

  // Fungsi simulasi analisis klasifikasi gejala stroke
  Future<void> _runClassification() async {
    if (_imageBytes == null) {
      _showSnackBar('Pilih atau ambil gambar terlebih dahulu!');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _statusText = 'Sedang Menganalisis...';
      _statusColor = const Color(0xFFD97706);
    });

    // Simulasi proses analisis AI / pemrosesan citra selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
      _hasResult = true;
      _statusText = 'Selesai Dianalisis';
      _statusColor = const Color(0xFF059669); // Hijau sukses
      _predictionLabel = 'Indikasi Asimetri Wajah (Suspek Stroke Awal)';
      _confidenceScore = '87.4%';
      _recommendation =
          'Sistem mendeteksi kemungkinan sudut bibir/kelopak mata tidak simetris (Facial Droop). Segera lakukan pemeriksaan lebih lanjut ke fasilitas kesehatan terdekat (Metode F.A.S.T).';
    });

    _showSnackBar('Analisis citra selesai!');
  }

  // Fungsi untuk mereset / menghapus gambar
  void _resetImage() {
    setState(() {
      _selectedImage = null;
      _imageBytes = null;
      _isAnalyzing = false;
      _hasResult = false;
      _statusText = 'Menunggu Input Gambar';
      _statusColor = const Color(0xFF64748B);
      _predictionLabel = '- (Belum ada analisis) -';
      _confidenceScore = '-- %';
      _recommendation =
          'Silakan ambil atau pilih foto wajah untuk memulai deteksi awal.';
    });
    _showSnackBar('Gambar telah dihapus.');
  }

  // Menampilkan snackbar pemberitahuan
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Dialog Informasi F.A.S.T
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF00796B)),
            SizedBox(width: 8),
            Text('Metode F.A.S.T Stroke', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• F (Face Drooping): Wajah tampak tidak simetris atau terkulai di satu sisi.',
                style: TextStyle(fontSize: 13, height: 1.4)),
            SizedBox(height: 6),
            Text('• A (Arm Weakness): Kelemahan pada salah satu lengan atau sulit diangkat.',
                style: TextStyle(fontSize: 13, height: 1.4)),
            SizedBox(height: 6),
            Text('• S (Speech Difficulty): Bicara pelo, tidak jelas, atau sulit berbicara.',
                style: TextStyle(fontSize: 13, height: 1.4)),
            SizedBox(height: 6),
            Text('• T (Time to call): Waktu sangat kritis, segera cari bantuan medis darurat.',
                style: TextStyle(fontSize: 13, height: 1.4)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Deteksi Gejala Stroke',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Tentang F.A.S.T',
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. KARTU INFORMASI PANDUAN SINGKAT
              Card(
                elevation: 0,
                color: const Color(0xFFE0F2F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFB2DFDB)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.health_and_safety, color: Color(0xFF00796B), size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ambil foto wajah atau pilih dari galeri untuk mendeteksi indikasi awal gejala stroke (asimetri wajah).',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF004D40),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. KOTAK PRATINJAU GAMBAR (IMAGE PREVIEW BOX)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pratinjau Gambar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (_imageBytes != null)
                    TextButton.icon(
                      onPressed: _resetImage,
                      icon: const Icon(Icons.refresh, size: 16, color: Colors.redAccent),
                      label: const Text(
                        'Hapus / Ganti',
                        style: TextStyle(fontSize: 12, color: Colors.redAccent),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              Container(
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _imageBytes != null
                        ? const Color(0xFF00796B)
                        : const Color(0xFFCBD5E1),
                    width: _imageBytes != null ? 2.0 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _imageBytes != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            // Tampilkan foto yang berhasil diambil / dipilih
                            Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            ),
                            // Overlay gradient tipis di bagian bawah foto
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 12,
                                ),
                                color: Colors.black.withValues(alpha: 0.5),
                                child: Text(
                                  _selectedImage?.name ?? 'Foto Terpilih',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Belum ada gambar yang dipilih',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Gunakan tombol di bawah untuk memasukkan foto',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // 3. TOMBOL "BUKA KAMERA" & "PILIH GAMBAR"
              Row(
                children: [
                  // Tombol Buka Kamera
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImageFromCamera,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Buka Kamera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00796B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tombol Pilih Gambar
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImageFromGallery,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Pilih Gambar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00796B),
                        side: const BorderSide(color: Color(0xFF00796B), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 4. TOMBOL "MULAI ANALISIS DETEKSI"
              ElevatedButton.icon(
                onPressed: (_imageBytes != null && !_isAnalyzing)
                    ? _runClassification
                    : null,
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.analytics_outlined),
                label: Text(
                  _isAnalyzing
                      ? 'Sedang Memproses Citra...'
                      : 'Mulai Analisis Deteksi',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  disabledForegroundColor: const Color(0xFF94A3B8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 5. KARTU HASIL KLASIFIKASI
              const Text(
                'Hasil Klasifikasi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _hasResult
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status Deteksi:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),

                    // Label Hasil Prediksi Utama
                    const Text(
                      'Prediksi Label:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _predictionLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _hasResult
                            ? const Color(0xFFDC2626) // Merah peringatan
                            : const Color(0xFF334155),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Label Tingkat Kepercayaan (Confidence Score)
                    Row(
                      children: [
                        const Text(
                          'Tingkat Kepercayaan: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          _confidenceScore,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _hasResult
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Rekomendasi / Keterangan
                    Text(
                      _recommendation,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF475569),
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Catatan Disclaimer Medis
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: Color(0xFFD97706),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Hasil klasifikasi ini hanya sebagai skrining awal dan bukan pengganti diagnosa resmi dokter spesialis saraf.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF92400E),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
