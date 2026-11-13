#!/usr/bin/env bash
# Reissue the Wazuh dashboard certificate so it is valid for 100.100.100.130,
# signed by the existing Wazuh root CA. Run with: sudo bash fix-dashboard-cert.sh
set -euo pipefail

IP=100.100.100.130
USER_HOME=$(getent passwd "${SUDO_USER:-root}" | cut -d: -f6)
TAR=${TAR:-$USER_HOME/wazuh-install-files.tar}
YML=/etc/wazuh-dashboard/opensearch_dashboards.yml
OUT_CA=$USER_HOME/root-ca.crt

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo"; exit 1; }

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT   # removes the extracted CA private key afterwards
tar -xf "$TAR" -C "$WORK"
CA="$WORK/wazuh-install-files/root-ca.pem"
CAKEY="$WORK/wazuh-install-files/root-ca.key"
[ -f "$CA" ] && [ -f "$CAKEY" ] || { echo "root-ca.pem / root-ca.key not found in $TAR"; exit 1; }

getpath() {  # handles quotes, indentation and trailing spaces
  grep -E "^[[:space:]]*$1:" "$YML" | head -1 | cut -d: -f2- | tr -d "\"' \t\r"
}
CERT=$(getpath 'server\.ssl\.certificate')
KEY=$(getpath 'server\.ssl\.key')
CERT=${CERT:-/etc/wazuh-dashboard/certs/dashboard.pem}
KEY=${KEY:-/etc/wazuh-dashboard/certs/dashboard-key.pem}
[ -f "$CERT" ] && [ -f "$KEY" ] || { echo "Could not find current cert/key paths in $YML"; exit 1; }
OWNER=$(stat -c %U:%G "$CERT")
echo "Dashboard cert: $CERT"
echo "Dashboard key:  $KEY"

BACKUP="$(dirname "$CERT").bak-$(date +%Y%m%d-%H%M%S)"
cp -a "$(dirname "$CERT")" "$BACKUP"
echo "Backup of old certs: $BACKUP"

cat > "$WORK/ext.cnf" <<EOF
basicConstraints=CA:FALSE
keyUsage=digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=IP:$IP,IP:127.0.0.1,DNS:wazuh-dashboard,DNS:$(hostname)
EOF

openssl req -new -nodes -newkey rsa:2048 \
  -keyout "$WORK/dash.key" -out "$WORK/dash.csr" \
  -subj "/C=US/L=California/O=Wazuh/OU=Wazuh/CN=wazuh-dashboard"
openssl x509 -req -in "$WORK/dash.csr" -CA "$CA" -CAkey "$CAKEY" -CAcreateserial \
  -out "$WORK/dash.pem" -days 825 -sha256 -extfile "$WORK/ext.cnf"

install -o "${OWNER%%:*}" -g "${OWNER##*:}" -m 400 "$WORK/dash.pem" "$CERT"
install -o "${OWNER%%:*}" -g "${OWNER##*:}" -m 400 "$WORK/dash.key" "$KEY"

install -o "${SUDO_USER:-root}" -g "${SUDO_USER:-root}" -m 644 "$CA" "$OUT_CA"
echo "Root CA for Windows copied to: $OUT_CA"

systemctl restart wazuh-dashboard
echo "Waiting for dashboard to come back..."
for i in $(seq 1 30); do
  if echo | openssl s_client -connect "$IP:443" -CAfile "$CA" -verify_ip "$IP" 2>/dev/null \
       | grep -q "Verify return code: 0 (ok)"; then
    echo "OK: certificate for $IP verifies against the Wazuh root CA."
    exit 0
  fi
  sleep 2
done
echo "Dashboard did not verify within 60s. Check: systemctl status wazuh-dashboard"
echo "To roll back: cp -a $BACKUP/. $(dirname "$CERT")/ && systemctl restart wazuh-dashboard"
exit 1
