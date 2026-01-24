certs_path="$HOME/.config/wayvnc/vnc_certs"
key_path="$certs_path/vnc.key"

echo "--- Key and certificate generation for Wayvnc: ---"

openssl genrsa -out "${key_path}" 2048
openssl req -new -key "${key_path}" -out "${certs_path}/vnc.csr"
openssl x509 -req -days 365 -in "${certs_path}/vnc.csr" \
  -signkey "${key_path}" -out "${certs_path}/vnc.crt"
