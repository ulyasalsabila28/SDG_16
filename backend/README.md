# Laporin Backend (Node.js + SQLite)
    cd backend
    npm install
    npm start        # http://localhost:3000
Akun demo: demo@laporin.id / demo1234
Database: SQLite bawaan Node.js (perlu Node 22.13 atau lebih baru), file `laporin.db` dibuat otomatis. Hapus file itu untuk reset.
Kode OTP tampil di terminal server dan (mode dev) ikut dikirim ke aplikasi.
Produksi: set NODE_ENV=production, JWT_SECRET, dan sambungkan layanan email untuk OTP.
