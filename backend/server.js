// REST API Laporin: Express + SQLite + JWT
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { db, setCode } = require('./db');

const SECRET = process.env.JWT_SECRET || 'laporin-dev-secret';
const PORT = process.env.PORT || 3000;
const DEV = process.env.NODE_ENV !== 'production';
const app = express();
app.use(cors());
app.use(express.json());

const fail = (res, code, error, extra = {}) => res.status(code).json({ error, ...extra });
const sign = (u) => jwt.sign({ id: u.id }, SECRET, { expiresIn: '30d' });
const pub = (u) => ({ id: u.id, email: u.email, name: u.name, phone: u.phone, location: u.location });

function auth(req, res, next) {
  const h = req.headers.authorization || '';
  try {
    const { id } = jwt.verify(h.replace('Bearer ', ''), SECRET);
    req.user = db.prepare('SELECT * FROM users WHERE id=?').get(id);
    if (!req.user) throw new Error();
    next();
  } catch { fail(res, 401, 'Sesi berakhir, silakan login kembali'); }
}

function issueOtp(user) {
  const otp = String(Math.floor(100000 + Math.random() * 900000));
  db.prepare('UPDATE users SET otp=?, otp_expires=? WHERE id=?').run(otp, Date.now() + 10 * 60 * 1000, user.id);
  console.log(`[OTP] ${user.email}: ${otp}`);
  return DEV ? { devOtp: otp } : {};
}

// ---------- AUTH ----------
app.post('/auth/register', (req, res) => {
  const { email, password } = req.body || {};
  if (!/^\S+@\S+\.\S+$/.test(email || '')) return fail(res, 400, 'Format email tidak valid');
  if ((password || '').length < 6) return fail(res, 400, 'Password minimal 6 karakter');
  const exist = db.prepare('SELECT * FROM users WHERE email=?').get(email.toLowerCase());
  if (exist && exist.verified) return fail(res, 409, 'Email sudah terdaftar, silakan log in');
  const hash = bcrypt.hashSync(password, 10);
  let user = exist;
  if (exist) db.prepare('UPDATE users SET password_hash=? WHERE id=?').run(hash, exist.id);
  else {
    const id = db.prepare('INSERT INTO users (email,password_hash,name) VALUES (?,?,?)')
      .run(email.toLowerCase(), hash, email.split('@')[0]).lastInsertRowid;
    user = { id, email: email.toLowerCase() };
  }
  res.json({ message: 'Kode OTP dikirim', ...issueOtp(user) });
});

app.post('/auth/resend-otp', (req, res) => {
  const user = db.prepare('SELECT * FROM users WHERE email=?').get((req.body.email || '').toLowerCase());
  if (!user || user.verified) return fail(res, 404, 'Akun tidak ditemukan');
  res.json({ message: 'Kode OTP dikirim ulang', ...issueOtp(user) });
});

app.post('/auth/verify-otp', (req, res) => {
  const user = db.prepare('SELECT * FROM users WHERE email=?').get((req.body.email || '').toLowerCase());
  if (!user || user.otp !== String(req.body.otp) || Date.now() > user.otp_expires)
    return fail(res, 400, 'Kode OTP salah atau kedaluwarsa');
  db.prepare('UPDATE users SET verified=1, otp=NULL WHERE id=?').run(user.id);
  res.json({ token: sign(user), user: pub(user) });
});

app.post('/auth/login', (req, res) => {
  const user = db.prepare('SELECT * FROM users WHERE email=?').get((req.body.email || '').toLowerCase());
  if (!user || !bcrypt.compareSync(req.body.password || '', user.password_hash)) return fail(res, 401, 'Email atau password salah');
  if (!user.verified) return fail(res, 403, 'Akun belum diverifikasi', { needOtp: true, ...issueOtp(user) });
  res.json({ token: sign(user), user: pub(user) });
});

// ---------- BERANDA ----------
const counts = (uid) => {
  const rows = db.prepare('SELECT status, COUNT(*) c FROM reports WHERE user_id=? GROUP BY status').all(uid);
  const o = { belum: 0, sedang: 0, selesai: 0 };
  rows.forEach(r => (o[r.status] = r.c));
  return { ...o, total: o.belum + o.sedang + o.selesai };
};

