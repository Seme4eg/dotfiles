#!/usr/bin/env bash

FIELDS=IN-USE,SSID,SECURITY,FREQ,RATE,SIGNAL,BARS # ACTIVE

# awk NF to filter empty lines from output
networks=$(nmcli --fields "$FIELDS" device wifi list | sed '/--/d' | awk NF)
# get ssids list, -t flag returns list without 1st 'header' line
ssids=$(nmcli -t --fields SSID device wifi list | awk NF)
# will b empty if no active connection
initial_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

# Getting ssid of the chosen row by mapping list or rows and list of ssids to
# each other. Reason for this function is that i didn't find another way to
# parse row to get it's ssid. Because of possible spaces in ssids.
get_ssid() {
  # start with 0 index cuz we are also iterating over 'headers' line first
  index=0

  echo "$networks" |
    while read row; do
      # get 'index'th line from the list of ssids
      ssid=$(echo "$ssids" | awk NR==$index)

      # remove all spaces from both strings, maybe not best way to do it idk
      if [ ${row// /} = ${1// /} ]; then
        echo "$ssid"
        break
      fi

      (( index++ ))
    done
}

wifi_on() {
  if [ $(nmcli radio wifi) = "enabled" ]; then
    echo "󰤭  Disable Wi-Fi"
    return 0
  else
    echo "󰤨  Enable Wi-Fi"
    return 1
  fi
}

toggle_wifi() {
  if wifi_on; then
    nmcli radio wifi off
    say -e "Wifi turned off"
    show_menu
  else
    nmcli radio wifi on
    say -t 5000 -e "Wifi turned on. Scanning for networks..."
    sleep 5
    show_menu
  fi
}

ssid_connected() {
  ssid="$1"
  connected_ssid=$(nmcli -t -f active,ssid dev wifi | grep -e '^yes' | cut -d: -f2)
  if [ "$connected_ssid" = "$ssid" ]; then
    echo "Disconnect"
    return 0
  else
    echo "Connect"
    return 1
  fi
}

ssid_saved() {
  # Parses the list of known connections to see if it already contains the SSID.
  # nmcli connection show -- more detailed list of saved networks
  if nmcli -g NAME connection | grep -wqx "$1"; then
    echo "Forget"
    return 0
  else
    return 1
  fi
}

forget_ssid() {
  nmcli connection delete id "$1"
  say -e "Deleted $1."
}

toggle_ssid() {
  ssid="$1"
  vpnstatus=`systemctl is-active openvpn-client@client.service`
  if [ $vpnstatus == 'active' ]; then
    sudo systemctl stop openvpn-client@client.service
    vpnneedsactivation=0
  fi

  _success() {
    say -e "Connected to $1."
    if [ $vpnneedsactivation ]; then
      sleep 5
      sudo systemctl start openvpn-client@client.service
    fi
  }
  _connecting() {
    say -t 2000 -e $(whoami) "Connecting to $1..."
  }

  requires_password() {
    security=$(nmcli -t -f ssid,security dev wifi list | grep "^$1:" | cut -d: -f2)

    if [[ "$security" == "802-11-wireless-security" ]]; then
      return 1
    else
      return 0
    fi
  }

  _connect_protected() {
    wifi_pass=$(rofi -dmenu -password  \
      -theme-str '#entry { placeholder: "password .."; }')
    # if no password provided - quit that script and restore initial connection
    # maybe show return to main menu instead?
    if [ ! "$wifi_pass" ]; then
      # no need to restore initial connection if it wasn't disbanded
      ssid_connected "$initial_ssid" && exit 1
      nmcli connection up id "$initial_ssid"
      say -e "Restored connection to $initial_ssid."
      exit 1
    fi
    _connecting "$ssid"
    nmcli device wifi connect "$1" password "$wifi_pass"
    # if connection failed - prompt again and remove attempted connection from
    # saved ones (cuz it does save connection even if wrong pass was provided)
    if [ $? -gt 0 ]; then
      nmcli connection delete id "$1"
      say -e "Nope."
      _connect_protected "$1"
    fi
    # required to show success notif
    return 0
  }

  if ssid_connected "$ssid"; then
    nmcli connection down id "$ssid" && say -e "Disconnected from $ssid."
  else
    if ssid_saved "$ssid"; then
      _connecting "$ssid"
      nmcli connection up id "$ssid" && _success "$ssid"
    else
      if requires_password; then
        _connect_protected "$ssid" && _success "$ssid"
      else
        # unprotected wifi network
        _connecting "$ssid"
        nmcli device wifi connect "$ssid" password "" && _success "$ssid"
      fi
    fi
  fi
}

# A submenu for a specific device that allows connecting, pairing, and trusting
ssid_menu() {
  ssid="$1"
  goback="Back"

  # Build options
  connected=$(ssid_connected "$ssid")
  saved=$(ssid_saved "$ssid")
  ssid_saved "$ssid" && options="$connected\n$saved\n$goback" ||
      options="$connected\n$goback"

  # Open rofi menu, read chosen option
  chosen="$(echo -e "$options" | rofi -dmenu -i \
    -theme-str "#entry { placeholder: \"$ssid:\"; }" \
    -theme-str '* { font: "syne mono 13"; }')"

  # Match chosen option to command
  case "$chosen" in
    "")
      echo "No option chosen."
      ;;
    "$connected")
      toggle_ssid "$ssid"
      ;;
    "$saved")
      forget_ssid "$ssid"
      ;;
    "$goback")
      show_menu
      ;;
  esac
}

# autoupdate network list
function update_networks() {
  while true; do
    sleep 1
    _networks=$(nmcli --fields "$FIELDS" device wifi list | sed '/--/d' | awk NF)
    _count=`echo "$_networks" | wc -l`
    count=`echo "$networks" | wc -l`

    # -w for 'wait' to not spam tnose notification until user refreshes
    [ $_count -ne $count ] && say -w -e "Networks changed, refresh"
  done
}

show_menu() {
  state=$(wifi_on)

  # start background networks list updating, and kill it later by pid
  update_networks & update_pid=$!

  wifi_on && options="$state\n$networks" || options="$state"
  # force monospace font to not get those fields messy
  chosen_row=$(echo -e "$options\nrefresh" | uniq -u |
                 rofi -dmenu -i -selected-row 2 \
                   -theme-str '#entry { placeholder: "Wi-Fi SSID:"; }' \
                   -theme-str '* { font: "syne mono 13"; }')

  kill $update_pid

  # chosen_ssid might b empty in case we chose 'enable/disable wifi' row
  # so we don't check for it's emptyness
  if [ -z "$chosen_row" ]; then exit; fi

  ssid=$(get_ssid "$chosen_row")

  if [ "$chosen_row" = "$state" ]; then
    toggle_wifi
  elif [ "$chosen_row" = 'refresh' ]; then
    networks=$(nmcli --fields "$FIELDS" device wifi list | sed '/--/d' | awk NF)
    ssids=$(nmcli -t --fields SSID device wifi list | awk NF)
    show_menu
  else
    ssid_menu "$ssid"
  fi
}

show_menu

exit 0
