#!/usr/bin/env zsh

alias pd="podman"
alias pdcreate="pd run --replace --name postgres -p 5432:5432 -d \
-e POSTGRES_USER=user -e POSTGRES_PASSWORD=admin -e POSTGRES_HOST_AUTH_METHOD=trust \
postgres:latest"
alias pdrm="pd rm -f"
alias pdup="pd up -d"
alias pdexec="pd exec -it " # add -U <username>
alias pdlogs="pd logs"      # and <name> of container
