#!/usr/bin/env zsh

alias pd="podman"
alias pdrun="pd run --replace --name postgres -p 5432:5432 -d -e POSTGRES_PASSWORD=test postgres:latest"
alias pdrm="pd rm -f"
alias pdup="pd up -d"
