#!/usr/bin/env zsh

proxy_claude() {
  export HTTPS_PROXY=http://localhost:20171
  export HTTP_PROXY=http://localhost:20171
  claude
}

proxy() {
  export HTTPS_PROXY=http://localhost:20171
  export HTTP_PROXY=http://localhost:20171
  export https_proxy=http://localhost:20171
  export http_proxy=http://localhost:20171
  export all_proxy=socks5://localhost:20170
  zsh
}

# in case of error when starting zapret service:
# 'Error: No such file or directory; did you mean chain 'ts-input' in table ip 'filter'? flush chain inet zapretunix output'
alias fixzapret="sudo nft delete table inet zapretunix"
