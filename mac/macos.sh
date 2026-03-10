#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
  printf 'This script must be run with bash.\n' >&2
  exit 1
fi

if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
  printf 'Run this script directly (for example: ./macos.sh), do not source it.\n' >&2
  return 1 2>/dev/null || exit 1
fi

set -Eeuo pipefail
IFS=$'\n\t'

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

if [[ ! -t 1 ]]; then
  RED=''
  GREEN=''
  YELLOW=''
  NC=''
fi

DRY_RUN=false
FAILED_ITEMS=()

log_info() {
  printf '%b%s%b\n' "$YELLOW" "$1" "$NC"
}

log_success() {
  printf '%b%s%b\n' "$GREEN" "$1" "$NC"
}

log_warn() {
  printf '%b%s%b\n' "$YELLOW" "$1" "$NC"
}

log_error() {
  printf '%b%s%b\n' "$RED" "$1" "$NC" >&2
}

usage() {
  cat <<'EOF'
Usage: ./macos.sh [--dry-run|-n] [--help|-h]

Options:
  -n, --dry-run   Show what would run without making changes
  -h, --help      Show this help message
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n|--dry-run)
        DRY_RUN=true
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
    shift
  done
}

render_command() {
  printf '%q ' "$@"
}

run_cmd() {
  local rendered
  rendered="$(render_command "$@")"
  rendered="${rendered% }"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[dry-run] $rendered"
    return 0
  fi

  "$@"
}

record_failure() {
  FAILED_ITEMS+=("$1")
}

confirm() {
  local prompt="$1"
  local response normalized

  while true; do
    if ! read -r -p "$(printf '%b%s%b' "$YELLOW" "$prompt [y/N]: " "$NC")" response; then
      printf '\n'
      return 1
    fi
    normalized="$(printf '%s' "$response" | tr '[:upper:]' '[:lower:]')"

    case "$normalized" in
      y|yes) return 0 ;;
      n|no|'') return 1 ;;
      *) log_warn "Please answer yes or no." ;;
    esac
  done
}

require_command() {
  local cmd="$1"
  if [[ "$DRY_RUN" == true ]]; then
    return 0
  fi
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_error "Missing required command: $cmd"
    exit 1
  fi
}

append_line_if_missing() {
  local file_path="$1"
  local line="$2"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[dry-run] append to $file_path: $line"
    return 0
  fi

  touch "$file_path"
  if ! grep -Fqx "$line" "$file_path"; then
    printf '%s\n' "$line" >> "$file_path"
  fi
}

install_homebrew() {
  require_command curl

  if [[ "$DRY_RUN" == true ]]; then
    log_info "Installing Homebrew..."
    log_info '[dry-run] /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    log_info "[dry-run] append brew shellenv to $HOME/.zprofile"
    log_success "Homebrew installation successful."
    return 0
  fi

  log_info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    append_line_if_missing "$HOME/.zprofile" 'eval "$(/opt/homebrew/bin/brew shellenv)"'
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
    append_line_if_missing "$HOME/.zprofile" 'eval "$(/usr/local/bin/brew shellenv)"'
  else
    log_error "Homebrew install finished, but brew binary was not found."
    exit 1
  fi

  log_success "Homebrew installation successful."
}

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    log_success "Homebrew is already installed."
    return 0
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[dry-run] Homebrew is not installed. It would be installed now."
  fi

  install_homebrew
}

install_formula() {
  local formula="$1"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[dry-run] brew install $formula"
    return 0
  fi

  require_command brew
  if brew list --formula "$formula" >/dev/null 2>&1; then
    log_success "$formula is already installed."
    return 0
  fi

  log_info "Installing $formula..."
  if run_cmd brew install "$formula"; then
    log_success "$formula installation successful."
    return 0
  fi

  log_error "Failed to install $formula."
  return 1
}

install_cask() {
  local cask="$1"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[dry-run] brew install --cask $cask"
    return 0
  fi

  require_command brew
  if brew list --cask "$cask" >/dev/null 2>&1; then
    log_success "$cask is already installed."
    return 0
  fi

  log_info "Installing $cask..."
  if run_cmd brew install --cask "$cask"; then
    log_success "$cask installation successful."
    return 0
  fi

  log_error "Failed to install $cask."
  return 1
}

