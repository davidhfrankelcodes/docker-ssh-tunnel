#!/bin/sh

# Exits 0 if the tunnel's port accepts a TCP connection, non-zero otherwise.
# Used by the watchdog in start-autossh.sh and by Docker's HEALTHCHECK.

if [ "$TUNNEL_TYPE" = "R" ]; then
    # Reverse tunnel: the forwarded port lives on the remote server
    host=${HEALTHCHECK_HOST:-$REMOTE_SERVER}
    port=${HEALTHCHECK_PORT:-$REMOTE_PORT}
else
    # Local tunnel: the forwarded port lives on this machine
    host=${HEALTHCHECK_HOST:-localhost}
    port=${HEALTHCHECK_PORT:-$LOCAL_PORT}
fi

nc -z -w "${HEALTHCHECK_TIMEOUT:-5}" "$host" "$port"
