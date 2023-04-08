#!/usr/bin/env zsh

alias vpns="ssc start openvpn-client@client.service"
alias vpnstop="ssc stop openvpn-client@client.service"
alias vpnr="ssc restart openvpn-client@client.service"
alias vpnen="ssc enable --now openvpn-client@client.service"
alias vpnd="ssc disable openvpn-client@client.service"
alias vpnS="ssc status openvpn-client@client.service"
