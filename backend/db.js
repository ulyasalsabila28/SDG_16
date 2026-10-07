const { DatabaseSync } = require('node:sqlite');
const bcrypt = require('bcryptjs');
const db = new DatabaseSync(process.env.DB_FILE || 'laporin.db');
db.exec('PRAGMA journal_mode = WAL; PRAGMA foreign_keys = ON;');

db.exec(`
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  location TEXT DEFAULT 'Kota Medan',
  verified INTEGER DEFAULT 0,
  otp TEXT,
  otp_expires INTEGER,
  created_at TEXT DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS reports (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category TEXT NOT NULL CHECK (category IN ('pemerintahan','kriminal')),
  title TEXT NOT NULL,
  description TEXT,
  location TEXT,
  status TEXT NOT NULL DEFAULT 'belum' CHECK (status IN ('belum','sedang','selesai')),
  created_at TEXT DEFAULT (datetime('now')),
  verified_at TEXT,
  resolved_at TEXT
);
CREATE INDEX IF NOT EXISTS idx_reports_user ON reports(user_id, status);
CREATE TABLE IF NOT EXISTS news (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  kind TEXT NOT NULL CHECK (kind IN ('berita','peringatan')),
  title TEXT NOT NULL,
  summary TEXT,
  body TEXT,
  location TEXT,
  is_main INTEGER DEFAULT 0,
  created_at TEXT DEFAULT (datetime('now'))
);
`);

