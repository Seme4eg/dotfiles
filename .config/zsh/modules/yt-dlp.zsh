#!/usr/bin/env zsh

# yt-dlp download whatever audio u specify
alias ytd='yt-dlp -x --output "${HOME}/Music/__dw/%(artist,creator,uploader)s -% (title)s.%(ext)s" '

ytdcurchapters() { # yt-dlp download current
  url="$(wl-paste)"
  url="${url%?list*}"
  yt-dlp -x --split-chapters --output \
    "chapter:${HOME}/Music/__dw/chapters/%(title)s/%(section_number)03d - %(section_title)s.%(ext)s" \
    "${url}"
}
