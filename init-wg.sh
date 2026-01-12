#!/bin/sh
set -e

SERVER_IP="$1"
: "${WG_PORT:?WG_PORT must be set in .env}"
PORT="$WG_PORT"


if [ -z "$SERVER_IP" ]; then
  echo "WARNING: SERVER_IP not provided." >&2
  echo "         You must manually edit client.conf and set Endpoint." >&2
  SERVER_IP="<ServerIp>"
fi

mkdir -p /config/wg_confs

if [ -f /config/wg_confs/server.conf ]; then
  echo "server.conf already exists, aborting."
  exit 1
fi

SERVER_PRIV=$(wg genkey)
SERVER_PUB=$(echo "$SERVER_PRIV" | wg pubkey)

CLIENT_PRIV=$(wg genkey)
CLIENT_PUB=$(echo "$CLIENT_PRIV" | wg pubkey)

sed \
  -e "s|<PrivateKey>|$CLIENT_PRIV|g" \
  -e "s|<PublicKey>|$SERVER_PUB|g" \
  -e "s|<ServerIp>|$SERVER_IP|g" \
  -e "s|<Port>|$PORT|g" \
  /work/client.example.conf > /work/client.conf

sed \
  -e "s|<PrivateKey>|$SERVER_PRIV|g" \
  -e "s|<PublicKey>|$CLIENT_PUB|g" \
  -e "s|<Port>|$PORT|g" \
  /work/server.example.conf > /config/wg_confs/server.conf

echo "WireGuard configs generated."
