#!/bin/bash

apt update && apt install -y wireguard iproute2 iptables

PRIVATE_KEY=$(wg genkey)
PUBLIC_KEY=$(echo "$PRIVATE_KEY" | wg pubkey)

echo "=============================="
echo "VPN SERVER KEYS"
echo "=============================="
echo "PRIVATE KEY:"
echo "$PRIVATE_KEY"
echo ""
echo "PUBLIC KEY:"
echo "$PUBLIC_KEY"
echo "=============================="

mkdir -p /etc/wireguard

cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = $PRIVATE_KEY
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOF

wg-quick up wg0

tail -f /dev/null
