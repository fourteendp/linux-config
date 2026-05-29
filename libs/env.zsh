#!/usr/bin/env zsh
export EMAIL=""
export NAME=""

if [ -z "$(git config --global user.email)" ]; then
    if [ ! -z "$EMAIL" ]; then
      git config --global user.email "$EMAIL"
    fi
fi

if [ -z "$(git config --global user.name)" ]; then
    if [ ! -z "$NAME" ]; then
      git config --global user.name "$NAME"
    fi
fi
