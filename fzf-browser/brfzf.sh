fzf_browser() {
    fzf --preview '
        file_path={}
        
        # 1. Get MIME type cleanly
        mime=$(file --mime-type -b "$file_path")
        
        # 2. Setup standard sizing variables for Kitty icat
        icat_cmd="kitten icat --clear --transfer-mode=memory --stdin=no --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0"

        # --- PREVIEW LOGIC ---
        
        # A. Directories
        if [[ -d "$file_path" ]]; then
            ls -la --color=always "$file_path"

        # B. Images (PNG, JPEG, GIF, WebP, etc.)
        elif [[ "$mime" == image/* ]]; then
            eval "$icat_cmd" "$file_path"

        # C. PDFs (Using MuPDF to rasterize page 1 into a fast cache)
        elif [[ "$mime" == "application/pdf" ]]; then
            cache_img="${XDG_CACHE_HOME:-$HOME/.cache}/fzf_pdf_$(basename "$file_path").png"
            
            # Generate png of 1st page only if not already cached
            if [[ ! -f "$cache_img" ]]; then
                mutool draw -o "$cache_img" "$file_path" 1 >/dev/null 2>&1
            fi
            
            eval "$icat_cmd" "$cache_img"

        # D. Plain Text, Source Code, and Config files
        elif [[ "$mime" == text/* || "$mime" == "application/json" || "$mime" == "application/javascript" ]]; then
            bat --color=always --style=numbers --line-range :500 "$file_path" 2>/dev/null || cat "$file_path"

        # E. Fallback for Binary Data, Archives, or Unknown types
        else
            echo "--- File Information ---"
            file -b "$file_path"
            echo -e "\n--- Archive / Size Details ---"
            ls -lh "$file_path"
        fi
    '
}
fzf_browser
