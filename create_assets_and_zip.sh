#!/usr/bin/env bash
# Creates placeholder SVG assets, converts them to PNG (multiple sizes) if possible,
# synthesizes short WAV audio files, and packages everything into my_snake_game_assets.zip
#
# Usage:
#   chmod +x create_assets_and_zip.sh
#   ./create_assets_and_zip.sh
#
# Requirements:
#   - bash (macOS / Linux / WSL)
#   - python3 (used to synthesize WAV tones)
#   - One of: rsvg-convert (preferred) OR ImageMagick's convert (for SVG -> PNG)
#
# The script will:
#   - write SVG placeholder images to assets/images/
#   - attempt to convert SVG -> PNG at sizes 512, 256, 128 into assets/images/png/
#   - generate WAV audio files into assets/audio/
#   - create my_snake_game_assets.zip containing assets/ and README_ASSETS.md
set -e

OUT_ZIP="my_snake_game_assets.zip"
ASSETS_DIR="assets"
IMG_DIR="$ASSETS_DIR/images"
PNG_DIR="$IMG_DIR/png"
AUDIO_DIR="$ASSETS_DIR/audio"

echo "Cleaning previous outputs..."
rm -rf "$ASSETS_DIR" "$OUT_ZIP"

echo "Creating directories..."
mkdir -p "$IMG_DIR" "$PNG_DIR" "$AUDIO_DIR"

echo "Writing SVG image placeholders..."

cat > "$IMG_DIR/snake_head.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">
  <rect width="100%" height="100%" rx="20" fill="#0b3e15"/>
  <g transform="translate(40,40)">
    <circle cx="88" cy="88" r="64" fill="#4CAF50" stroke="#2E7D32" stroke-width="8"/>
    <!-- Eyes -->
    <circle cx="64" cy="72" r="10" fill="#ffffff"/>
    <circle cx="112" cy="72" r="10" fill="#ffffff"/>
    <circle cx="64" cy="72" r="5" fill="#000000"/>
    <circle cx="112" cy="72" r="5" fill="#000000"/>
    <!-- Smile -->
    <path d="M64 112 Q88 132 112 112" stroke="#1b5e20" stroke-width="6" fill="none" stroke-linecap="round"/>
  </g>
</svg>
SVG

cat > "$IMG_DIR/snake_body.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect width="100%" height="100%" rx="16" fill="#0b3e15"/>
  <rect x="16" y="16" width="96" height="96" rx="16" fill="#66bb6a" stroke="#2e7d32" stroke-width="6"/>
</svg>
SVG

cat > "$IMG_DIR/food.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect width="100%" height="100%" rx="16" fill="#0b3e15"/>
  <g transform="translate(12,8)">
    <circle cx="52" cy="52" r="40" fill="#e53935" stroke="#b71c1c" stroke-width="6"/>
    <ellipse cx="40" cy="32" rx="12" ry="6" fill="#4caf50"/>
    <path d="M48 14 Q56 6 68 12" stroke="#4caf50" stroke-width="4" fill="none"/>
    <circle cx="36" cy="42" r="8" fill="#ff8a80" opacity="0.8"/>
  </g>
</svg>
SVG

cat > "$IMG_DIR/power_speed.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect width="100%" height="100%" rx="16" fill="#0b3e15"/>
  <g transform="translate(16,16)">
    <circle cx="48" cy="48" r="36" fill="#ff9800" stroke="#ef6c00" stroke-width="6"/>
    <text x="48" y="62" font-size="36" text-anchor="middle" fill="#fff" font-family="Arial" font-weight="700">⚡</text>
  </g>
</svg>
SVG

cat > "$IMG_DIR/power_shield.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect width="100%" height="100%" rx="16" fill="#0b3e15"/>
  <g transform="translate(16,12)">
    <path d="M48 4 L92 24 L92 60 C92 92 64 108 48 116 C32 108 4 92 4 60 L4 24 Z" fill="#2196f3" stroke="#1976d2" stroke-width="6"/>
    <text x="48" y="64" font-size="28" text-anchor="middle" fill="#fff" font-family="Arial" font-weight="700">🛡️</text>
  </g>
</svg>
SVG

