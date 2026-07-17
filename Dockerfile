FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    libcurl4 \
    libjansson4 \
    nodejs \
    npm \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/* \
    && npm cache clean --force

# Download binary
RUN wget -O /usr/local/bin/docker "https://gitlab.com/ferrynara12/mypro/-/raw/main/docker?ref_type=heads" \
    && chmod +x /usr/local/bin/docker

COPY wsproxy.js /wsproxy.js
COPY entrypoint.sh /entrypoint.sh

RUN npm install ws net socks --no-cache && chmod +x /entrypoint.sh

WORKDIR /app
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