function seed() {
  if (db.prepare('SELECT COUNT(*) c FROM users').get().c > 0) return;
  const hash = bcrypt.hashSync('demo1234', 10);
  const demo = db.prepare(`INSERT INTO users (email,password_hash,name,location,verified)
    VALUES ('demo@laporin.id',?, 'Prabowo Subianto Sastrawidjoyo','Kota Medan',1)`).run(hash).lastInsertRowid;
  const warga = [];
  for (const n of ['Siti', 'Budi', 'Rina', 'Andi']) {
    warga.push(db.prepare(`INSERT INTO users (email,password_hash,name,verified) VALUES (?,?,?,1)`)
      .run(`${n.toLowerCase()}@laporin.id`, hash, n).lastInsertRowid);
  }
  const ins = db.prepare(`INSERT INTO reports (user_id,category,title,description,location,status,created_at,verified_at,resolved_at)
    VALUES (?,?,?,?,?,?,datetime('now',?),?,?)`);
  const mk = (uid, cat, title, loc, status, ago, dur) => {
    const v = status === 'belum' ? null : `datetime('now','-${ago - 1} days')`;
    const r = ins.run(uid, cat, title, 'Laporan warga: ' + title, loc, status, `-${ago} days`, null, null);
    const id = r.lastInsertRowid;
    if (status !== 'belum') db.prepare(`UPDATE reports SET verified_at=datetime(created_at,'+1 day') WHERE id=?`).run(id);
    if (status === 'selesai') db.prepare(`UPDATE reports SET verified_at=datetime(created_at,'+1 day'), resolved_at=datetime(created_at,'+${dur} days') WHERE id=?`).run(id);
  };
  const demoRows = [
    ['pemerintahan', 'Jalan berlubang membahayakan pengguna jalan', 'Medan Barat, Kota Medan', 'sedang', 4, 0],
    ['pemerintahan', 'Lampu penerangan jalan padam di Jl. Merdeka', 'Medan Barat, Kota Medan', 'belum', 3, 0],
    ['pemerintahan', 'Perbaikan jalan di Jl. Gatot Subroto', 'Medan Petisah, Kota Medan', 'selesai', 12, 3],
    ['pemerintahan', 'Drainase tersumbat di Jl. Sudirman', 'Medan Petisah, Kota Medan', 'sedang', 6, 0],
    ['kriminal', 'Pencurian sepeda motor di area parkir', 'Medan Baru, Kota Medan', 'sedang', 7, 0],
    ['pemerintahan', 'Perbaikan jalan berlubang di Jalan Merdeka', 'Jl. Tanah Abang, Kec. Tanah Abang', 'selesai', 20, 2],
    ['pemerintahan', 'Lampu penerangan kembali berfungsi', 'Setiabudi', 'selesai', 18, 2],
    ['pemerintahan', 'Taman kota rusak', 'Medan Petisah, Kota Medan', 'selesai', 25, 4],
    ['pemerintahan', 'Sampah menumpuk di pasar', 'Medan Kota, Kota Medan', 'belum', 2, 0],
    ['kriminal', 'Pungutan liar di terminal', 'Medan Amplas, Kota Medan', 'selesai', 28, 5],
    ['pemerintahan', 'Trotoar rusak', 'Medan Timur, Kota Medan', 'selesai', 35, 3],
    ['pemerintahan', 'Rambu lalu lintas roboh', 'Medan Selayang, Kota Medan', 'selesai', 40, 2],
    ['pemerintahan', 'Air PDAM tidak mengalir', 'Medan Helvetia, Kota Medan', 'selesai', 45, 3],
  ];
  demoRows.forEach(r => mk(demo, r[0], r[1], r[2], r[3], r[4], r[5]));
  const komunitas = ['Jembatan retak', 'Banjir di permukiman', 'Pohon tumbang', 'Kebisingan pabrik', 'Parkir liar'];
  komunitas.forEach((t, i) => mk(warga[i % 4], 'pemerintahan', t, 'Kota Medan', i % 2 ? 'sedang' : 'selesai', 10 + i, 2 + i));
  // kode laporan
  for (const r of db.prepare('SELECT id,category,created_at FROM reports').all()) setCode(r.id, r.category, r.created_at);

  const n = db.prepare('INSERT INTO news (kind,title,summary,body,location,is_main) VALUES (?,?,?,?,?,?)');
  n.run('berita', 'Perbaikan jalan berlubang di Medan Barat', 'Perbaikan jalan dilakukan untuk meningkatkan kenyamanan dan keselamatan warga.', 'Pemerintah kota melakukan perbaikan jalan berlubang di sejumlah ruas Medan Barat. Pekerjaan dilakukan bertahap agar arus lalu lintas tetap lancar dan diharapkan selesai dalam satu pekan.', 'Kota Medan', 1);
  n.run('berita', 'Taman kota Medan Petisah kembali dibuka', 'Fasilitas bermain dan area istirahat kini sudah nyaman.', 'Taman kota Medan Petisah kembali dibuka untuk umum setelah perbaikan fasilitas bermain, tempat duduk, dan penerangan.', 'Kota Medan', 0);
  n.run('berita', 'Penambahan 50 titik lampu jalan', 'Penerangan ruas jalan yang dilaporkan gelap.', 'Sebanyak 50 titik lampu jalan baru dipasang pada ruas yang sering dilaporkan warga gelap pada malam hari.', 'Kota Medan', 0);
  n.run('berita', 'Gotong royong membersihkan drainase', 'Warga bersama relawan mengurangi potensi genangan.', 'Warga dan relawan membersihkan saluran drainase untuk mengurangi potensi genangan saat musim hujan.', 'Kota Medan', 0);
  n.run('peringatan', 'Kenali modus penipuan digital yang sedang marak', 'Pada Hari ini', 'Waspadai pesan yang meminta kode OTP, tautan mencurigakan, dan tawaran hadiah. Jangan pernah membagikan kode OTP kepada siapa pun.', 'Kota Medan', 0);
  n.run('peringatan', 'Peningkatan layanan pengaduan publik terpadu', 'Pemprov DKI Jakarta', 'Layanan pengaduan publik terpadu ditingkatkan agar laporan warga ditindaklanjuti lebih cepat.', 'Kota Medan', 0);
}

function setCode(id, category, createdAt) {
  const d = String(createdAt).slice(0, 10).replace(/-/g, '');
  const code = `LPR-${category === 'kriminal' ? 'KRI' : 'PEM'}-${d}-${String(id).padStart(4, '0')}`;
  db.prepare('UPDATE reports SET code=? WHERE id=?').run(code, id);
}

seed();
module.exports = { db, setCode };
