"""
Backend Server API - Deteksi Gejala Stroke Awal
Tugas Akhir Pengolahan Citra dan Visi Komputer (PCVK)

Cara Menjalankan:
1. Pastikan Flask terpasang: pip install flask flask-cors
2. Jalankan server: python app.py
3. Server akan berjalan di: http://0.0.0.0:5000/predict
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import random
import time

app = Flask(__name__)
CORS(app)  # Memungkinkan request cross-origin dari aplikasi Flutter

@app.route('/', methods=['GET'])
def index():
    return jsonify({
        "status": "online",
        "service": "API Deteksi Gejala Stroke Awal (PCVK)",
        "endpoint": "/predict (POST, multipart/form-data)"
    })

@app.route('/predict', methods=['POST'])
def predict():
    # 1. Validasi apakah ada file yang dikirim
    if 'image' not in request.files and 'file' not in request.files:
        return jsonify({
            "status": "error",
            "message": "Tidak ada file gambar yang dikirim (gunakan field 'image' atau 'file')."
        }), 400

    file = request.files.get('image') or request.files.get('file')

    if file.filename == '':
        return jsonify({
            "status": "error",
            "message": "Nama file kosong."
        }), 400

    filename = file.filename
    print(f"[*] Menerima gambar untuk dianalisis: {filename}")

    # Simulasi pembacaan dan pemrosesan citra (bisa diintegrasikan dengan OpenCV/MediaPipe/TFLite)
    time.sleep(1.5)

    # Contoh hasil deteksi citra (bisa diganti dengan model machine learning tim kamu)
    # Di sini disiapkan logika contoh:
    labels = [
        {
            "label": "Indikasi Asimetri Wajah (Suspek Stroke Awal)",
            "is_stroke_suspect": True,
            "confidence": round(random.uniform(85.0, 96.5), 1),
            "face_asymmetry_score": 0.42,
            "recommendation": "Terdeteksi asimetri signifikan pada kontur bibir/mata (Facial Droop). Segera lakukan pemeriksaan medis darurat (Metode F.A.S.T)."
        },
        {
            "label": "Wajah Simetris (Normal)",
            "is_stroke_suspect": False,
            "confidence": round(random.uniform(90.0, 98.0), 1),
            "face_asymmetry_score": 0.08,
            "recommendation": "Tidak terdeteksi indikasi kelumpuhan atau asimetri wajah yang mencolok. Kondisi fitur wajah tampak normal."
        }
    ]

    # Ambil salah satu contoh hasil (atau pasang inferensi model AI di sini)
    result = labels[0]

    return jsonify({
        "status": "success",
        "filename": filename,
        "label": result["label"],
        "is_stroke_suspect": result["is_stroke_suspect"],
        "confidence": result["confidence"],
        "asymmetry_score": result["face_asymmetry_score"],
        "recommendation": result["recommendation"],
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
    }), 200

if __name__ == '__main__':
    # Berjalan di port 5000 pada semua interface
    app.run(host='0.0.0.0', port=5000, debug=True)
