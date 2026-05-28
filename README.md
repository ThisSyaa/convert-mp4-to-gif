# 🎬 MP4 to GIF Converter — CLI Tool

Konversi video MP4 menjadi GIF animasi berkualitas tinggi langsung dari terminal, tanpa aplikasi tambahan. Menggunakan teknik **Two-Pass Color Palette** via FFmpeg untuk hasil yang tajam dan warna akurat.

---

## ✨ Fitur Utama

- **Two-Pass Palette** — Menghasilkan GIF dengan 256 warna optimal khusus per video (bukan palet generik)
- **Trimming / Pemotongan** — Pilih titik mulai dan durasi GIF secara presisi
- **3 Preset Kualitas** — Standard Web, Social Media HD, dan Lightweight Thumbnail
- **Scaling Lanczos** — Algoritma resize berkualitas tinggi, minim blur
- **Interaktif** — Cukup jalankan skrip dan ikuti instruksi di terminal
- **Cross-platform** — Tersedia untuk Linux, macOS, dan Windows

---

## 📋 Persyaratan

**FFmpeg** harus sudah terinstal di sistem Anda.

```bash
# Linux (Ubuntu/Debian)
sudo apt update && sudo apt install -y ffmpeg

# macOS
brew install ffmpeg

# Windows
# Download dari https://ffmpeg.org/ → daftarkan folder bin ke Environment Variables (Path)
```

Verifikasi instalasi:
```bash
ffmpeg -version
```

---

## 📁 Struktur Direktori

```
mp4-to-gif-cli/
├── video_input/        # Taruh file MP4 di sini
├── gif_output/         # Hasil GIF tersimpan otomatis di sini
├── konversi_gif.sh     # Skrip untuk Linux / macOS
└── konversi_gif.bat    # Skrip untuk Windows
```

Folder `video_input/` dan `gif_output/` akan dibuat otomatis saat skrip pertama kali dijalankan.

---

## 🚀 Cara Penggunaan

### Linux / macOS

```bash
# 1. Beri izin eksekusi (hanya perlu sekali)
chmod +x konversi_gif.sh

# 2. Pindahkan video MP4 ke folder input
cp video-saya.mp4 video_input/

# 3. Jalankan skrip
./konversi_gif.sh
```

### Windows

```
1. Pindahkan file MP4 ke dalam folder video_input\
2. Klik dua kali file konversi_gif.bat
3. Ikuti instruksi yang muncul di Command Prompt
```

---

## 🎛️ Menu Interaktif

Saat skrip dijalankan, Anda akan diminta mengisi beberapa parameter:

```
=================================================
     SISTEM KONVERSI MP4 KE GIF (TERMINAL)
=================================================
Daftar file di folder 'video_input':
  demo.mp4
-------------------------------------------------
Masukkan nama file video (contoh: contoh.mp4): demo.mp4

[Pengaturan Durasi] Maksimal rekomendasi 60 detik.
Mulai dari detik ke berapa? (misal: 0 atau 12.5): 5
Berapa lama durasi GIF? (misal: 5): 8

[Pilihan Kualitas Preset]:
1) Standard Web (Lebar 480px, 15 FPS) - Rekomendasi Blog
2) Social Media / HD (Lebar 720px, 24 FPS) - Gambar Tajam
3) Lightweight / Thumbnail (Lebar 320px, 10 FPS) - Ukuran Kecil
Pilih preset (1-3): 2
```

---

## 📐 Tabel Preset Kualitas

| Preset | Lebar | FPS | Cocok Untuk | Estimasi Ukuran* |
|--------|-------|-----|-------------|-----------------|
| Standard Web | 480px | 15 | Blog, forum, dokumentasi | ~2–5 MB / 10 detik |
| Social Media HD | 720px | 24 | Twitter, Slack, presentasi | ~5–12 MB / 10 detik |
| Lightweight | 320px | 10 | Email, thumbnail, preview | ~0.5–2 MB / 10 detik |

*Estimasi ukuran bergantung pada kompleksitas visual video sumber.*

---

## ⚙️ Cara Kerja (Two-Pass Palette)

Format GIF hanya mendukung maksimal **256 warna**. Konversi langsung (one-pass) menghasilkan gambar berbintik dan warna rusak. Skrip ini menggunakan teknik dua tahap:

```
Pass 1 — palettegen
  MP4 ──► Analisis warna dominan ──► palette.png (256 warna optimal)

Pass 2 — paletteuse
  MP4 + palette.png ──► GIF berkualitas tinggi
```

Perintah FFmpeg yang dieksekusi secara internal:

```bash
# Pass 1
ffmpeg -ss [START] -t [DURASI] -i input.mp4 \
  -vf "fps=[FPS],scale=[WIDTH]:-1:flags=lanczos,palettegen" palette.png

# Pass 2
ffmpeg -ss [START] -t [DURASI] -i input.mp4 -i palette.png \
  -lavfi "fps=[FPS],scale=[WIDTH]:-1:flags=lanczos [x]; [x][1:v] paletteuse" output.gif
```

---

## 📝 Penamaan File Output

File GIF hasil konversi diberi nama otomatis berdasarkan parameter yang dipilih:

```
{nama_file}_t{detik_mulai}_{lebar}px.gif

Contoh:
  demo_t5_720px.gif    ← dari demo.mp4, mulai detik 5, lebar 720px
  clip_t0_480px.gif    ← dari clip.mp4, mulai detik 0, lebar 480px
```

---

## ❗ Tips & Catatan

- **Durasi maksimal** yang direkomendasikan adalah **60 detik** — GIF lebih panjang dari itu akan menghasilkan file yang sangat besar.
- **Aspect ratio** dipertahankan otomatis. Jika lebar diset ke 480px, tinggi akan menyesuaikan secara proporsional.
- Jika konversi gagal, pastikan nama file tidak mengandung spasi. Ganti spasi dengan underscore `_` atau tanda hubung `-`.
- File palet sementara (`gif_palette.png`) dihapus otomatis setelah proses selesai.

---

## 🔧 Dependensi

| Dependensi | Versi Minimum | Keterangan |
|-----------|--------------|------------|
| FFmpeg | 4.0+ | Core engine konversi |
| Bash | 3.2+ | Runtime skrip (Linux/macOS) |
| CMD / batch | — | Runtime skrip (Windows) |

---

## 📄 Lisensi

Proyek ini bebas digunakan dan dimodifikasi untuk keperluan pribadi maupun komersial.
