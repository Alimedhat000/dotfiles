#!/usr/bin/env bash
#
# migrate-flat.sh - Flatten nested dotfiles structure without breaking system
#
# Usage:
#   ./migrate-flat.sh [--dry-run] [--package <name>] [--continue-from <package>]
#
# Options:
#   --dry-run         Show what would happen without making changes
#   --package <name>  Migrate only a specific package
#   --continue-from   Resume migration from a specific package
#   --verify          Run verification checks only
#   --help            Show this help message
#

set -euo pipefail

REPO_DIR="${REPO_DIR:-$HOME/dotfiles}"
BACKUP_FILE="$HOME/dotfiles-backup-$(date +%F).tar.gz"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DRY_RUN=false
SINGLE_PACKAGE=""
START_FROM=""
VERIFY_ONLY=false

# Package migration mapping: package -> target_path
PACKAGES=(
    "nvim:.config/nvim"
    "kitty:.config/kitty"
    "lazygit:.config/lazygit"
    "mpv:.config/mpv"
    "spicetify:.config/spicetify"
    "gtk-3.0:.config/gtk-3.0"
    "gtk-4.0:.config/gtk-4.0"
    "matugen:.config/matugen"
    "hypr:.config/hypr"
    "dolphinrc:.config/dolph "environment.d:.inrc"
   config/environment.d"
    "mimeapps.list:.config/mimeapps.list"
    "kdeglobals:.config/kdeglobals"
    "btop:.config/btop"
    "cava:.config/cava"
    "pipewire:.config/pipewire"
    "qt5ct:.config/qt5ct"
    "qt6ct:.config/qt6ct"
    "danksearch:.config/danksearch"
    "DankMaterialShell:.config/DankMaterialShell"
)

# Direct file mappings (not directories)
DIRECT_FILES=(
    "mimeapps.list:.config/mimeapps.list:mimeapps.list"
    "kdeglobals:.config/kdeglobals:kdeglobals"
)

# Special cases
ZSH_PACKAGE="zsh"
SYSTEM_PACKAGE="system"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} $*"
    else
        echo "[EXEC] $*"
        eval "$@"
    fi
}

confirm() {
    local msg="$1"
    if [ "$DRY_RUN" = true ]; then
        log_info "Would confirm: $msg"
        return 0
    fi
    read -p "$msg [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warn "Skipped: $msg"
        return 1
    fi
    return 0
}

check_git_clean() {
    if ! git -C "$REPO_DIR" diff --quiet 2>/dev/null; then
        log_warn "Uncommitted changes detected. Consider committing first."
        if ! confirm "Continue with uncommitted changes?"; then
            exit 1
        fi
    fi
}

# ============================================================================
# BACKUP & SAFETY
# ============================================================================

create_backup() {
    log_info "Creating backup: $BACKUP_FILE"
    run_cmd "git -C '$REPO_DIR' archive HEAD | gzip > '$BACKUP_FILE'"
    log_success "Backup created"
}

ensure_safety_branch() {
    if [ "$DRY_RUN" = true ]; then
        log_info "Would create safety branch: flatten-safety"
        return 0
    fi
    
    if ! git -C "$REPO_DIR" rev-parse --verify flatten-safety >/dev/null 2>&1; then
        log_info "Creating safety branch..."
        git -C "$REPO_DIR" checkout -b flatten-safety
        git -C "$REPO_DIR" commit -a -m "safety: snapshot before flattening $(date +%F)"
        log_success "Safety branch created"
    else
        log_info "Safety branch already exists"
    fi
}

# ============================================================================
# MIGRATION FUNCTIONS
# ============================================================================

migrate_package() {
    local package="$1"
    local target="$2"
    local source_dir="$REPO_DIR/$package"
    local target_dir="$REPO_DIR/$target"
    
    log_info "Migrating: $package → $target"
    
    # Check if source exists
    if [ ! -d "$source_dir" ]; then
        log_warn "Source directory not found: $source_dir"
        return 0
    fi
    
    # Find files to migrate (recursively)
    local files
    files=$(find "$source_dir" -type f 2>/dev/null | sed "s|$source_dir/||" | grep -v '^$')
    
    if [ -z "$files" ]; then
        log_warn "No files found in $source_dir"
        return 0
    fi
    
    # Show files that will be migrated
    local count
    count=$(echo "$files" | wc -l)
    echo "  Files to migrate ($count):"
    echo "$files" | head -10 | sed 's/^/    - /'
    [ "$count" -gt 10 ] && echo "    ... and $((count - 10)) more"
    
    # Create target directory
    run_cmd "mkdir -p '$target_dir'"
    
    # Move files - strip the leading package/.config/package/ pattern
    echo "$files" | while read -r f; do
        if [ -e "$source_dir/$f" ]; then
            # Calculate relative path: remove leading package/.config/package/
            local new_path="$f"
            local prefix="${package}/.config/${package}"
            if [[ "$f" == "$prefix/"* ]]; then
                new_path="${f#$prefix/}"
            fi
            
            local target_subdir
            target_subdir="$(dirname "$target_dir/$new_path")"
            run_cmd "mkdir -p '$target_subdir'"
            run_cmd "git mv '$source_dir/$f' '$target_dir/$new_path' 2>/dev/null || cp -a '$source_dir/$f' '$target_dir/$new_path'"
        fi
    done
    
    # Remove empty source directories (keep package directory itself)
    if [ "$DRY_RUN" = false ]; then
        find "$source_dir" -type d -empty -delete 2>/dev/null || true
    fi
    
    # Create proxy symlink at old location
    local config_subdir="$source_dir/.config/$(basename "$target")"
    if [ -d "$source_dir/.config" ] && [ ! -e "$config_subdir" ]; then
        local proxy_target="../../$target"
        log_info "Creating proxy symlink: $config_subdir → $proxy_target"
        run_cmd "ln -s '$proxy_target' '$config_subdir'"
    fi
    
    # Commit
    if [ "$DRY_RUN" = false ]; then
        git -C "$REPO_DIR" add -A
        git -C "$REPO_DIR" commit -m "flatten: move $package to $target"
        log_success "Committed: $package → $target"
    fi
}

