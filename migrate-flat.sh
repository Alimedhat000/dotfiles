#!/usr/bin/env bash
#
# migrate-flat.sh - Flatten nested dotfiles structure without breaking system
#
# Current structure:  nvim/.config/nvim/init.lua
# Target structure:   nvim/init.lua (with proxy symlink nvim/.config/nvim -> ../..)
#
# The proxy symlink keeps stow working - existing symlinks in ~/.config/ will
# follow through the proxy and still reach the config files.
#
# Usage: ./migrate-flat.sh [--dry-run]
#

set -euo pipefail

REPO_DIR="${REPO_DIR:-$HOME/dotfiles}"
BACKUP_FILE="$HOME/dotfiles-backup-$(date +%F-%H%M%S).tar.gz"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DRY_RUN=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            ;;
    esac
done

log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*"; }

run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${YELLOW}[DRY-RUN]${NC} $*"
        return 0
    else
        eval "$@"
    fi
}

create_backup() {
    log_info "Creating backup: $BACKUP_FILE"
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${YELLOW}[DRY-RUN]${NC} git archive HEAD | gzip > '$BACKUP_FILE'"
    else
        git -C "$REPO_DIR" archive HEAD | gzip > "$BACKUP_FILE"
        log_success "Backup created: $BACKUP_FILE"
    fi
}

ensure_clean_repo() {
    if [ "$DRY_RUN" = true ]; then
        return 0
    fi
    
    if ! git -C "$REPO_DIR" diff --quiet 2>/dev/null; then
        log_error "Repository has uncommitted changes. Commit or stash them first."
        exit 1
    fi
}

create_migration_branch() {
    local branch_name="flatten-migration"
    
    if [ "$DRY_RUN" = true ]; then
        log_info "Would create branch: $branch_name"
        return 0
    fi
    
    local current_branch
    current_branch=$(git -C "$REPO_DIR" branch --show-current)
    
    # Check if we're already on the migration branch
    if [ "$current_branch" = "$branch_name" ]; then
        log_info "Already on branch: $branch_name"
        return 0
    fi
    
    # Check if branch already exists
    if git -C "$REPO_DIR" rev-parse --verify "$branch_name" >/dev/null 2>&1; then
        log_warn "Branch '$branch_name' already exists"
        read -p "Switch to it and continue? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git -C "$REPO_DIR" checkout "$branch_name"
            log_success "Switched to branch: $branch_name"
        else
            log_error "Aborted. Delete the branch or use a different name."
            exit 1
        fi
    else
        log_info "Creating branch: $branch_name (from $current_branch)"
        git -C "$REPO_DIR" checkout -b "$branch_name"
        log_success "Created and switched to branch: $branch_name"
    fi
}

