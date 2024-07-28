#!/bin/sh

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "Starting autossh tunnel from $LOCAL_PORT to $REMOTE_PORT on $REMOTE_SERVER as user $REMOTE_USER"

if [ "$TUNNEL_TYPE" = "R" ]; then
    log "Creating a remote (R) tunnel"
    autossh -NT -M 0 -o "ServerAliveInterval=60" -o "ServerAliveCountMax=2" -R *:${REMOTE_PORT}:localhost:${LOCAL_PORT} ${REMOTE_USER}@${REMOTE_SERVER}
elif [ "$TUNNEL_TYPE" = "L" ]; then
    log "Creating a local (L) tunnel"
    autossh -NT -M 0 -o "ServerAliveInterval=60" -o "ServerAliveCountMax=2" -L *:${LOCAL_PORT}:localhost:${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_SERVER}
else
    log "Invalid TUNNEL_TYPE. Please set it to 'L' for local or 'R' for remote in your .env file."
    exit 1
fi

log "autossh tunnel stopped"
