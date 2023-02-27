#!/usr/bin/env bash

# notify-send -a $(whoami) "Getting list of available Wi-Fi networks..."

FIELDS=IN-USE,SSID,SECURITY,FREQ,RATE,SIGNAL,BARS # ACTIVE

# awk NF to filter empty lines from output
wifi_list=$(nmcli --fields "$FIELDS" device wifi list | sed '/--/d' | awk NF)
# get ssids list, -t flag returns list without 1st 'header' line
wifi_ssids=$(nmcli -t --fields SSID device wifi list | awk NF)
# will b empty if no active connection
initial_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

# Getting ssid of the chosen row by mapping list or rows and list of ssids to
# each other. Reason for this function is that i didn't find another way to
# parse row to get it's ssid. Because of possible spaces in ssids.
get_ssid() {
  # start with 0 index cuz we are also iterating over 'headers' line first
  index=0

  echo "$wifi_list" |
    while read row; do
      # get 'index'th line from the list of ssids
      ssid=$(echo "$wifi_ssids" | awk NR==$index)

      # remove all spaces from both strings, maybe not best way to do it idk
      if [ ${row// /} = ${1// /} ]; then
        echo "$ssid"
        break
      fi

      (( index++ ))
    done
}

is_enabled() {
  if [ ! -z "$initial_ssid" ]; then
    echo "睊  Disable Wi-Fi"
    return 0
  else
    echo "睊  Enable Wi-Fi"
    return 1
  fi
}

toggle_enabled() {
  if is_enabled; then
    nmcli radio wifi off
    notify-send -a $(whoami) "Wifi turned off"
  else
    nmcli radio wifi on
    notify-send -a $(whoami) "Wifi turned on"
  fi
}

connect() {
  notify_success() {
    notify-send -a $(whoami) "Connected to $1."
  }
  connecting() {
    notify-send -t 2000 -a $(whoami) "Connecting to $1..."
  }
  rip() {
    notify-send -a $(whoami) "Failed to connect"
  }

  ssid=$(get_ssid "$1")

  # Parses the list of known connections to see if it already contains the SSID.
  # nmcli connection show -- more detailed list of saved networks
  if nmcli -g NAME connection | grep -wx "$ssid"; then
    connecting "$ssid"
    nmcli connection up id "$ssid" && notify_success "$ssid" || rip
  else
    if [[ "$1" =~ "WPA2" ]]; then
      connect_protected "$ssid" && notify_success || rip
    else
      # unprotected wifi network
      connecting "$ssid"
      nmcli device wifi connect "$ssid" password "" &&
        notify_success "$ssid" || rip
    fi
  fi
}

connect_protected() {
  # get password
  wifi_pass=$(rofi -dmenu -password  \
    -theme-str '#entry { placeholder: "password .."; }')
  # if no password provided - quit that script and restore initial connection
  # maybe show return to main menu instead?
  if [ ! "$wifi_pass" ]; then
    nmcli connection up id "$initial_ssid"
    notify-send -a $(whoami) "Restored connection to $initial_ssid."
    exit 1
  fi
  nmcli device wifi connect "$1" password "$wifi_pass"
  # if connection failed - prompt again and remove attempted connection from
  # saved ones (cuz it does save connection even if wrong pass was provided)
  if [ $? -gt 0 ]; then
    nmcli connection delete id "$1"
    connect_protected "$1"
  fi
  # required to show success notif
  return 0
}

show_menu() {
  state=$(is_enabled)
  # force monospace font to not get those fields messy
  chosen_row=$(echo -e "$state\n$wifi_list" | uniq -u |
                 rofi -dmenu -selected-row 2 \
                   -theme-str '#entry { placeholder: "Wi-Fi SSID:"; }' \
                   -theme-str '* { font: "syne mono 13"; }')

  # chosen_ssid might b empty in case we chose 'enable/disable wifi' row
  # so we don't check for it's emptyness
  if [ -z "$chosen_row" ]; then exit
  elif [ "$chosen_row" = "$state" ]; then
    toggle_enabled
  else
    connect "$chosen_row"
  fi
}

show_menu

exit 0
