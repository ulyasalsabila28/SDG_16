# Laporin (Flutter + Node.js/SQLite)

## 1. Jalankan backend
    cd backend
    npm install
    npm start            # http://localhost:3000
Akun demo: demo@laporin.id / demo1234.

## 2. Jalankan aplikasi
    flutter pub get
    flutter run -d chrome        # web
    flutter run                  # mobile (emulator Android otomatis memakai 10.0.2.2:3000)
HP fisik: flutter run --dart-define=API_URL=http://IP_KOMPUTER:3000