# setup pam-gnupg to unlock GnuPG keys on login

echo 'auth     optional  pam_gnupg.so store-only' |
  sudo tee -a /etc/pam.d/system-local-login >/dev/null

echo 'session  optional  pam_gnupg.so' |
  sudo tee -a /etc/pam.d/system-local-login >/dev/null

# gnome-keyring stuff, needed for element
echo '-auth      optional     pam_gnome_keyring.so
-password  optional     pam_gnome_keyring.so    use_authtok
-session   optional     pam_gnome_keyring.so    auto_start' |
  sudo tee -a /etc/pam.d/login >/dev/null