cat > "$IMG_DIR/power_double.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect width="100%" height="100%" rx="16" fill="#0b3e15"/>
  <g transform="translate(16,16)">
    <circle cx="48" cy="48" r="36" fill="#ffeb3b" stroke="#fbc02d" stroke-width="6"/>
    <text x="48" y="64" font-size="28" text-anchor="middle" fill="#000" font-family="Arial" font-weight="900">×2</text>
  </g>
</svg>
SVG

cat > "$IMG_DIR/power_slow.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect width="100%" height="100%" rx="16" fill="#0b3e15"/>
  <g transform="translate(16,16)">
    <circle cx="48" cy="48" r="36" fill="#9c27b0" stroke="#7b1fa2" stroke-width="6"/>
    <text x="48" y="64" font-size="28" text-anchor="middle" fill="#fff" font-family="Arial" font-weight="700">🐌</text>
  </g>
</svg>
SVG

echo "SVGs written to $IMG_DIR"

echo "Checking for SVG -> PNG conversion tools..."
CONVERTER=""
if command -v rsvg-convert >/dev/null 2>&1; then
  CONVERTER="rsvg-convert"
  echo "Found rsvg-convert (librsvg) -> will use it for PNG conversion."
elif command -v convert >/dev/null 2>&1; then
  CONVERTER="convert"
  echo "Found ImageMagick 'convert' -> will use it for PNG conversion."
else
  echo "No SVG converter found (rsvg-convert or ImageMagick 'convert')."
  echo "PNG files will NOT be generated. To enable PNG conversion install librsvg2-bin or ImageMagick."
fi