migrate_direct_file() {
    local package="$1"
    local target="$2"
    local source="$REPO_DIR/$package/.config/$package"
    local target_file="$REPO_DIR/$target"
    
    log_info "Migrating: $package/.config/$package → $target"
    
    if [ ! -f "$source" ]; then
        log_warn "Source file not found: $source"
        return 0
    fi
    
    # Create target directory
    run_cmd "mkdir -p '$(dirname "$target_file")'"
    
    # Move file
    run_cmd "git mv '$source' '$target_file'"
    
    # Remove empty directories
    run_cmd "rmdir '$REPO_DIR/$package/.config' 2>/dev/null || true"
    
    # Create proxy symlink at old location
    run_cmd "mkdir -p '$REPO_DIR/$package/.config'"
    run_cmd "ln -s ../../$target '$REPO_DIR/$package/.config/$package'"
    
    # Commit
    if [ "$DRY_RUN" = false ]; then
        git -C "$REPO_DIR" add -A
        git -C "$REPO_DIR" commit -m "flatten: move $package to $target"
        log_success "Committed: $package → $target"
    fi
}

migrate_zsh() {
    local source="$REPO_DIR/zsh/.zshrc"
    local target="$REPO_DIR/.zshrc"
    
    log_info "Migrating: zsh/.zshrc → .zshrc"
    
    if [ ! -f "$source" ]; then
        log_warn "Source file not found: $source"
        return 0
    fi
    
    # Move file
    run_cmd "git mv '$source' '$target'"
    
    # Remove empty directories
    run_cmd "rmdir '$REPO_DIR/zsh/.config' 2>/dev/null || true"
    
    # Create proxy symlink at old location
    run_cmd "ln -s ../.zshrc '$REPO_DIR/zsh/.zshrc'"
    
    # Commit
    if [ "$DRY_RUN" = false ]; then
        git -C "$REPO_DIR" add -A
        git -C "$REPO_DIR" commit -m "flatten: move zsh/.zshrc to .zshrc"
        log_success "Committed: zsh → .zshrc"
    fi
}

migrate_system() {
    local source_dir="$REPO_DIR/system"
    local target_dir="$REPO_DIR/.config"
    
    log_info "Migrating: system/ → .config/"
    
    if [ ! -d "$source_dir" ]; then
        log_warn "Source directory not found: $source_dir"
        return 0
    fi
    
    # Find files to migrate
    local files
    files=$(find "$source_dir/.config" -type f 2>/dev/null | sed "s|$source_dir/||")
    
    if [ -z "$files" ]; then
        log_warn "No files found in $source_dir"
        return 0
    fi
    
    echo "  Files to migrate:"
    echo "$files" | sed 's/^/    - /'
    
    # Create target directory
    run_cmd "mkdir -p '$target_dir'"
    
    # Move files
    echo "$files" | while read -r f; do
        if [ -e "$source_dir/$f" ]; then
            run_cmd "git mv '$source_dir/$f' '$target_dir/$f' 2>/dev/null || cp -a '$source_dir/$f' '$target_dir/$f'"
        fi
    done
    
    # Remove empty directories
    if [ "$DRY_RUN" = false ]; then
        find "$source_dir" -type d -empty -delete 2>/dev/null || true
    fi
    
    # Create proxy symlink at old location
    run_cmd "ln -s ../../.config '$source_dir/.config'"
    
    # Commit
    if [ "$DRY_RUN" = false ]; then
        git -C "$REPO_DIR" add -A
        git -C "$REPO_DIR" commit -m "flatten: move system/ to .config/"
        log_success "Committed: system → .config/"
    fi
}

# ============================================================================
# VERIFICATION
# ============================================================================

