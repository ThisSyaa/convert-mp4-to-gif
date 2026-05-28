#!/bin/bash

# Konfigurasi Folder
INPUT_DIR="video_input"
OUTPUT_DIR="gif_output"
TEMP_PALETTE="/tmp/gif_palette.png"

# Membuat folder jika belum ada
mkdir -p "$INPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "================================================="
echo "     SISTEM KONVERSI MP4 KE GIF (TERMINAL)       "
echo "================================================="

# 1. Pilih File MP4
echo "Daftar file di folder '$INPUT_DIR':"
ls -1 "$INPUT_DIR" 2>/dev/null
echo "-------------------------------------------------"
read -p "Masukkan nama file video (contoh: contoh.mp4): " FILENAME

INPUT_PATH="$INPUT_DIR/$FILENAME"

# Validasi keberadaan file
if [ ! -f "$INPUT_PATH" ]; then
    echo "Error: File '$INPUT_PATH' tidak ditemukan!"
    exit 1
fi

# 2. Input Pemotongan Durasi (Trimming)
echo -e "\n[Pengaturan Durasi] Maksimal rekomendasi 60 detik."
read -p "Mulai dari detik ke berapa? (Format detik, misal: 0 atau 12.5): " START_TIME
read -p "Berapa lama durasi GIF yang ingin diambil? (Format detik, misal: 5): " DURATION

# 3. Pilih Preset Kualitas
echo -e "\n[Pilihan Kualitas Preset]:"
echo "1) Standard Web (Lebar 480px, 15 FPS) - Rekomendasi Blog"
echo "2) Social Media / HD (Lebar 720px, 24 FPS) - Gambar Tajam"
echo "3) Lightweight / Thumbnail (Lebar 320px, 10 FPS) - Ukuran Kecil"
read -p "Pilih preset (1-3): " PRESET_CHOICE

case $PRESET_CHOICE in
    1) WIDTH=480; FPS=15 ;;
    2) WIDTH=720; FPS=24 ;;
    3) WIDTH=320; FPS=10 ;;
    *) WIDTH=480; FPS=15; echo "Pilihan salah, menggunakan Standard Web." ;;
esac

# Tentukan nama file output
OUTPUT_FILENAME="${FILENAME%.*}_t${START_TIME}_${WIDTH}px.gif"
OUTPUT_PATH="$OUTPUT_DIR/$OUTPUT_FILENAME"

echo -e "\nMemulai pemrosesan konversi..."

# PASS 1: Membuat Palet Warna Optimal
ffmpeg -y -ss "$START_TIME" -t "$DURATION" -i "$INPUT_PATH" \
    -vf "fps=$FPS,scale=$WIDTH:-1:flags=lanczos,palettegen" "$TEMP_PALETTE" 2>/dev/null

# PASS 2: Mengonversi Video ke GIF Menggunakan Palet Tersebut
ffmpeg -y -ss "$START_TIME" -t "$DURATION" -i "$INPUT_PATH" -i "$TEMP_PALETTE" \
    -lavfi "fps=$FPS,scale=$WIDTH:-1:flags=lanczos [x]; [x][1:v] paletteuse" "$OUTPUT_PATH" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "-------------------------------------------------"
    echo "STATUS: CONVERSION SUCCESS!"
    echo "Hasil disimpan di: $OUTPUT_PATH"

    # Hitung ukuran file hasil
    size_bytes=$(stat -c%s "$OUTPUT_PATH" 2>/dev/null || stat -f%z "$OUTPUT_PATH")
    size_mb=$(awk "BEGIN {print sprintf(\"%.2f\", $size_bytes / 1024 / 1024)}")
    echo "Ukuran File GIF : $size_mb MB"
    echo "================================================="
else
    echo "STATUS: CONVERSION FAILED!"
fi

# Hapus file palet sementara
rm -f "$TEMP_PALETTE"
