#!/bin/bash

# Simple one-step deployment script
# Usage: ./deploy-images-simple.sh user@remote-host

REMOTE_HOST="${1:-user@your-server-ip}"

if [ "$REMOTE_HOST" = "user@your-server-ip" ]; then
    echo "Usage: $0 <user@remote-host>"
    echo "Example: $0 user@192.168.1.100"
    exit 1
fi

filename="plane-images-$(date +%Y%m%d%H%M%S).tar.gz"

set -e

echo "Building images..."
docker compose build

echo "Saving images..."
docker compose config --images | xargs docker save | gzip > $filename

echo "Transferring to $REMOTE_HOST..."
scp $filename "$REMOTE_HOST:/tmp/plane-images.tar.gz"

echo "Loading images on remote server..."
ssh "$REMOTE_HOST" "gunzip -c /tmp/plane-images.tar.gz | docker load && rm /tmp/plane-images.tar.gz"

echo "Cleaning up..."
rm $filename

echo "✓ Done! Images deployed to $REMOTE_HOST"

