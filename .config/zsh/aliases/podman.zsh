#!/usr/bin/env zsh

alias pd="podman"
alias pdu="pd up -d"
alias pdstop="pd stop"
alias pdl="pd logs --follow --since 10m"
alias pdrm="pd rm -fv"
alias pde="pd exec"         # <container_name> command (no quotes)
alias pdexec="pd exec -it " # add -U <username>
pdei() { p exec -it "$1" /bin/sh; }
penv() { pde "$1" env; }

# --- podman-compose ---

alias pc="podman-compose"
alias pcu="pc up -d"
# # recreate the container with all its volumes
# alias pcur="pcu --force-recreate"
# alias pcr="pc restart"
# alias pcd="pc down"
# # stop container and all its volumes
# alias pcdv="pc down -v"

# --- containers ---
alias pdpostgres="pd run -d --replace --name postgres -p 5432:5432 \
  -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin \
  -e POSTGRES_HOST_AUTH_METHOD=trust \
  docker.io/postgres"
alias pdapplyddl="psql -U admin -h localhost -p 5432 -d postgres -f"
alias pdrabbitmq="pd run -d --replace --name rabbitmq -p 5672:5672 -p 15672:15672 \
  docker.io/rabbitmq:4.0.0-alpine"
alias pdredis="pd run -d --replace --name redis -p 6379:6379 \
  docker.io/redis:7.4.0-alpine"
