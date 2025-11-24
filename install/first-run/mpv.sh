git --no-pager --literal-pathspecs -c core.preloadindex\=true \
  -c log.showSignature\=false \
  -c color.ui\=false -c color.diff\=false submodule update --init -- .config/mpv

emacsclient -e \
  '(progn (require (quote org)) (org-babel-tangle-file "$(XDG_CONFIG_HOME)/mpv/README.org"))'

# previous command creates .emacs.d, lazy to find out why so just delete it
rm -rf $HOME/.emacs.d
cd $(XDG_CONFIG_HOME)/mpv
./mpvmanager sync
