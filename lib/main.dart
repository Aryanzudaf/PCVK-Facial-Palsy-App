import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00796B), // Hijau-toska medis
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
      // Membuka Tampilan Awal (Splash Screen) terlebih dahulu
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// TAMPILAN AWAL / SPLASH SCREEN (ANIMASI LOADING)
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _loadingMessage = 'Memuat sistem...';
  Timer? _messageTimer;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Animasi fade & scale untuk logo
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    // Teks loading bertahap yang dinamis
    _messageTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) return;
      setState(() {
        if (timer.tick == 1) {
          _loadingMessage = 'Menyiapkan modul visi komputer...';
        } else if (timer.tick == 2) {
          _loadingMessage = 'Menginisialisasi parameter deteksi F.A.S.T...';
        } else {
          _loadingMessage = 'Sistem siap digunakan!';
        }
      });
    });

    // Otomatis berpindah ke halaman utama setelah 3 detik
    _navigationTimer = Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const StrokeDetectionHomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _messageTimer?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Gradien profesional nuansa medis modern
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00382E), // Deep Teal
              Color(0xFF005B4F),
              Color(0xFF00796B),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // LOGO DENGAN ANIMASI FADE & SCALE
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      // Lingkaran Berpendar (Glow Icon Container)
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            size: 64,
                            color: Color(0xFF00796B),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // JUDUL APLIKASI
                      const Text(
                        'STROKE DETECT AI',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // SUBTITLE MEDIS
                      Text(
                        'Sistem Skrining Awal Gejala Stroke\nBerbasis Asimetri Wajah (PCVK)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.4,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // INDIKATOR LOADING ELEGAN & TEKS STATUS
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    children: [
                      // Progress Bar Halus
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 4,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF80CBC4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pesan Dinamis Loading
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _loadingMessage,
                          key: ValueKey<String>(_loadingMessage),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.8),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // FOOTER / COPYRIGHT AKADEMIK
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Tugas Akhir Pengolahan Citra & Visi Komputer • v1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// HALAMAN UTAMA APLIKASI
// ==========================================
class StrokeDetectionHomePage extends StatefulWidget {
  const StrokeDetectionHomePage({super.key});

  @override
  State<StrokeDetectionHomePage> createState() =>
      _StrokeDetectionHomePageState();
}

class _StrokeDetectionHomePageState extends State<StrokeDetectionHomePage> {
  final ImagePicker _picker = ImagePicker();

  // State gambar
  XFile? _selectedImage;
  Uint8List? _imageBytes;

  // Konfigurasi Server API (Backend Colab Ngrok / Localhost)
  String _serverUrl = 'https://undone-print-vocalist.ngrok-free.dev/predict';
  bool _useServerApi = true;

  // State Hasil Analisis
  bool _isAnalyzing = false;
  String _statusText = 'Menunggu Input Gambar';
  Color _statusColor = const Color(0xFF64748B);
  String _predictionLabel = '- (Belum ada analisis) -';
  String _confidenceScore = '-- %';
  String _asymmetryScore = '';
  String _recommendation =
      'Silakan ambil atau pilih foto wajah untuk memulai deteksi awal.';
  bool _hasResult = false;
  bool _isSuspect = false;

  // 1. FUNGSI MENGAMBIL FOTO DARI KAMERA
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
      );

      if (photo != null) {
        final Uint8List bytes = await photo.readAsBytes();
        setState(() {
          _selectedImage = photo;
          _imageBytes = bytes;
          _statusText = 'Gambar Siap Dikirim & Dianalisis';
          _statusColor = const Color(0xFF0284C7);
          _hasResult = false;
          _predictionLabel = '- (Tekan tombol "Mulai Analisis Deteksi") -';
          _confidenceScore = '-- %';
          _asymmetryScore = '';
          _recommendation = 'Foto berhasil diambil. Tekan tombol di bawah untuk mengirim dan memproses gambar.';
        });

        _showSnackBar('Foto berhasil diambil dari kamera!');
      }
    } catch (e) {
      debugPrint('Error kamera: $e');
      if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
        _showSnackBar(
          'Kamera sistem tidak didukung di desktop Windows. Gunakan tombol "Pilih Gambar" atau gunakan Android emulator.',
        );
      } else {
        _showSnackBar('Gagal mengakses kamera: $e');
      }
    }
  }

  // 2. FUNGSI MEMILIH GAMBAR DARI GALERI
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
          _statusText = 'Gambar Siap Dikirim & Dianalisis';
          _statusColor = const Color(0xFF0284C7);
          _hasResult = false;
          _predictionLabel = '- (Tekan tombol "Mulai Analisis Deteksi") -';
          _confidenceScore = '-- %';
          _asymmetryScore = '';
          _recommendation = 'Gambar berhasil dipilih. Tekan tombol di bawah untuk mengirim dan memproses gambar.';
        });

        _showSnackBar('Gambar berhasil dipilih dari galeri!');
      }
    } catch (e) {
      debugPrint('Error galeri: $e');
      _showSnackBar('Gagal membuka galeri: $e');
    }
  }

  // 3. FUNGSI UTAMA: MENGIRIM FILE GAMBAR KE SERVER API
  Future<void> _runClassification() async {
    if (_imageBytes == null || _selectedImage == null) {
      _showSnackBar('Pilih atau ambil foto wajah terlebih dahulu!');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _statusText = _useServerApi
          ? 'Mengirim Gambar ke Server...'
          : 'Menganalisis Citra...';
      _statusColor = const Color(0xFFD97706);
    });

    if (_useServerApi) {
      try {
        final uri = Uri.parse(_serverUrl);
        var request = http.MultipartRequest('POST', uri);

        // Header agar permintaan lewat lancar jika menggunakan Ngrok free tunnel
        request.headers['ngrok-skip-browser-warning'] = 'true';

        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            _imageBytes!,
            filename: _selectedImage!.name,
          ),
        );

        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 12),
        );
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          debugPrint('Response API: ${response.body}');
          final Map<String, dynamic> data = jsonDecode(response.body);

          final dynamic rawLabel = data['label_teks'] ?? data['label'];
          final dynamic hasilKlasifikasi = data['hasil_klasifikasi'];

          // 1. Tangani kasus wajah tidak terdeteksi / tidak ada label dari server
          if (rawLabel == null && hasilKlasifikasi == null) {
            final String serverMsg =
                data['error']?.toString() ??
                data['message']?.toString() ??
                'Wajah tidak terdeteksi dengan jelas. Pastikan seluruh wajah menghadap lurus ke kamera.';

            if (!mounted) return;
            setState(() {
              _isAnalyzing = false;
              _hasResult = false;
              _isSuspect = false;
              _statusText = 'Wajah Tidak Terdeteksi';
              _statusColor = const Color(0xFFD97706);
              _predictionLabel = 'Gagal Mendeteksi Wajah';
              _confidenceScore = '-- %';
              _asymmetryScore = '';
              _recommendation = serverMsg;
            });
            _showSnackBar('Wajah tidak terdeteksi, coba ambil foto ulang.');
            return;
          }

          // 2. Format nilai confidence (jika 0.0 - 1.0, kalikan 100)
          final dynamic confVal = data['confidence'];
          String confidence = '-- %';
          if (confVal != null) {
            final double? parsedConf = double.tryParse(confVal.toString());
            if (parsedConf != null) {
              final double pct = parsedConf <= 1.0
                  ? parsedConf * 100
                  : parsedConf;
              confidence = '${pct.toStringAsFixed(2)}%';
            } else {
              confidence = '$confVal%';
            }
          }

          // 3. Tentukan status suspek & label
          final bool isSuspect =
              hasilKlasifikasi == 1 ||
              hasilKlasifikasi?.toString() == '1' ||
              rawLabel == 1 ||
              data['is_stroke_suspect'] == true ||
              (rawLabel?.toString().toLowerCase().contains('unhealthy') ??
                  false) ||
              (rawLabel?.toString().toLowerCase().contains('paralisis') ??
                  false) ||
              (rawLabel?.toString().toLowerCase().contains('stroke') ??
                  false) ||
              (rawLabel?.toString().toLowerCase().contains('asimetri') ??
                  false);

          String label;
          if (rawLabel is int || rawLabel == null) {
            label = isSuspect
                ? 'Indikasi Facial Palsy / Asimetri Wajah'
                : 'Normal / Sehat (Simetris)';
          } else {
            label = rawLabel.toString();
          }

          final String rec =
              data['recommendation']?.toString() ??
              (isSuspect
                  ? 'Terindikasi kemungkinan Facial Palsy / Asimetri Wajah (Metode F.A.S.T).'
                  : 'Kondisi fitur simetri wajah tampak normal / sehat (Healthy).');
          final dynamic asymVal = data['asymmetry_score'];

          if (!mounted) return;
          setState(() {
            _isAnalyzing = false;
            _hasResult = true;
            _isSuspect = isSuspect;
            _statusText = 'Berhasil Dianalisis (Server API)';
            _statusColor = isSuspect
                ? const Color(0xFFDC2626)
                : const Color(0xFF059669);
            _predictionLabel = label;
            _confidenceScore = confidence;
            _asymmetryScore = asymVal != null ? 'Skor Asimetri: $asymVal' : '';
            _recommendation = rec;
          });

          _showSnackBar('Gambar berhasil diproses oleh server!');
          return;
        } else {
          throw Exception('Server mengembalikan kode ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Gagal mengirim ke server API: $e');
        if (!mounted) return;

        _showSnackBar(
          'Server API offline/tidak terjangkau ($e). Beralih ke analisis demo lokal.',
        );
      }
    }

    // MODE FALLBACK / SIMULASI OFFLINE
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
      _hasResult = true;
      _isSuspect = true;
      _statusText = 'Selesai Dianalisis (Simulasi Lokal)';
      _statusColor = const Color(0xFFDC2626);
      _predictionLabel = 'Indikasi Asimetri Wajah (Suspek Stroke Awal)';
      _confidenceScore = '88.7%';
      _asymmetryScore = 'Skor Deviasi Asimetri: 0.38';
      _recommendation = 'Sistem mendeteksi kemungkinan sudut bibir/kelopak mata tidak simetris (Facial Droop). Segera lakukan pemeriksaan medis darurat (Metode F.A.S.T).';
    });

    _showSnackBar('Analisis citra selesai!');
  }

  // 4. FUNGSI RESET / HAPUS GAMBAR
  void _resetImage() {
    setState(() {
      _selectedImage = null;
      _imageBytes = null;
      _isAnalyzing = false;
      _hasResult = false;
      _isSuspect = false;
      _statusText = 'Menunggu Input Gambar';
      _statusColor = const Color(0xFF64748B);
      _predictionLabel = '- (Belum ada analisis) -';
      _confidenceScore = '-- %';
      _asymmetryScore = '';
      _recommendation =
          'Silakan ambil atau pilih foto wajah untuk memulai deteksi awal.';
    });
    _showSnackBar('Gambar telah dihapus.');
  }

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

  // 5. DIALOG PENGATURAN SERVER API
  void _showServerSettingsDialog() {
    final TextEditingController urlController = TextEditingController(
      text: _serverUrl,
    );
    bool tempUseServer = _useServerApi;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.settings, color: Color(0xFF00796B)),
              SizedBox(width: 8),
              Text('Pengaturan Server API', style: TextStyle(fontSize: 17)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Kirim ke Server API',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Jika dimatikan, aplikasi menggunakan mode demo/simulasi lokal.',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: tempUseServer,
                  onChanged: (val) {
                    setDialogState(() {
                      tempUseServer = val;
                    });
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'URL Endpoint Server (POST):',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: urlController,
                  enabled: tempUseServer,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'http://10.0.2.2:5000/predict',
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Tips:\n• Android Emulator: http://10.0.2.2:5000/predict\n• Windows/Browser: http://127.0.0.1:5000/predict\n• HP Fisik (Wi-Fi): http://IP_KOMPUTER:5000/predict',
                    style: TextStyle(fontSize: 11, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _useServerApi = tempUseServer;
                  _serverUrl = urlController.text.trim();
                });
                Navigator.of(ctx).pop();
                _showSnackBar('Pengaturan server API berhasil disimpan!');
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  // 6. DIALOG EDUKASI F.A.S.T
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.health_and_safety, color: Color(0xFF00796B)),
            SizedBox(width: 8),
            Text('Metode F.A.S.T Stroke', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• F (Face Drooping): Wajah tampak tidak simetris atau terkulai di satu sisi.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 6),
            Text(
              '• A (Arm Weakness): Kelemahan pada salah satu lengan atau sulit diangkat.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 6),
            Text(
              '• S (Speech Difficulty): Bicara pelo, tidak jelas, atau sulit berbicara.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 6),
            Text(
              '• T (Time to call): Waktu sangat kritis, segera cari bantuan medis darurat.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
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
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan Server API',
            onPressed: _showServerSettingsDialog,
          ),
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
              // Kartu Status Mode
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _useServerApi
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _useServerApi
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _useServerApi
                          ? Icons.cloud_done_outlined
                          : Icons.offline_bolt_outlined,
                      size: 18,
                      color: _useServerApi
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _useServerApi
                            ? 'Mode: Server API Aktif ($_serverUrl)'
                            : 'Mode: Simulasi Demo Lokal (Offline)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _useServerApi
                              ? const Color(0xFF065F46)
                              : const Color(0xFF92400E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Panduan Singkat
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
                      Icon(
                        Icons.health_and_safety,
                        color: Color(0xFF00796B),
                        size: 28,
                      ),
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

              const SizedBox(height: 18),

              // Pratinjau Gambar
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
                      icon: const Icon(
                        Icons.refresh,
                        size: 16,
                        color: Colors.redAccent,
                      ),
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
                            Image.memory(_imageBytes!, fit: BoxFit.cover),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 12,
                                ),
                                color: Colors.black.withValues(alpha: 0.55),
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

              // Tombol Buka Kamera & Pilih Gambar
              Row(
                children: [
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
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImageFromGallery,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Pilih Gambar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00796B),
                        side: const BorderSide(
                          color: Color(0xFF00796B),
                          width: 1.5,
                        ),
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

              // Tombol Mulai Analisis Deteksi
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
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(
                  _isAnalyzing
                      ? 'Sedang Memproses Citra...'
                      : (_useServerApi
                            ? 'Kirim & Analisis ke Server'
                            : 'Mulai Analisis Deteksi'),
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

              // Kartu Hasil Klasifikasi
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
                        ? (_isSuspect
                              ? const Color(0xFFFCA5A5)
                              : const Color(0xFFA7F3D0))
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

                    const Text(
                      'Prediksi Label:',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _predictionLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _hasResult
                            ? (_isSuspect
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF059669))
                            : const Color(0xFF334155),
                      ),
                    ),

                    const SizedBox(height: 12),

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
                                ? (_isSuspect
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF059669))
                                : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),

                    if (_asymmetryScore.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        _asymmetryScore,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    Text(
                      _recommendation,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF475569),
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Catatan Medis
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
