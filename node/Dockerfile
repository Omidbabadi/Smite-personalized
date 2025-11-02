FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    wireguard-tools \
    iptables \
    curl \
    unzip \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install xray-core
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ARCH="64"; \
    elif [ "$ARCH" = "aarch64" ]; then ARCH="arm64-v8a"; \
    else ARCH="64"; fi && \
    curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-${ARCH}.zip -o /tmp/xray.zip && \
    unzip /tmp/xray.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm /tmp/xray.zip

# Install rathole
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ARCH="x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then ARCH="aarch64"; \
    else ARCH="x86_64"; fi && \
    echo "Getting latest rathole version..." && \
    RATHOLE_VERSION=$(curl -sL https://api.github.com/repos/rapiz1/rathole/releases | jq -r '.[0].tag_name // "v0.4.9"') && \
    echo "Downloading rathole ${RATHOLE_VERSION} for ${ARCH}..." && \
    (curl -L "https://github.com/rapiz1/rathole/releases/download/${RATHOLE_VERSION}/rathole-${ARCH}-unknown-linux-musl.tar.gz" -o /tmp/rathole.tar.gz -f || \
     curl -L "https://github.com/rapiz1/rathole/releases/download/${RATHOLE_VERSION}/rathole-${ARCH}-unknown-linux-gnu.tar.gz" -o /tmp/rathole.tar.gz -f || \
     (echo "Trying alternative download method..." && \
      RATHOLE_ASSET=$(curl -sL "https://api.github.com/repos/rapiz1/rathole/releases" | jq -r --arg arch "$ARCH" '.[0].assets[] | select(.name | contains($arch) and (contains("linux-musl") or contains("linux-gnu"))) | .browser_download_url' | head -1) && \
      if [ -n "$RATHOLE_ASSET" ] && [ "$RATHOLE_ASSET" != "null" ]; then \
          curl -L "$RATHOLE_ASSET" -o /tmp/rathole.tar.gz -f; \
      else \
          echo "Error: Could not find rathole binary for ${ARCH}"; \
          exit 1; \
      fi)) && \
    if [ ! -f /tmp/rathole.tar.gz ] || [ ! -s /tmp/rathole.tar.gz ]; then \
        echo "Error: Failed to download rathole"; \
        exit 1; \
    fi && \
    file /tmp/rathole.tar.gz | grep -qE "(gzip|compressed)" && \
    tar -xzf /tmp/rathole.tar.gz -C /tmp && \
    find /tmp -name "rathole" -type f -executable -exec mv {} /usr/local/bin/ \; && \
    chmod +x /usr/local/bin/rathole && \
    rm -rf /tmp/rathole*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8888

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8888"]

