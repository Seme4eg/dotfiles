#!/usr/bin/env bash

# notify-send -a $(whoami) "Getting list of available Wi-Fi networks..."

# some maybe useful fields
# ACTIVE
FIELDS=IN-USE,SSID,SECURITY,FREQ,RATE,SIGNAL,BARS

# awk NF to filter empty lines from output
wifi_list=$(nmcli --fields "$FIELDS" device wifi list | sed '/--/d' | awk NF)
# get ssids list, -t flag returns list without 1st 'header' line
wifi_ssids=$(nmcli -t --fields SSID device wifi list | awk NF)

# Getting ssid of the chosen row by mapping list or rows and list of ssids
# to each other. Reason for this function is that i didn't know find another way
# to parse row to get it's ssid. Because of possible spaces in ssids.
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

disable_row="睊  Disable Wi-Fi"
enable_row="睊  Enable Wi-Fi"
# Really janky way of telling if there is currently a connection
[[ $(nmcli -fields WIFI g) =~ "enabled" ]] &&
  TOGGLE="$disable_row" || TOGGLE="$enable_row"

# force monospace font to not get those fields messy
chosen_row=$(echo -e "$TOGGLE\n$wifi_list" |
                uniq -u |
                rofi -dmenu -selected-row 2 \
                  -theme-str '#entry { placeholder: "Wi-Fi SSID:"; }' \
                  -theme-str '* { font: "Source Code Pro 13"; }')
chosen_ssid=$(get_ssid "$chosen_row")

notify_success() {
  grep "successfully" &&
    notify-send -a $(whoami) "Connection Established" \
      "You are now connected to the Wi-Fi network \"$chosen_ssid\"."
}

if [ -z "$chosen_row" ]; then exit
elif [ "$chosen_row" = "$enable_row" ]; then
  nmcli radio wifi on
elif [ "$chosen_row" = "$disable_row" ]; then
  nmcli radio wifi off
else
  # Parses the list of known connections to see if it already contains the
  # chosen SSID.
  # nmcli connection show -- more detailed list of saved networks
  if [[ ! -z $(nmcli -g NAME connection | grep -wx "$chosen_ssid") ]]; then
    nmcli connection up id "$chosen_ssid" --ask | notify_success
  else
    [[ "$chosen_row" =~ "WPA2" ]] &&
      wifi_pass=$(rofi -dmenu -password  \
        -theme-str '#entry { placeholder: "password .."; }')
    nmcli device wifi connect "$chosen_ssid" password "$wifi_pass" |
      notify_success
  fi
fi
