# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable command history across sessions
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# Paths
export PATH="$HOME/.config/composer/vendor/bin:$PATH"

# Source Configurations
source ~/.config/p10k/powerlevel10k.zsh-theme
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

if [[ -f ~/.cache/ls_colors ]]; then
  source ~/.cache/ls_colors
fi

# --- THE MAGIC BRIDGE ---
local_config_file="$HOME/.zshrc.local"
if [ -f "$local_config_file" ]; then
  source "$local_config_file"
fi

if [ -f "$HOME/.zshrc.secrets" ]; then
  source "$HOME/.zshrc.secrets"
fi

# Public Aliases (Safe for everyone)
alias cls="clear"
alias update="sudo pacman -Syu"
alias battery="upower -i $(upower -e | grep 'BAT')"
# alias nighton='hyprctl hyprsunset temperature 3500'
alias nightoff='hyprctl hyprsunset identity'
alias code='vscodium'
alias ls='ls --color=auto'
alias storage='sudo du -ah --max-depth=1 . | sort -rh'

# Environment tweaks
export EDITOR=vim
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.spicetify:$PATH"
export KDE_FORCE_DISABLE_PLATFORM_THEME=1

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Run kotofetch only on kitty fullscreen (Cool feature to share!)
if [[ "$TERM" == "xterm-kitty" ]]; then
    cols=$(tput cols)
    rows=$(tput lines)
    if (( cols >= 180 && rows >= 45 )); then
        kotofetch
    fi
fi


nighton() {
  local temp
  case "$1" in
    1) temp=4500 ;; 
    2) temp=3500 ;; 
    3) temp=2500 ;; 
    4) temp=1500 ;; 
    *) temp=${1:-3500} ;;
  esac

  hyprctl hyprsunset temperature "$temp"
  echo "Night mode active: ${temp}K"
}
