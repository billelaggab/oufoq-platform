#!/usr/bin/env bash
# سكربت تحميل خط Tajawal الرسمي من مستودع Google Fonts (GitHub)
# الاستخدام: bash scripts/download_tajawal_font.sh
set -euo pipefail

FONT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/assets/fonts/Tajawal"
BASE_URL="https://raw.githubusercontent.com/google/fonts/main/ofl/tajawal"
WEIGHTS=("Light" "Regular" "Medium" "Bold" "ExtraBold")

mkdir -p "$FONT_DIR"
for weight in "${WEIGHTS[@]}"; do
  out="$FONT_DIR/Tajawal-$weight.ttf"
  if [ -s "$out" ]; then
    echo "موجود مسبقاً: $out"
  else
    echo "جارٍ التحميل: Tajawal-$weight.ttf"
    curl -fsSL -o "$out" "$BASE_URL/Tajawal-$weight.ttf"
  fi
done

echo "تم تجهيز خط Tajawal بجميع أوزانه داخل: $FONT_DIR"
