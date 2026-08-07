#!/usr/bin/env zsh

# yt-dlp download whatever audio u specify
alias ytd='yt-dlp -x --output "${HOME}/Music/__dw/%(title)s.%(ext)s" '

ytdcur() { # yt-dlp download current
  url="$(wl-paste)"
  url="${url%?list*}"
  yt-dlp -x --output "${HOME}/Music/__dw/%(title)s.%(ext)s" "${url}"
}

# // yt-dlp -j <url> to get the info of the vid
# {
#   "id": "_djhahv07Cw",
#   "title": "Anoana",
#   "thumbnail": "https://i.ytimg.com/vi_webp/_djhahv07Cw/maxresdefault.webp",
#   "album": "Anoana",
#   // use . notation to access the i-th element of an array - %(artists.0)s
#   "artists": ["Heilung", "Christopher Juul", "Maria Franz", "Kai Uwe Faust"],
#   "chapters": null,
#   "creators": ["Heilung", "Christopher Juul", "Maria Franz", "Kai Uwe Faust"],
#   "alt_title": "Anoana",
#   "playlist": "Anoana",
#   "playlist_title": "Anoana",
#   "fulltitle": "Anoana",
#   "artist": "Heilung, Christopher Juul, Maria Franz, Kai Uwe Faust",
#   "creator": "Heilung, Christopher Juul, Maria Franz, Kai Uwe Faust"
# }
