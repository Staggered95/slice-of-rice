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
source ~/.config/powerlevel10k/powerlevel10k.zsh-theme

if [[ -f ~/.cache/ls_colors ]]; then
  source ~/.cache/ls_colors
fi

# Aliases (optional)
alias cls="clear"
alias update="sudo pacman -Syu"
alias battery="cat /sys/class/power_supply/BAT0/capacity"
alias nighton='hyprctl hyprsunset temperature 3500'
alias nightoff='hyprctl hyprsunset identity'
alias code='vscodium'
alias ls='ls --color=auto'



# Useful environment tweaks
export EDITOR=vim
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.spicetify:$PATH"
export KDE_FORCE_DISABLE_PLATFORM_THEME=1


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH=$PATH:/home/Shubham/.spicetify

# To customize prompt, run `p10k configure` or edit ~/.config/hypr/themes/p10k/everforest_dark.
#[[ ! -f ~/.config/hypr/themes/p10k/everforest_dark ]] || source ~/.config/hypr/themes/p10k/everforest_dark
#
#
#
# Hook for Oh My Posh
#eval "$(oh-my-posh init zsh --config /usr/share/oh-my-posh/themes/jblab_2021.omp.json)"
#
#eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/themes/everforest.omp.json)"
