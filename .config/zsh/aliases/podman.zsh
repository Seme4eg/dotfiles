#!/usr/bin/env zsh

alias pd="podman"
alias pdpostgres="pd run --replace --name postgres -p 5432:5432 -d \
  -e POSTGRES_USER=user -e POSTGRES_PASSWORD=admin \
  -e POSTGRES_HOST_AUTH_METHOD=trust \
  postgres:latest"
alias pdrabbitmq="pd run --replace --name rabbitmq -p 5672:5672 -p 15672:15672 \
  docker.io/rabbitmq:latest"
alias pdrm="pd rm -f"
alias pdup="pd up -d"
alias pdexec="pd exec -it " # add -U <username>
alias pdlogs="pd logs"      # and <name> of container
