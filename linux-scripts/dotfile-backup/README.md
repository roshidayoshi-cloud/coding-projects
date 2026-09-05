# Dotfile Backup Script

Simple bash script that backs up your EndeavourOS configuration files.

## What it backs up
- Hyprland config
- Waybar config
- Kitty terminal config
- Shell configs (.bashrc, .zshrc)
- Neovim config

## How to use

```bash
./backup-dotfiles.sh
```

Creates a timestamped backup folder in your home directory.

## Customization

Edit the `DOTFILES` array in the script to add/remove files you want backed up.

```markdown
```

Save.