install_npm_package() {
  local pkg="$1"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[dry-run] npm install -g $pkg"
    return 0
  fi

  require_command npm
  if npm ls -g --depth=0 "$pkg" >/dev/null 2>&1; then
    log_success "$pkg is already installed globally."
    return 0
  fi

  log_info "Installing npm package $pkg..."
  if run_cmd npm install -g "$pkg"; then
    log_success "$pkg installation successful."
    return 0
  fi

  log_error "Failed to install npm package $pkg."
  return 1
}

tap_brew_repo() {
  local tap="$1"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[dry-run] brew tap $tap"
    return 0
  fi

  require_command brew
  if brew tap | grep -Fxq "$tap"; then
    log_success "$tap is already tapped."
    return 0
  fi

  log_info "Tapping $tap..."
  if run_cmd brew tap "$tap"; then
    log_success "$tap tap successful."
    return 0
  fi

  log_error "Failed to tap $tap."
  return 1
}

ensure_mas_available() {
  if command -v mas >/dev/null 2>&1; then
    return 0
  fi

  log_warn "mas is required for Mac App Store installs."
  if ! confirm "Install mas with Homebrew now?"; then
    return 1
  fi

  install_formula "mas"
}

ensure_mas_signed_in() {
  if [[ "$DRY_RUN" == true ]]; then
    log_info "[dry-run] mas account"
    return 0
  fi

  if mas account >/dev/null 2>&1; then
    return 0
  fi

  log_warn "No App Store account detected for mas. Skipping Mac App Store installs."
  return 1
}

install_mas_app() {
  local app_name="$1"
  local app_id="$2"

  if ! confirm "Do you want to install $app_name from the Mac App Store?"; then
    log_warn "Skipping $app_name."
    return 0
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[dry-run] mas install $app_id # $app_name"
    return 0
  fi

  require_command mas
  if mas list | awk '{print $1}' | grep -Fxq "$app_id"; then
    log_success "$app_name is already installed."
    return 0
  fi

  log_info "Installing $app_name from the Mac App Store..."
  if run_cmd mas install "$app_id"; then
    log_success "$app_name installation successful."
    return 0
  fi

  log_error "Failed to install $app_name."
  return 1
}

parse_args "$@"

if [[ "$DRY_RUN" == true ]]; then
  log_info "Dry-run mode enabled. Commands will be printed but not executed."
fi

if [[ "$(uname -s)" != "Darwin" ]]; then
  log_error "This script is intended for macOS only."
  exit 1
fi

ensure_homebrew

tap_list=(
  "mongodb/brew"
  "teamookla/speedtest"
)

for tap in "${tap_list[@]}"; do
  if confirm "Do you want to tap repository $tap?"; then
    if ! tap_brew_repo "$tap"; then
      record_failure "tap:$tap"
    fi
  else
    log_warn "Skipping tap for $tap."
  fi
done

software_list=(
  "node"
  "speedtest"
  "python@3.12"
  "htop"
  "doctl"
  "ca-certificates"
  "mongodb-community@7.0"
  "mongosh"
  "gcc"
  "wget"
  "git"
  "mas"
  "watchman"
  "go"
  "nmap"
  "xmrig"
  "ffmpeg"
  "pkg-config"
  "cairo"
  "pango"
  "libpng"
  "jpeg"
  "giflib"
  "librsvg"
  "pixman"
)

install_choices=()
for software in "${software_list[@]}"; do
  if confirm "Do you want to install $software?"; then
    install_choices+=("$software")
  else
    log_warn "Skipping $software."
  fi
done

