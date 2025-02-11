#!/usr/bin/env zsh

alias pd="podman"
alias pdpostgres="pd run -d --replace --name postgres -p 5432:5432 \
  -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin \
  -e POSTGRES_HOST_AUTH_METHOD=trust \
  docker.io/postgres:13-alpine3.20" # or just alpine, but need v13 for work
alias applyddl="psql -U admin -h localhost -p 5432 -d postgres -f"
alias pdrabbitmq="pd run -d --replace --name rabbitmq -p 5672:5672 -p 15672:15672 \
  docker.io/rabbitmq:4.0.0-alpine"
alias pdredis="pd run -d --replace --name rabbitmq -p 6379:6379 \
  docker.io/redis:7.4.0-alpine"
alias pdrm="pd rm -f"
alias pdup="pd up -d"
alias pdexec="pd exec -it " # add -U <username>
alias pdlogs="pd logs"      # and <name> of container
