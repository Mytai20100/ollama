#!/bin/sh
main() {
set -eu

status() { echo ">>> $*" >&2; }
error() { echo "ERROR: $*"; exit 1; }
available() { command -v $1 >/dev/null; }

for TOOL in curl tar; do
    available $TOOL || error "Missing: $TOOL — apt-get install -y $TOOL"
done

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)        ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) error "Unsupported architecture: $ARCH" ;;
esac

VER_PARAM="${OLLAMA_VERSION:+?version=$OLLAMA_VERSION}"
INSTALL_DIR="${OLLAMA_INSTALL_DIR:-$HOME/.local}"
BIN_DIR="$INSTALL_DIR/bin"

mkdir -p "$BIN_DIR" "$INSTALL_DIR/lib/ollama"

URL_BASE="https://ollama.com/download"
FILENAME="ollama-linux-${ARCH}"

status "Downloading Ollama ($ARCH)..."

if available zstd && curl --fail --silent --head --location "${URL_BASE}/${FILENAME}.tar.zst${VER_PARAM}" >/dev/null 2>&1; then
    curl --fail --show-error --location --progress-bar \
        "${URL_BASE}/${FILENAME}.tar.zst${VER_PARAM}" | zstd -d | tar -xf - -C "$INSTALL_DIR"
else
    curl --fail --show-error --location --progress-bar \
        "${URL_BASE}/${FILENAME}.tgz${VER_PARAM}" | tar -xzf - -C "$INSTALL_DIR"
fi

[ -f "$INSTALL_DIR/ollama" ] && ln -sf "$INSTALL_DIR/ollama" "$BIN_DIR/ollama"
[ -f "$BIN_DIR/ollama" ] || error "Binary not found after extraction"
chmod +x "$BIN_DIR/ollama"
status "Done."
}
main