verify_migration() {
    log_info "Running verification checks..."
    
    local failed=0
    
    # Check symlinks resolve correctly
    local symlinks=(
        "$HOME/.config/hypr"
        "$HOME/.config/kitty"
        "$HOME/.config/nvim"
        "$HOME/.config/lazygit"
        "$HOME/.config/mpv"
        "$HOME/.config/spicetify"
        "$HOME/.config/gtk-3.0"
        "$HOME/.config/gtk-4.0"
        "$HOME/.config/matugen"
        "$HOME/.config/user-dirs.dirs"
        "$HOME/.zshrc"
    )
    
    for symlink in "${symlinks[@]}"; do
        if [ -L "$symlink" ]; then
            local resolved
            resolved=$(readlink -f "$symlink" 2>/dev/null || echo "BROKEN")
            if [ -f "$resolved" ] || [ -d "$resolved" ]; then
                log_success "$symlink → $resolved"
            else
                log_error "$symlink → $resolved (BROKEN)"
                ((failed++))
            fi
        elif [ -f "$symlink" ] || [ -d "$symlink" ]; then
            log_info "$symlink (direct, not symlink)"
        else
            log_warn "$symlink (not found)"
        fi
    done
    
    if [ $failed -gt 0 ]; then
        log_error "$failed verification checks failed"
        return 1
    fi
    
    log_success "All verification checks passed"
    return 0
}

# ============================================================================
# UPDATE INSTALL.SH
# ============================================================================

update_install_script() {
    log_info "Updating install.sh to handle new structure..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "Would update install.sh"
        return 0
    fi
    
    cat >> "$REPO_DIR/install.sh" << 'EOF'

# ============================================================================
# NOTE (2026-02-12): Flat migration complete
# ============================================================================
# Config files have been moved to flat structure:
#   - .config/<app>/ instead of <app>/.config/<app>/
#   - .zshrc at repo root
#   - .config/user-dirs.dirs from system/
#
# Proxy symlinks at old paths ensure backward compatibility.
# Stow continues to work without changes.
# ============================================================================
EOF
    
    log_success "install.sh updated"
}

# ============================================================================
# MAIN
# ============================================================================

usage() {
    head -30 "$0" | tail -25
    exit 0
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --dry-run)
                DRY_RUN=true
                ;;
            --package)
                shift
                SINGLE_PACKAGE="$1"
                ;;
            --continue-from)
                shift
                START_FROM="$1"
                ;;
            --verify)
                VERIFY_ONLY=true
                ;;
            --help|-h)
                usage
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                ;;
        esac
        shift
    done
}

main() {
    parse_args "$@"
    
    cd "$REPO_DIR"
    
    echo "========================================"
    echo "  Dotfiles Flat Migration Script"
    echo "========================================"
    echo
    echo "Repo: $REPO_DIR"
    echo "Dry-run: $DRY_RUN"
    echo "Single package: ${SINGLE_PACKAGE:-none}"
    echo "Start from: ${START_FROM:-none}"
    echo
    
    # Verification only mode
    if [ "$VERIFY_ONLY" = true ]; then
        verify_migration
        exit $?
    fi
    
    # Safety checks
    check_git_clean
    ensure_safety_branch
    create_backup
    
    # Check if we should start from a specific package
    local started=false
    if [ -n "$START_FROM" ]; then
        started=true
        log_info "Starting from package: $START_FROM"
    fi
    
    # Migrate regular packages
    for mapping in "${PACKAGES[@]}"; do
        local package="${mapping%%:*}"
        local target="${mapping##*:}"
        
        # Skip if looking for specific package and not there yet
        if [ -n "$START_FROM" ] && [ "$started" = false ]; then
            if [ "$package" = "$START_FROM" ]; then
                started=true
            fi
            continue
        fi
        
        # Skip if filtering to single package
        if [ -n "$SINGLE_PACKAGE" ] && [ "$package" != "$SINGLE_PACKAGE" ]; then
            continue
        fi
        
        migrate_package "$package" "$target"
    done
    
    # Migrate direct file mappings
    for mapping in "${DIRECT_FILES[@]}"; do
        IFS=':' read -r package target source <<< "$mapping"
        
        if [ -n "$START_FROM" ] && [ "$started" = false ]; then
            if [ "$package" = "$START_FROM" ]; then
                started=true
            fi
            continue
        fi
        
        if [ -n "$SINGLE_PACKAGE" ] && [ "$package" != "$SINGLE_PACKAGE" ]; then
            continue
        fi
        
        migrate_direct_file "$package" "$target" "$source"
    done
    
    # Migrate zsh (if not filtered)
    if [ -z "$SINGLE_PACKAGE" ] || [ "$SINGLE_PACKAGE" = "zsh" ]; then
        migrate_zsh
    fi
    
    # Migrate system (if not filtered)
    if [ -z "$SINGLE_PACKAGE" ] || [ "$SINGLE_PACKAGE" = "system" ]; then
        migrate_system
    fi
    
    # Update install script
    update_install_script
    
    # Final verification
    echo
    verify_migration || true
    
    echo
    log_success "Migration complete!"
    echo
    echo "Next steps:"
    echo "  1. Test your applications (kitty, nvim, hypr, etc.)"
    echo "  2. If issues arise, rollback with: git checkout flatten-safety"
    echo "  3. Push changes when ready: git push origin flatten-migration"
    echo
}

main "$@"
