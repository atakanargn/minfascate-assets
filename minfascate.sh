#!/bin/bash

# Kaynak ve hedef klasörleri tanımla
SOURCE_DIR="source_folder"
OUTPUT_DIR="output_folder"

# Çıkış klasörünü oluştur
mkdir -p "$OUTPUT_DIR"

# Kaynak klasördeki tüm JS ve CSS dosyalarını bul
find "$SOURCE_DIR" \( -name "*.js" -o -name "*.css" \) | while read file; do
    # Dosyanın göreli yolunu al
    REL_PATH=$(realpath --relative-to="$SOURCE_DIR" "$file")
    OUTPUT_PATH="$OUTPUT_DIR/$REL_PATH"
    
    # Hedef klasör yapısını oluştur
    mkdir -p "$(dirname "$OUTPUT_PATH")"
    
    # Geçici bir dosyada açıklamaları temizle
    TEMP_FILE=$(mktemp)
    
    if [[ "$file" == *.js ]]; then
        # JS dosyalarından açıklamaları temizle
        sed -E '/^\s*\/\//d; s/\/\*[^*]*\*+([^/*][^*]*\*+)*\// /g' "$file" > "$TEMP_FILE"
        # JS dosyasını sıkıştır ve obfuscate et
        uglifyjs "$TEMP_FILE" -c -m -o "$OUTPUT_PATH"
    elif [[ "$file" == *.css ]]; then
        # CSS dosyalarından açıklamaları temizle
        sed -E 's/\/\*[^*]*\*+([^/*][^*]*\*+)*\// /g' "$file" > "$TEMP_FILE"
        # CSS dosyasını sıkıştır
        cleancss "$TEMP_FILE" -o "$OUTPUT_PATH"
    fi
    
    # Geçici dosyayı sil
    rm "$TEMP_FILE"

    # Orijinal dosya izinlerini kopyala
    chmod --reference="$file" "$OUTPUT_PATH"

    echo "Processed: $REL_PATH"
done
