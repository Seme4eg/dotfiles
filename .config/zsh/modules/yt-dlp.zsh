#!/usr/bin/env zsh

# yt-dlp download whatever audio u specify
alias ytd='yt-dlp -x --output "${HOME}/Music/__dw/%(title)s.%(ext)s" '

ytdcur() { # yt-dlp download current
  url="$(wl-paste)"
  url="${url%?list*}"
  yt-dlp -x --output "${HOME}/Music/__dw/%(title)s.%(ext)s" "${url}"
}
