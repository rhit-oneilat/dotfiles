export EDITOR=nvim
export PATH="$HOME/.cargo/bin:$PATH"
export MOZ_ENABLE_WAYLAND=1
alias ll='ls -lah'
alias gs='git status'
alias v='nvim'
alias ff='firefox & exit'
source ~/.github_token
eval "$(starship init bash)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/usr/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/usr/etc/profile.d/conda.sh" ]; then
        . "/usr/etc/profile.d/conda.sh"
    else
        export PATH="/usr/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


[ -f ~/.fzf.bash ] && source ~/.fzf.bash
