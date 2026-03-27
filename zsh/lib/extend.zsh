# starship
eval "$(starship init zsh)"

if [ -z "$(git config --global user.email)" ]; then
    if [ ! -z "$GIT_EMAIL" ]; then
      git config --global user.email "$GIT_EMAIL"
    fi
fi

if [ -z "$(git config --global user.name)" ]; then
    if [ ! -z "$GIT_NAME" ]; then
      git config --global user.name "$GIT_NAME"
    fi
fi