# Migrate a .config package: nvim/.config/nvim/* -> nvim/*
# Creates proxy symlink: nvim/.config/nvim -> ../..
migrate_config_package() {
    local package="$1"
    local package_dir="$REPO_DIR/$package"
    local nested_path="$package_dir/.config/$package"
    
    log_info "Migrating: $package"
    
    # Check if already migrated (proxy symlink exists)
    if [ -L "$nested_path" ]; then
        log_info "  Already migrated (proxy symlink exists)"
        return 0
    fi
    
    # Check if this is a single-file package (e.g., dolphinrc/.config/dolphinrc is a file)
    if [ -f "$nested_path" ]; then
        echo "  Structure: $package/.config/$package (file) -> $package/$package"
        
        local basename_file
        basename_file=$(basename "$nested_path")
        echo "    Moving: $basename_file"
        run_cmd "git -C '$REPO_DIR' mv '$nested_path' '$package_dir/'"
        
        # Remove the now-empty .config directory
        run_cmd "rmdir '$package_dir/.config'"
        
        # Create proxy symlink using ABSOLUTE path to avoid symlink chain issues
        # package/.config -> $REPO_DIR/$package (absolute)
        run_cmd "ln -s '$package_dir' '$package_dir/.config'"
        
        # Stage the symlink
        run_cmd "git -C '$REPO_DIR' add '$package_dir/.config'"
        
        # Commit this package
        if [ "$DRY_RUN" = false ]; then
            git -C "$REPO_DIR" add -A
            git -C "$REPO_DIR" commit -m "flatten: $package/.config/$package -> $package/$package"
            log_success "  Committed"
        fi
        return 0
    fi
    
    # Check if this package has the nested directory structure
    if [ ! -d "$nested_path" ]; then
        log_warn "  Skipping: no nested structure at $package/.config/$package"
        return 0
    fi
    
    echo "  Structure: $package/.config/$package/* -> $package/*"
    
    # List files to move
    local files
    files=$(find "$nested_path" -mindepth 1 -maxdepth 1 2>/dev/null)
    
    if [ -z "$files" ]; then
        log_warn "  No files found in $nested_path"
        return 0
    fi
    
    # Move each file/directory up to package root
    for item in $files; do
        local basename_item
        basename_item=$(basename "$item")
        
        # Skip empty directories (git can't track them)
        if [ -d "$item" ] && [ -z "$(ls -A "$item")" ]; then
            echo "    Skipping empty dir: $basename_item"
            continue
        fi
        
        echo "    Moving: $basename_item"
        run_cmd "git -C '$REPO_DIR' mv '$item' '$package_dir/'"
    done
    
    # Remove the now-empty nested directories (use rm -rf to handle any leftover empty dirs)
    run_cmd "rm -rf '$nested_path'" 
    run_cmd "rm -rf '$package_dir/.config'"
    
    # Create proxy symlink using ABSOLUTE path to avoid symlink chain issues
    # package/.config/package -> $REPO_DIR/$package (absolute)
    run_cmd "mkdir -p '$package_dir/.config'"
    run_cmd "ln -s '$package_dir' '$package_dir/.config/$package'"
    
    # Stage the symlink
    run_cmd "git -C '$REPO_DIR' add '$package_dir/.config/$package'"
    
    # Commit this package
    if [ "$DRY_RUN" = false ]; then
        git -C "$REPO_DIR" add -A
        git -C "$REPO_DIR" commit -m "flatten: $package/.config/$package -> $package"
        log_success "  Committed"
    fi
}

# Migrate zsh: zsh/.zshrc is already flat, nothing to do
migrate_zsh() {
    local zsh_dir="$REPO_DIR/zsh"
    
    log_info "Checking: zsh"
    
    if [ ! -d "$zsh_dir" ]; then
        log_warn "  zsh directory not found"
        return 0
    fi
    
    # Check if .zshrc exists directly in zsh/
    if [ -f "$zsh_dir/.zshrc" ]; then
        log_info "  Already flat (zsh/.zshrc exists)"
        return 0
    fi
    
    # Check for weird nested structure
    if [ -f "$zsh_dir/.config/.zshrc" ]; then
        log_info "  Moving zsh/.config/.zshrc -> zsh/.zshrc"
        run_cmd "git -C '$REPO_DIR' mv '$zsh_dir/.config/.zshrc' '$zsh_dir/.zshrc'"
        run_cmd "rmdir '$zsh_dir/.config' 2>/dev/null || true"
        
        if [ "$DRY_RUN" = false ]; then
            git -C "$REPO_DIR" add -A
            git -C "$REPO_DIR" commit -m "flatten: zsh/.config/.zshrc -> zsh/.zshrc"
            log_success "  Committed"
        fi
    fi
}

