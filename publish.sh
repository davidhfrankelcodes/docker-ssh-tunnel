#!/bin/sh
# Builds the image for amd64 and arm64 and pushes it to Docker Hub as
# `latest` plus a UTC timestamp tag (e.g. 20261004203000).
#
# Usage: ./publish.sh
# Requires: `docker login` already done on this machine. No credentials are stored here.

set -eu

IMAGE=${IMAGE:-davidhfrankelcodes/docker-ssh-tunnel}
PLATFORMS=linux/amd64,linux/arm64
BUILDER=multiarch

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

fail() {
    echo "ERROR: $1" >&2
    exit 1
}

cd "$(dirname "$0")"

# Only publish committed code
if [ -n "$(git status --porcelain)" ]; then
    fail "Working tree has uncommitted changes. Commit or stash them first."
fi

# Re-validates stored credentials; fails without prompting if there are none
if ! docker login </dev/null >/dev/null 2>&1; then
    fail "Not logged in to Docker Hub. Run \`docker login\` and try again."
fi

# The default builder can't push multi-platform images, so use a docker-container one
if ! docker buildx inspect "$BUILDER" >/dev/null 2>&1; then
    log "Creating buildx builder '$BUILDER'"
    docker buildx create --name "$BUILDER" --driver docker-container >/dev/null
fi

if ! docker buildx inspect --bootstrap "$BUILDER" | grep -q 'linux/arm64'; then
    fail "Builder can't build arm64. Install QEMU emulation with:
  docker run --privileged --rm tonistiigi/binfmt --install arm64"
fi

TAG=$(date -u '+%Y%m%d%H%M%S')
log "Publishing $IMAGE:latest and $IMAGE:$TAG ($PLATFORMS) from commit $(git rev-parse --short HEAD)"

docker buildx build \
    --builder "$BUILDER" \
    --platform "$PLATFORMS" \
    --pull \
    -t "$IMAGE:latest" \
    -t "$IMAGE:$TAG" \
    --push \
    .

log "Done. Verify with: docker buildx imagetools inspect $IMAGE:$TAG"
