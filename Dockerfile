# Alpine image has fast download at pull time
FROM alpine

# Install autossh on Alpine with apk command
RUN apk add --no-cache autossh

# Copy the start and health check scripts
COPY start-autossh.sh /start-autossh.sh
COPY healthcheck.sh /healthcheck.sh

# Make the scripts executable
RUN chmod +x /start-autossh.sh /healthcheck.sh

# Reports health in `docker ps`. This alone doesn't restart anything;
# the watchdog in start-autossh.sh handles restarts.
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 CMD ["/healthcheck.sh"]

# Start the script
CMD ["/start-autossh.sh"]