# Migrate system: system/.config/* -> system/* with proxy
migrate_system() {
    local system_dir="$REPO_DIR/system"
    local nested_dir="$system_dir/.config"
    
    log_info "Migrating: system"
    
    if [ ! -d "$nested_dir" ]; then
        log_warn "  No .config directory in system/"
        return 0
    fi
    
    # Check if already migrated
    if [ -L "$nested_dir" ]; then
        log_info "  Already migrated (proxy symlink exists)"
        return 0
    fi
    
    # Move files from system/.config/* to system/*
    local files
    files=$(find "$nested_dir" -mindepth 1 -maxdepth 1 2>/dev/null)
    
    if [ -z "$files" ]; then
        log_warn "  No files in system/.config/"
        return 0
    fi
    
    for item in $files; do
        local basename_item
        basename_item=$(basename "$item")
        echo "    Moving: $basename_item"
        run_cmd "git -C '$REPO_DIR' mv '$item' '$system_dir/'"
    done
    
    # Remove empty .config and create proxy symlink using ABSOLUTE path
    run_cmd "rmdir '$nested_dir'"
    run_cmd "ln -s '$system_dir' '$system_dir/.config'"
    run_cmd "git -C '$REPO_DIR' add '$system_dir/.config'"
    
    if [ "$DRY_RUN" = false ]; then
        git -C "$REPO_DIR" add -A
        git -C "$REPO_DIR" commit -m "flatten: system/.config/* -> system/*"
        log_success "  Committed"
    fi
}

verify_symlinks() {
    log_info "Verifying system symlinks still work..."
    
    local checks=(
        "$HOME/.config/nvim"
        "$HOME/.config/hypr"
        "$HOME/.config/kitty"
        "$HOME/.zshrc"
    )
    
    local all_ok=true
    
    for link in "${checks[@]}"; do
        if [ -L "$link" ]; then
            # Check if symlink resolves to something that exists
            if [ -e "$link" ]; then
                local target
                target=$(readlink "$link")
                log_success "  $link -> $target"
            else
                log_error "  $link -> BROKEN"
                all_ok=false
            fi
        elif [ -e "$link" ]; then
            log_info "  $link (not a symlink)"
        else
            log_warn "  $link (does not exist)"
        fi
    done
    
    if [ "$all_ok" = true ]; then
        log_success "All symlinks verified!"
    else
        log_error "Some symlinks are broken. You may need to run: stow -R <package>"
    fi
}

show_result() {
    echo
    echo "========================================"
    echo "  Result"
    echo "========================================"
    echo
    echo "Before: nvim/.config/nvim/init.lua"
    echo "After:  nvim/init.lua"
    echo "        nvim/.config/nvim -> $REPO_DIR/nvim  (absolute proxy symlink)"
    echo
    echo "Your ~/.config/nvim symlink still works because:"
    echo "  ~/.config/nvim -> ../dotfiles/nvim/.config/nvim -> $REPO_DIR/nvim/"
    echo
    
    local current_branch
    current_branch=$(git -C "$REPO_DIR" branch --show-current)
    if [ "$current_branch" = "flatten-migration" ]; then
        echo "========================================"
        echo "  Next Steps"
        echo "========================================"
        echo
        echo "You're on branch: $current_branch"
        echo
        echo "If everything looks good:"
        echo "  git checkout main && git merge flatten-migration"
        echo
        echo "Or if something went wrong:"
        echo "  git checkout main  # abandon the branch"
        echo
    fi
}

main() {
    echo "========================================"
    echo "  Dotfiles Flatten Migration"
    echo "========================================"
    echo "Repo: $REPO_DIR"
    echo "Mode: $([ "$DRY_RUN" = true ] && echo 'DRY RUN' || echo 'LIVE')"
    echo
    
    ensure_clean_repo
    create_backup
    create_migration_branch
    
    # Packages with .config nesting
    local packages=(
        "nvim"
        "kitty"
        "hypr"
        "lazygit"
        "mpv"
        "spicetify"
        "gtk-3.0"
        "gtk-4.0"
        "matugen"
        "btop"
        "cava"
        "pipewire"
        "qt5ct"
        "qt6ct"
        "fastfetch"
        "danksearch"
        "DankMaterialShell"
        "dolphinrc"
        "environment.d"
        "mimeapps.list"
        "kdeglobals"
    )
    
    echo
    for package in "${packages[@]}"; do
        if [ -d "$REPO_DIR/$package" ]; then
            migrate_config_package "$package"
        fi
    done
    
    echo
    migrate_zsh
    migrate_system
    
    echo
    if [ "$DRY_RUN" = false ]; then
        verify_symlinks
        show_result
    else
        echo
        log_info "Dry run complete. Run without --dry-run to apply changes."
    fi
}

main "$@"
