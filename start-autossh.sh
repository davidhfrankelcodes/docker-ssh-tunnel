#!/bin/sh

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

HEALTHCHECK_ENABLED=${HEALTHCHECK_ENABLED:-true}
HEALTHCHECK_INTERVAL=${HEALTHCHECK_INTERVAL:-60}
HEALTHCHECK_RETRIES=${HEALTHCHECK_RETRIES:-3}
HEALTHCHECK_START_PERIOD=${HEALTHCHECK_START_PERIOD:-30}

log "Starting autossh tunnel from $LOCAL_PORT to $REMOTE_PORT on $REMOTE_SERVER as user $REMOTE_USER"

if [ "$TUNNEL_TYPE" = "R" ]; then
    log "Creating a remote (R) tunnel"
    forward="-R *:${REMOTE_PORT}:localhost:${LOCAL_PORT}"
elif [ "$TUNNEL_TYPE" = "L" ]; then
    log "Creating a local (L) tunnel"
    forward="-L *:${LOCAL_PORT}:localhost:${REMOTE_PORT}"
else
    log "Invalid TUNNEL_TYPE. Please set it to 'L' for local or 'R' for remote in your .env file."
    exit 1
fi

# ExitOnForwardFailure makes ssh exit (so autossh retries) if the port can't be
# bound, e.g. when a stale session still holds it, instead of staying connected
# with no forward.
set -f # Don't glob the `*` in $forward
autossh -NT -M 0 \
    -o "ServerAliveInterval=60" \
    -o "ServerAliveCountMax=2" \
    -o "ExitOnForwardFailure=yes" \
    $forward ${REMOTE_USER}@${REMOTE_SERVER} &
autossh_pid=$!
set +f

# This script is PID 1, so pass `docker stop` on to autossh
trap 'log "Stopping"; kill $autossh_pid 2>/dev/null; exit 0' TERM INT

if [ "$HEALTHCHECK_ENABLED" != "true" ]; then
    wait $autossh_pid
    log "autossh tunnel stopped"
    exit 1
fi

# Watchdog: exit after repeated failed checks so the restart policy restarts the container.
# `sleep & wait` keeps the trap responsive while sleeping.
log "Watchdog enabled: checking every ${HEALTHCHECK_INTERVAL}s, restarting after ${HEALTHCHECK_RETRIES} failures"
sleep "$HEALTHCHECK_START_PERIOD" & wait $!

failures=0
while kill -0 $autossh_pid 2>/dev/null; do
    if /healthcheck.sh; then
        if [ $failures -gt 0 ]; then
            log "Health check recovered"
        fi
        failures=0
    else
        failures=$((failures + 1))
        log "Health check failed ($failures/$HEALTHCHECK_RETRIES)"
        if [ $failures -ge "$HEALTHCHECK_RETRIES" ]; then
            log "Tunnel unhealthy, exiting so the container restarts"
            kill $autossh_pid 2>/dev/null
            exit 1
        fi
    fi
    sleep "$HEALTHCHECK_INTERVAL" & wait $!
done

log "autossh tunnel stopped"
exit 1
