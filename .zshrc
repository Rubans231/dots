# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnosterzak"

plugins=(
    git
    archlinux
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Check archlinux plugin commands here
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/archlinux

# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
#pokemon-colorscripts --no-title -s -r #without fastfetch
# pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -

# fastfetch. Will be disabled if above colorscript was chosen to install
#fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

# Set-up icons for files/directories in terminal using lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# Set-up FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Define the resize trap globally (outside the function)
# This prevents memory issues and ensures it's only defined once.
TRAPWINCH() {
  # Clear the screen to remove artifacts
  clear
  
  # Run the main function
  ff
  
  # Reset the prompt if the ZSH line editor is active
  if [[ -o zle ]]; then
    zle reset-prompt
  fi
}

ff() {
  local config="$HOME/.config/fastfetch/config.jsonc"
  local original_logo="$HOME/.config/fastfetch/exp33.txt"
  
  # --- THE FIX ---
  # Sleep for 50ms to allow Hyprland to finish the "snap" animation
  # so tput reads the final window size, not the spawning size.
  sleep 0.05

  # Get dimensions
  local width=$(tput cols)
  local height=$(tput lines)

  if [ "$height" -lt 35 ] && [ "$width" -lt 50 ]; then
    # Crop: Get bottom 15 lines -> Keep only first 50 chars
    tail -n 15 "$original_logo" | cut -c 1-102 > /tmp/ff_laptop_only.txt
    
    # Run with cropped logo (Laptop) and no text
    fastfetch -c "$config" --logo /tmp/ff_laptop_only.txt -s break

  # --- LOGIC 1: HORIZONTAL SPLIT (Short Window) ---
  elif [ "$height" -lt 35 ]; then
    local max_lines=$((height - 4))
    head -n "$max_lines" "$original_logo" > /tmp/ff_trimmed_logo.txt
    fastfetch -c "$config" --logo /tmp/ff_trimmed_logo.txt -s break

  # --- LOGIC 2: VERTICAL SPLIT (Narrow Window) ---
  elif [ "$width" -lt 110 ]; then
    fastfetch -c "$config" --logo "$original_logo" -s break

  # --- LOGIC 3: FULL SCREEN ---
  else
    fastfetch -c "$config" --logo "$original_logo"
  fi
}


# Run on startup
ff
