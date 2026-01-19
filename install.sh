#!/bin/bash

DOTFILES="$HOME/dotfiles"

# Make sure dotfiles directory exists
if [ ! -d "$DOTFILES" ]; then
  echo "Error: $DOTFILES does not exist!"
  echo "You need to restore your dotfiles directory first."
  exit 1
fi

# Apps that were managed with stow
APPS=(
  "nvim" "kitty" "fastfetch" "btop" "htop" "lazygit"
  "mpv" "cava" "spicetify" "gtk-3.0" "gtk-4.0"
  "qt5ct" "qt6ct" "fontconfig" "matugen" "hypr" "danksearch"
  "pipewire" "wireplumber" "environment.d" "DankMaterialShell"
  "kdeglobals" "mimeapps.list" "dolphinrc"
)

cd "$DOTFILES"

# Restow each app
for app in "${APPS[@]}"; do
  if [ -d "$DOTFILES/$app" ]; then
    echo "Restowing $app..."
    stow -v -R -t "$HOME" "$app"
  else
    echo "Skipping $app: Not found in $DOTFILES"
  fi
done

# Handle system files
if [ -d "$DOTFILES/system" ]; then
  echo "Restowing system files..."
  stow -v -R -t "$HOME" system
fi

# Handle zsh - fix structure if needed
if [ -d "$DOTFILES/zsh" ]; then
  # Check if .zshrc is in wrong location and fix it
  if [ -f "$DOTFILES/zsh/.config/.zshrc" ]; then
    echo "Moving .zshrc to correct location..."
    mv "$DOTFILES/zsh/.config/.zshrc" "$DOTFILES/zsh/"
    rmdir "$DOTFILES/zsh/.config" 2>/dev/null
  fi

  # Backup existing .zshrc if it's not a symlink
  if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    echo "Backing up existing .zshrc to .zshrc.backup"
    mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
  fi

  echo "Restowing zsh..."
  stow -v -R -t "$HOME" zsh
else
  echo "Skipping zsh: Not found in $DOTFILES"
fi

echo "Done! Symlinks recreated."