app.get('/home', auth, (req, res) => {
  const s = db.prepare(`SELECT COUNT(*) total,
      SUM(status='selesai') done,
      AVG(CASE WHEN resolved_at IS NOT NULL THEN julianday(resolved_at)-julianday(created_at) END) avg_days,
      COUNT(DISTINCT user_id) reporters FROM reports`).get();
  res.json({
    user: pub(req.user),
    counts: counts(req.user.id),
    latest: db.prepare('SELECT * FROM reports WHERE user_id=? ORDER BY created_at DESC, id DESC LIMIT 1').get(req.user.id) || null,
    stats: {
      total: s.total,
      done_pct: s.total ? Math.round((s.done / s.total) * 1000) / 10 : 0,
      avg_days: Math.round((s.avg_days || 0) * 10) / 10,
      reporters: s.reporters,
    },
    done: db.prepare(`SELECT id,title,location FROM reports WHERE status='selesai' ORDER BY resolved_at DESC LIMIT 2`).all(),
    alerts: db.prepare(`SELECT * FROM news WHERE kind='peringatan' ORDER BY id DESC LIMIT 2`).all(),
  });
});

// ---------- LAPORAN ----------
app.get('/reports', auth, (req, res) => {
  const { status } = req.query;
  const rows = status && ['belum', 'sedang', 'selesai'].includes(status)
    ? db.prepare('SELECT * FROM reports WHERE user_id=? AND status=? ORDER BY created_at DESC, id DESC').all(req.user.id, status)
    : db.prepare('SELECT * FROM reports WHERE user_id=? ORDER BY created_at DESC, id DESC').all(req.user.id);
  res.json({ counts: counts(req.user.id), reports: rows });
});

app.post('/reports', auth, (req, res) => {
  const { category, title, description, location } = req.body || {};
  if (!['pemerintahan', 'kriminal'].includes(category)) return fail(res, 400, 'Kategori tidak valid');
  if (!(title || '').trim()) return fail(res, 400, 'Judul laporan wajib diisi');
  const r = db.prepare('INSERT INTO reports (user_id,category,title,description,location) VALUES (?,?,?,?,?)')
    .run(req.user.id, category, title.trim(), (description || '').trim(), (location || req.user.location || '').trim());
  const row = db.prepare('SELECT * FROM reports WHERE id=?').get(r.lastInsertRowid);
  setCode(row.id, row.category, row.created_at);
  res.status(201).json(db.prepare('SELECT * FROM reports WHERE id=?').get(row.id));
});

app.get('/reports/:id', auth, (req, res) => {
  const r = db.prepare('SELECT * FROM reports WHERE id=? AND user_id=?').get(req.params.id, req.user.id);
  r ? res.json(r) : fail(res, 404, 'Laporan tidak ditemukan');
});

app.patch('/reports/:id/status', auth, (req, res) => {
  const { status } = req.body || {};
  if (!['belum', 'sedang', 'selesai'].includes(status)) return fail(res, 400, 'Status tidak valid');
  const r = db.prepare('SELECT * FROM reports WHERE id=? AND user_id=?').get(req.params.id, req.user.id);
  if (!r) return fail(res, 404, 'Laporan tidak ditemukan');
  db.prepare(`UPDATE reports SET status=?,
    verified_at = CASE WHEN ?!='belum' AND verified_at IS NULL THEN datetime('now') ELSE verified_at END,
    resolved_at = CASE WHEN ?='selesai' THEN datetime('now') ELSE NULL END WHERE id=?`).run(status, status, status, r.id);
  res.json(db.prepare('SELECT * FROM reports WHERE id=?').get(r.id));
});

// ---------- BERITA ----------
app.get('/news', auth, (req, res) =>
  res.json(db.prepare(`SELECT * FROM news WHERE kind='berita' ORDER BY is_main DESC, id DESC`).all()));

// ---------- PROFIL ----------
app.get('/profile', auth, (req, res) => {
  const c = counts(req.user.id);
  res.json({ user: pub(req.user), total: c.total, selesai: c.selesai });
});

app.put('/profile', auth, (req, res) => {
  const { name, phone, location } = req.body || {};
  if (!(name || '').trim()) return fail(res, 400, 'Nama wajib diisi');
  db.prepare('UPDATE users SET name=?, phone=?, location=? WHERE id=?')
    .run(name.trim(), (phone || '').trim() || null, (location || '').trim() || 'Kota Medan', req.user.id);
  res.json(pub(db.prepare('SELECT * FROM users WHERE id=?').get(req.user.id)));
});

app.get('/', (_, res) => res.json({ app: 'Laporin API', ok: true }));
app.listen(PORT, () => console.log(`Laporin API berjalan di http://localhost:${PORT}`));
