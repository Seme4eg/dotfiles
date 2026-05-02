#!/usr/bin/env zsh

alias p="podman"
alias pd="p stop"
alias pstop="p stop"
alias pe="p exec" # <container_name> command (no quotes)
alias pl="p logs --follow --since 10m"
# alias prm="pd rm -fv"

pei() { p exec -it "$1" /bin/sh; }
penv() { pde "$1" env; }

# --- podman-compose ---

alias pc="podman-compose"
alias pcu="pc up -d"
alias pcvu="pc --verbose up -d"
# recreate the container with all its volumes
alias pcur="pcu --force-recreate"
alias pcr="pc restart"
alias pcd="pc down"
# stop container and all its volumes
alias pcdv="pc down -v"

# --- containers ---
alias pdpostgres="p run -d --replace --name postgres -p 5432:5432 \
  -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin \
  -e POSTGRES_HOST_AUTH_METHOD=trust \
  docker.io/postgres"
alias pdapplyddl="psql -U admin -h localhost -p 5432 -d postgres -f"
alias pdrabbitmq="p run -d --replace --name rabbitmq -p 5672:5672 -p 15672:15672 \
  docker.io/rabbitmq:4.0.0-alpine"
alias pdredis="p run -d --replace --name redis -p 6379:6379 \
  docker.io/redis:7.4.0-alpine"
