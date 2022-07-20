#!/usr/bin/env bash

cd ~/Music/sc

for f in *;  do
  if [ -d "$f" ] && [ ! -h "$f" ]; then
    (cd -- "$f"; ls -R | grep -P ".*sync-conflict.*" | xargs -d"\n" rm 2>/dev/null)
    echo "Folder $(pwd)/$f done";
  fi;
done;
