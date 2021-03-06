#!/bin/bash

# bat
if [[ $(command -v bat) ]]; then
    curl -L https://raw.githubusercontent.com/sharkdp/bat/master/assets/completions/bat.zsh.in \
        -o $ZSH_CONFIG/completions/_bat
fi

# docker
if [[ $(command -v docker) ]]; then
    curl -L https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker \
        -o $ZSH_CONFIG/completions/_docker
fi

# docker-compose
if [[ $(command -v docker-compose) ]]; then
    curl -fsSL https://raw.githubusercontent.com/docker/compose/master/contrib/completion/zsh/_docker-compose \
        -o $ZSH_CONFIG/completions/_docker-compose
fi

# exa
if [[ $(command -v exa) ]]; then
    curl -fsSL https://raw.githubusercontent.com/ogham/exa/master/completions/zsh/_exa \
        -o $ZSH_CONFIG/completions/_exa
fi

# fd
if [[ $(command -v fd) ]]; then
    curl -fsSL https://raw.githubusercontent.com/sharkdp/fd/master/contrib/completion/_fd \
        -o $ZSH_CONFIG/completions/_fd
fi

# flux
if [[ $(command -v flux) ]]; then
    flux completion zsh > _flux
    mv _flux $ZSH_CONFIG/completions/
fi

# helm
if [[ $(command -v helm) ]]; then
    helm completion zsh > _helm
    mv _helm $ZSH_CONFIG/completions/
fi

# kubectl
if [[ $(command -v kubectl) ]]; then
    kubectl completion zsh > _kubectl
    mv _kubectl $ZSH_CONFIG/completions/
fi