# Convert SVGs to PNG at multiple sizes if converter available
if [ -n "$CONVERTER" ]; then
  SIZES=(512 256 128)
  for svg in "$IMG_DIR"/*.svg; do
    base=$(basename "$svg" .svg)
    for s in "${SIZES[@]}"; do
      out="$PNG_DIR/${base}_${s}.png"
      echo "Converting $svg -> $out (size ${s}px)"
      if [ "$CONVERTER" = "rsvg-convert" ]; then
        # rsvg-convert uses -w and -h
        rsvg-convert -w "$s" -h "$s" -o "$out" "$svg"
      else
        # ImageMagick convert: preserve transparency
        convert -background none -resize "${s}x${s}" "$svg" "$out"
      fi
    done
  done
  echo "PNG conversion done. PNGs are in $PNG_DIR"
fi

echo "Writing README for asset usage..."
cat > README_ASSETS.md <<'MARKDOWN'
#### Placeholder assets generated for my_snake_game

This archive contains simple SVG placeholders for development and generated PNG versions (if your system supports conversion),
plus short WAV sounds synthesized (short tones).

Files:
- assets/images/
  - snake_head.svg
  - snake_body.svg
  - food.svg
  - power_speed.svg
  - power_shield.svg
  - power_double.svg
  - power_slow.svg
- assets/images/png/
  - snake_head_512.png, snake_head_256.png, snake_head_128.png (and same pattern for other images)  <-- only present if conversion tool available
- assets/audio/
  - eat.wav
  - power_up.wav
  - game_over.wav
  - background_music.wav

How to use in Flutter:
- If you want PNGs (recommended for Flame sprites), use files from assets/images/png/.
- If you prefer SVG rendering in widgets, add the `flutter_svg` package:
  In pubspec.yaml add:
    dependencies:
      flutter_svg: ^2.0.0
  Then:
    import 'package:flutter_svg/flutter_svg.dart';
    SvgPicture.asset('assets/images/food.svg')

- Flame / FlameAudio can play WAV files from assets/audio/. Ensure these files are listed under assets in your pubspec.yaml.

If PNGs are not generated by this script, install one of:
- librsvg (provides rsvg-convert). On Ubuntu/Debian: sudo apt install librsvg2-bin
- ImageMagick (provides convert). On Ubuntu/Debian: sudo apt install imagemagick
On macOS with Homebrew:
- brew install librsvg
- or brew install imagemagick

To convert later manually:
- rsvg-convert -w 256 -h 256 -o snake_head_256.png snake_head.svg
- convert -background none -resize 256x256 snake_head.svg snake_head_256.png

MARKDOWN

echo "Generating WAV audio files using an embedded Python script..."

cat > generate_wavs.py <<'PY'
#!/usr/bin/env python3
# Generates short WAV files (sine tones / simple background) into the target audio folder.
import wave, struct, math, os

audio_dir = os.path.join("assets", "audio")
os.makedirs(audio_dir, exist_ok=True)

def generate_wav(filename, freq=440.0, duration=0.2, volume=0.3, sample_rate=44100):
    n_samples = int(sample_rate * duration)
    with wave.open(filename, 'w') as wf:
        wf.setnchannels(1)          # mono
        wf.setsampwidth(2)         # 16-bit
        wf.setframerate(sample_rate)
        max_amp = int(32767 * volume)
        frames = bytearray()
        for i in range(n_samples):
            t = float(i) / sample_rate
            # simple sine wave
            sample = int(max_amp * math.sin(2 * math.pi * freq * t))
            frames += struct.pack('<h', sample)
        wf.writeframes(frames)

def generate_beep_pair(filename, freq1, freq2, duration=0.25):
    # mix two sines for a richer beep
    sample_rate = 44100
    n_samples = int(sample_rate * duration)
    with wave.open(filename, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        max_amp = int(32767 * 0.3)
        frames = bytearray()
        for i in range(n_samples):
            t = float(i) / sample_rate
            s = 0.5 * math.sin(2 * math.pi * freq1 * t) + 0.5 * math.sin(2 * math.pi * freq2 * t)
            sample = int(max_amp * s)
            frames += struct.pack('<h', sample)
        wf.writeframes(frames)

print("Generating eat.wav")
generate_wav(os.path.join(audio_dir, "eat.wav"), freq=880.0, duration=0.12, volume=0.35)

print("Generating power_up.wav")
generate_beep_pair(os.path.join(audio_dir, "power_up.wav"), 660.0, 990.0, duration=0.18)

print("Generating game_over.wav")
# descending tones
generate_wav(os.path.join(audio_dir, "game_over_part1.wav"), freq=700.0, duration=0.12, volume=0.35)
generate_wav(os.path.join(audio_dir, "game_over_part2.wav"), freq=520.0, duration=0.12, volume=0.35)
# concatenate into single file
parts = [
    os.path.join(audio_dir, "game_over_part1.wav"),
    os.path.join(audio_dir, "game_over_part2.wav"),
]
outname = os.path.join(audio_dir, "game_over.wav")
import wave
def concat_wavs(outname, parts):
    data = []
    params = None
    for p in parts:
        with wave.open(p, 'rb') as r:
            if params is None:
                params = r.getparams()
            data.append(r.readframes(r.getnframes()))
    with wave.open(outname, 'wb') as w:
        w.setparams(params)
        for d in data:
            w.writeframes(d)
concat_wavs(outname, parts)
# remove parts
for p in parts:
    os.remove(p)

print("Generating background_music.wav (short loopable ambience)")
# simple two-tone ambient clip (1.2s)
sample_rate = 44100
duration = 1.2
n_samples = int(sample_rate * duration)
with wave.open(os.path.join(audio_dir, "background_music.wav"), 'w') as wf:
    wf.setnchannels(1)
    wf.setsampwidth(2)
    wf.setframerate(sample_rate)
    max_amp = int(32767 * 0.14)
    frames = bytearray()
    for i in range(n_samples):
        t = float(i) / sample_rate
        s = (0.5 * math.sin(2 * math.pi * 220.0 * t) + 0.5 * math.sin(2 * math.pi * 330.0 * t)) * (0.9 + 0.1*math.sin(2*math.pi*0.5*t))
        sample = int(max_amp * s)
        frames += struct.pack('<h', sample)
    wf.writeframes(frames)

print("Done generating wavs.")
PY

python3 generate_wavs.py

echo "Zipping assets into $OUT_ZIP..."
zip -r "$OUT_ZIP" "$ASSETS_DIR" README_ASSETS.md >/dev/null

echo "Cleaning up temporary generator..."
rm -f generate_wavs.py

echo "Created $OUT_ZIP with SVGs, (PNG if conversion tool available) and WAV audio files."
echo ""
echo "Instructions:"
echo "1) Unzip the archive into your Flutter project root so the 'assets' folder sits next to pubspec.yaml."
echo "   unzip $OUT_ZIP -d ."
echo "2) Ensure your pubspec.yaml lists assets:"
echo "   flutter:"
echo "     assets:"
echo "       - assets/audio/"
echo "       - assets/images/"
echo "       - assets/images/png/   # (optional) if PNGs were generated"
echo ""
echo "If PNGs were not generated, install librsvg or ImageMagick and re-run this script to produce PNGs."