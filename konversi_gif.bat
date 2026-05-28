@echo off
setlocal enabledelayedexpansion

set INPUT_DIR=video_input
set OUTPUT_DIR=gif_output
set TEMP_PALETTE=gif_palette.png

if not exist %INPUT_DIR% mkdir %INPUT_DIR%
if not exist %OUTPUT_DIR% mkdir %OUTPUT_DIR%

echo =================================================
echo      SISTEM KONVERSI MP4 KE GIF (WINDOWS)        
echo =================================================
echo Daftar file di folder '%INPUT_DIR%':
dir /b %INPUT_DIR%
echo -------------------------------------------------
set /p FILENAME="Masukkan nama file video (contoh: video.mp4): "

set INPUT_PATH=%INPUT_DIR%\%FILENAME%

if not exist "%INPUT_PATH%" (
    echo Error: File "%INPUT_PATH%" tidak ditemukan!
    pause
    exit /b
)

echo.
echo [Pengaturan Durasi]
set /p START_TIME="Mulai dari detik ke berapa? (misal: 0 atau 5): "
set /p DURATION="Berapa lama durasi GIF yang ingin diambil? (misal: 4): "

echo.
echo [Pilihan Kualitas Preset]:
echo 1) Standard Web (Lebar 480px, 15 FPS)
echo 2) Social Media / HD (Lebar 720px, 24 FPS)
echo 3) Lightweight / Thumbnail (Lebar 320px, 10 FPS)
set /p PRESET_CHOICE="Pilih preset (1-3): "

if "%PRESET_CHOICE%"=="1" (
    set WIDTH=480
    set FPS=15
) else if "%PRESET_CHOICE%"=="2" (
    set WIDTH=720
    set FPS=24
) else if "%PRESET_CHOICE%"=="3" (
    set WIDTH=320
    set FPS=10
) else (
    set WIDTH=480
    set FPS=15
    echo Pilihan salah, menggunakan Standard Web.
)

:: Mengambil nama file tanpa ekstensi untuk output
for %%i in ("%FILENAME%") do set FILENAME_NO_EXT=%%~ni
set OUTPUT_PATH=%OUTPUT_DIR%\%FILENAME_NO_EXT%_t%START_TIME%_%WIDTH%px.gif

echo.
echo Sedang memproses... Tunggu sebentar...

:: Pass 1: Generate Palette
ffmpeg -y -ss %START_TIME% -t %DURATION% -i "%INPUT_PATH%" -vf "fps=%FPS%,scale=%WIDTH%:-1:flags=lanczos,palettegen" %TEMP_PALETTE%

:: Pass 2: Apply Palette ke GIF
ffmpeg -y -ss %START_TIME% -t %DURATION% -i "%INPUT_PATH%" -i %TEMP_PALETTE% -lavfi "fps=%FPS%,scale=%WIDTH%:-1:flags=lanczos [x]; [x][1:v] paletteuse" "%OUTPUT_PATH%"

if %errorlevel% equ 0 (
    echo -------------------------------------------------
    echo STATUS: KONVERSI BERHASIL!
    echo Hasil disimpan di: %OUTPUT_PATH%
    echo =================================================
) else (
    echo STATUS: KONVERSI GAGAL!
)

:: Hapus palet sementara
if exist %TEMP_PALETTE% del %TEMP_PALETTE%
pause
