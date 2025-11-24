# install go packages

export GOPATH="$HOME/.local/share/go"

# doom golang setup
go install golang.org/x/tools/gopls@latest
go install github.com/x-motemen/gore/cmd/gore@latest
go install github.com/stamblerre/gocode@latest
go install golang.org/x/tools/cmd/godoc@latest
go install golang.org/x/tools/cmd/goimports@latest
go install golang.org/x/tools/cmd/gorename@latest
go install github.com/cweill/gotests/gotests@latest
go install github.com/fatih/gomodifytags@latest
# emacs docker files formatting
go install github.com/jessfraz/dockfmt@latest
# debugging
go install github.com/go-delve/delve/cmd/dlv@latest
# formatting
go install github.com/segmentio/golines@latest
# +lsp
# go install github.com/nametake/golangci-lint-langserver@latest
