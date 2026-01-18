#!/bin/bash

# The directory where dotfiles will live
DOTFILES="$HOME/dotfiles"
mkdir -p "$DOTFILES"

# Apps to manage with stow
APPS=(
  "nvim" "kitty" "fastfetch" "btop" "htop" "lazygit"
  "mpv" "cava" "spicetify" "gtk-3.0" "gtk-4.0"
  "qt5ct" "qt6ct" "fontconfig" "matugen" "hypr" "danksearch"
  "pipewire" "wireplumber" "environment.d" "DankMaterialShell"
  "kdeglobals" "mimeapps.list" "dolphinrc"
)

cd "$DOTFILES"

# Move configs to individual folders
for app in "${APPS[@]}"; do
  if [ -d "$HOME/.config/$app" ] || [ -f "$HOME/.config/$app" ]; then
    # Check if it's already a symlink to avoid moving links
    if [ -L "$HOME/.config/$app" ]; then
      echo "Skipping $app: Already a symlink."
      continue
    fi

    echo "Organizing $app..."
    # Create the internal structure (e.g., ~/dotfiles/nvim/.config/)
    mkdir -p "$DOTFILES/$app/.config"
    # Move the config into its new home
    mv "$HOME/.config/$app" "$DOTFILES/$app/.config/"

    # Stow it immediately
    stow -v -t "$HOME" "$app"
  else
    echo "Skipping $app: Not found in ~/.config"
  fi
done

# Handle specific files like user-dirs
if [ -f "$HOME/.config/user-dirs.dirs" ] && [ ! -L "$HOME/.config/user-dirs.dirs" ]; then
  mkdir -p "$DOTFILES/system/.config"
  mv "$HOME/.config/user-dirs.dirs" "$DOTFILES/system/.config/"
  mv "$HOME/.config/user-dirs.locale" "$DOTFILES/system/.config/"
  stow -v -t "$HOME" system
fi

# Handle .zshrc (lives in $HOME, not .config)
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  echo "Organizing zshrc..."
  mkdir -p "$DOTFILES/zsh"
  mv "$HOME/.zshrc" "$DOTFILES/zsh/"
  stow -v -R -t "$HOME" zsh
fi

echo "All done! Check ~/dotfiles to see your organized packages."
