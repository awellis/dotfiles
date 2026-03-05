function zotero-clear-autoexports --description "Remove all Better BibTeX auto-exports from Zotero prefs"
    set -l prefs_file "$HOME/Library/Application Support/Zotero/Profiles/97kaa36k.default/prefs.js"

    if pgrep -x zotero-bin >/dev/null 2>&1; or pgrep -xf ".*Zotero.*" >/dev/null 2>&1
        echo "Error: Zotero is still running. Quit Zotero first."
        return 1
    end

    if not test -f "$prefs_file"
        echo "Error: prefs.js not found at $prefs_file"
        return 1
    end

    set -l count (grep -c "better-bibtex.autoExport\." "$prefs_file")

    if test "$count" -eq 0
        echo "No auto-exports found. Nothing to do."
        return 0
    end

    echo "Found $count auto-export(s). Removing..."

    cp "$prefs_file" "$prefs_file.bak"
    grep -v "better-bibtex.autoExport\." "$prefs_file.bak" >"$prefs_file"

    set -l remaining (grep -c "better-bibtex.autoExport\." "$prefs_file")
    if test "$remaining" -eq 0
        echo "Done. Removed $count auto-export(s). Backup saved as prefs.js.bak"
    else
        echo "Warning: $remaining entries remain. Restoring backup."
        cp "$prefs_file.bak" "$prefs_file"
        return 1
    end
end
