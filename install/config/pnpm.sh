# install all needed global npm packages

export PNPM_HOME=$HOME/.local/share/pnpm
export PATH=$PNPM_HOME:$PATH
# pnpm add --global typescript-language-server
# pnpm add --global typescript
pnpm add --global yaml-language-server
pnpm add --global bash-language-server
pnpm add --global vscode-json-languageserver
pnpm add --global vscode-langservers-extracted
pnpm add --global dockerfile-language-server-nodejs
