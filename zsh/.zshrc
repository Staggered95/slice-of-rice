# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable command history across sessions
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt INC_APPEND_HISTORY       # Save commands immediately
setopt SHARE_HISTORY            # Share history across sessions
setopt HIST_IGNORE_ALL_DUPS     # Don’t record duplicate entries
setopt HIST_REDUCE_BLANKS       # Remove unnecessary blanks
setopt HIST_VERIFY              # Don’t execute immediately with ! commands


# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
#ZSH_THEME="powerlevel10k/powerlevel10k"   # or "robbyrussell", "clean", etc.

# Plugins
plugins=(git z sudo archlinux)

# Source OMZ
#source $ZSH/oh-my-zsh.sh
source ~/.config/p10k/powerlevel10k.zsh-theme
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

if [[ -f ~/.cache/ls_colors ]]; then
  source ~/.cache/ls_colors
fi


local_config_file="$HOME/.zshrc.local"

# Check if the local file exists and source it
if [ -f "$local_config_file" ]; then
  source "$local_config_file"
fi



# Aliases (optional)
alias cls="clear"
alias update="sudo pacman -Syu"
alias battery="upower -i $(upower -e | grep 'BAT')"
alias nighton='hyprctl hyprsunset temperature 3500'
alias nightoff='hyprctl hyprsunset identity'
alias hi='sh ~/Scripts/random_waifu.sh'
alias code='vscodium'
alias ls='ls --color=auto'
#alias neofetch='neofetch --ascii_distro arch_small'
alias start='sh ~/Scripts/dev-setup.sh'
alias afc-backup='sh ~/vps_backups/pull_backup.sh'



# Useful environment tweaks
export EDITOR=vim
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.spicetify:$PATH"
export KDE_FORCE_DISABLE_PLATFORM_THEME=1


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH=$PATH:/home/Shubham/.spicetify


# For hey, a linux support
hey() {
	sh ~/Scripts/gemini-chat.sh "$@"
}
hey-reset() {
	sh ~/Scripts/gemini-chat.sh --reset
}


# For the dev helper
dev() {
	~/Scripts/dev "$@"
}
dev-reset() {
	~/Scripts/dev --reset
}

# For the otaku persona
otaku() {
	~/Scripts/otaku "$@"
}
otaku-reset() {
	~/Scripts/otaku --reset
}
