#!/usr/bin/env zsh

# https://go.dev/blog/pprof

gobench() {
  local number="$1"
  if [[ $# -eq 0 ]]; then
    number="1"
  fi

  # 'xxx' to not match any testname, bench=. to bench all code (specify func name
  # to bench a specific function)
  go test -run=xxx -bench=. \
    -benchmem -memprofile "mem${number}.prof" \
    -cpuprofile "cpu${number}.prof" -benchtime=5s >"${number}.bench"
}

profmem() {
  local number="$1"
  if [[ $# -eq 0 ]]; then
    number="1"
  fi

  # ignore nodes that don’t account for at least 10% of the samples
  go tool pprof --nodefraction=0.1 "mem${number}.prof"
}

profcpu() {
  local number="$1"
  if [[ $# -eq 0 ]]; then
    number="1"
  fi

  # ignore nodes that don’t account for at least 10% of the samples
  go tool pprof --nodefraction=0.1 "cpu${number}.prof"
}

bstat() {
  local a="$1"
  local b="$2"
  if [[ $# -lt 2 ]]; then
    a="1"
    b="2"
  fi
  benchstat "${a}.bench" "${b}.bench"
}