if [[ ${#install_choices[@]} -gt 0 ]]; then
  log_info "Installing selected Homebrew formulae..."
  for software in "${install_choices[@]}"; do
    if ! install_formula "$software"; then
      record_failure "formula:$software"
    fi
  done
else
  log_info "No Homebrew formula selected."
fi

software_list_gui=(
  "mongodb-compass"
  "pgadmin4"
  "tor-browser"
  "obs"
  "notion"
  "vlc"
  "cloudflare-warp"
  "openvpn-connect"
  "figma"
  "spotify"
  "zoom"
  "discord"
  "utm"
  "nomachine"
  "anydesk"
  "gather"
  "sourcetree"
  "free-download-manager"
  "zed"
  "antigravity"
  "codux"
  "redisinsight"
  "protonvpn"
  "cyberduck"
  "postman"
  "github"
  "microsoft-edge"
  "firefox"
  "google-chrome"
  "brave-browser"
  "visual-studio-code"
  "arc"
)

install_choices_gui=()
for software_gui in "${software_list_gui[@]}"; do
  if confirm "Do you want to install $software_gui?"; then
    install_choices_gui+=("$software_gui")
  else
    log_warn "Skipping $software_gui."
  fi
done

if [[ ${#install_choices_gui[@]} -gt 0 ]]; then
  log_info "Installing selected Homebrew casks..."
  for software_gui in "${install_choices_gui[@]}"; do
    if ! install_cask "$software_gui"; then
      record_failure "cask:$software_gui"
    fi
  done
else
  log_info "No Homebrew cask selected."
fi

software_list_npm=(
  "nodemon"
  "typescript"
  "wrangler"
  "yarn"
  "vite"
  "netlify-cli"
  "@tunnel/cli"
  "@vscode/vsce"
  "create-next-app"
  "prettier"
  "@anthropic-ai/claude-code"
)

install_choices_npm=()
for software_npm in "${software_list_npm[@]}"; do
  if confirm "Do you want to install npm package $software_npm?"; then
    install_choices_npm+=("$software_npm")
  else
    log_warn "Skipping npm package $software_npm."
  fi
done

if [[ ${#install_choices_npm[@]} -gt 0 ]]; then
  if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
    log_warn "Node.js/npm not available. Skipping npm package installation."
    record_failure "npm:node-or-npm-missing"
  else
    log_info "Installing selected npm packages..."
    for software_npm in "${install_choices_npm[@]}"; do
      if ! install_npm_package "$software_npm"; then
        record_failure "npm:$software_npm"
      fi
    done
  fi
else
  log_info "No npm package selected."
fi

mas_apps=(
  "803453959|Slack"
  "462062816|Microsoft PowerPoint"
  "462054704|Microsoft Word"
  "462058435|Microsoft Excel"
  "823766827|Microsoft OneDrive"
  "985367838|Microsoft Outlook"
  "409183694|Keynote"
  "409203825|Numbers"
  "409201541|Pages"
  "497799835|XCode"
  "640199958|Apple Developer"
  "310633997|WhatsApp Messenger"
  "747648890|Telegram"
  "1529001798|Hologram Desktop"
  "1176074088|Termius"
  "1561788435|Usage"
  "1440200291|Bitpay"
  "571213070|Davinci Resolve"
  "1645016851|Bluebook"
  "1295203466|Microsoft Remote Desktop"
)

if ensure_mas_available && ensure_mas_signed_in; then
  for app in "${mas_apps[@]}"; do
    app_id="${app%%|*}"
    app_name="${app#*|}"
    if ! install_mas_app "$app_name" "$app_id"; then
      record_failure "mas:$app_name"
    fi
  done
else
  log_warn "Skipping all Mac App Store app installs."
fi

log_info "Clearing local Homebrew cache..."
if [[ "$DRY_RUN" == true ]]; then
  log_info "[dry-run] brew cleanup"
  log_success "Homebrew cleanup simulation complete."
elif run_cmd brew cleanup; then
  log_success "Homebrew cleanup successful."
else
  log_warn "brew cleanup failed."
  record_failure "brew:cleanup"
fi

if [[ ${#FAILED_ITEMS[@]} -gt 0 ]]; then
  log_warn "Script completed with some issues:"
  for item in "${FAILED_ITEMS[@]}"; do
    log_warn " - $item"
  done
  exit 1
fi

log_success "Installation complete."
