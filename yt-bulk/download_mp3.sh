#!/bin/bash

#PENDING_FILE="./mp3_urls_pending.txt"
PENDING_FILE=$1
DOWNLOADED_FILE="./mp3_urls_downloaded.txt"

touch "$DOWNLOADED_FILE"

if [[ ! -f "$PENDING_FILE" ]]; then
    echo "Error: $PENDING_FILE not found!"
    exit 1
fi

while IFS= read -r url || [[ -n "$url" ]]; do
    url=$(echo "$url" | tr -d '\r')
    [[ -z "$url" ]] && continue

    if ! grep -qxF "$url" "$DOWNLOADED_FILE"; then
        echo "Processing download: $url"
        
        # Execute download. Switch '--audio-format mp3' to 'best' if you lack ffmpeg
        if yt-dlp -x --audio-format mp3 --audio-quality 320K "$url"; then
            echo "$url" >> "$DOWNLOADED_FILE"
            echo "Successfully saved!"
        else
            echo "WARNING: Post-processing failed for $url. Ensure ffmpeg is installed."
        fi
    else
        echo "Skipping (already downloaded): $url"
    fi
done < "$PENDING_FILE"

