# setup pam-gnupg to unlock GnuPG keys on login

echo 'auth     optional  pam_gnupg.so store-only' |
  sudo tee -a /etc/pam.d/system-local-login >/dev/null

echo 'session  optional  pam_gnupg.so' |
  sudo tee -a /etc/pam.d/system-local-login >/dev/null
