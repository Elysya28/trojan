#!/bin/bash

set -e

HAPROXY_VERSION="2.6.16"
SRC_DIR="/usr/src"

echo "[+] Deteksi OS..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
else
    echo "Tidak bisa mendeteksi OS."
    exit 1
fi

echo "[+] OS terdeteksi: $OS $VER"

# Install dependency
echo "[+] Install dependencies build..."

if [[ "$OS" == "debian" || "$OS" == "ubuntu" ]]; then
    apt update
    DEBIAN_FRONTEND=noninteractive apt install -y \
        wget build-essential libpcre3 libpcre3-dev \
        zlib1g-dev libssl-dev libsystemd-dev
else
    echo "OS $OS belum didukung oleh script ini."
    exit 1
fi

# Download dan compile haproxy
echo "[+] Download & compile HAProxy v$HAPROXY_VERSION"

cd "$SRC_DIR"
wget https://www.haproxy.org/download/2.6/src/haproxy-${HAPROXY_VERSION}.tar.gz
tar xzf haproxy-${HAPROXY_VERSION}.tar.gz
cd haproxy-${HAPROXY_VERSION}

make TARGET=linux-glibc USE_OPENSSL=1 USE_PCRE=1 USE_SYSTEMD=1
make install
ln -sf /usr/local/sbin/haproxy /usr/sbin/haproxy

echo "[✓] HAProxy v$HAPROXY_VERSION berhasil diinstal."

# Cek versi
haproxy -v