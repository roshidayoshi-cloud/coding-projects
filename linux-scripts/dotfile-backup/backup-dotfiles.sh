#!/bin/bash

# Dotfile Backup Script for EndeavourOS
# Backs up your config files to a safe location

BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
DOTFILES=(
    ".config/hypr"
    ".config/waybar"
    ".config/kitty"
    ".bashrc"
    ".zshrc"
    ".vimrc"
    ".config/nvim"
)

echo "🔄 Starting dotfile backup..."
mkdir -p "$BACKUP_DIR"

for dotfile in "${DOTFILES[@]}"; do
    if [ -e "$HOME/$dotfile" ]; then
        echo "✅ Backing up: $dotfile"
        cp -r "$HOME/$dotfile" "$BACKUP_DIR/"
    else
        echo "⏭️  Skipping (not found): $dotfile"
    fi
done

echo ""
echo "✨ Backup complete!"
echo "📁 Location: $BACKUP_DIR"
echo "💾 Size: $(du -sh "$BACKUP_DIR" | cut -f1)"
