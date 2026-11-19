# Backend Server API - Deteksi Gejala Stroke Awal (PCVK)

Backend ini bertugas menerima file gambar dari aplikasi Flutter, melakukan analisis citra (asimetri wajah / facial droop), dan mengembalikan hasil klasifikasi dalam format JSON.

## Cara Menjalankan Server:

1. Buka terminal di folder backend:
   ```bash
   cd d:\PROJECT-AKHIRPCVK\backend
   ```
2. Pasang dependensi:
   ```bash
   pip install -r requirements.txt
   ```
3. Jalankan server:
   ```bash
   python app.py
   ```
4. Server akan aktif di port 5000:
   - Akses dari Android Emulator: `http://10.0.2.2:5000/predict`
   - Akses dari Komputer/Browser: `http://127.0.0.1:5000/predict`
   - Akses dari HP Fisik lewat Wi-Fi: `http://<IP_KOMPUTER_KAMU>:5000/predict`
