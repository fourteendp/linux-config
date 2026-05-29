if (($+commands[starship] )); then
    eval "$(starship init zsh)"
fi
if (($+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi
