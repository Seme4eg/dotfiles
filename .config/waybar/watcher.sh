#!/usr/bin/env bash

# Dependency: entr

while sleep 0.1; do
  ls ~/.config/waybar/* | entr -pds 'pkill waybar; waybar &'
done
