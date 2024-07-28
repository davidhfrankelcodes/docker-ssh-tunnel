# Alpine image has fast download at pull time
FROM alpine

# Install autossh on Alpine with apk command
RUN apk add --no-cache autossh

# Copy the start script
COPY start-autossh.sh /start-autossh.sh

# Make the script executable
RUN chmod +x /start-autossh.sh

# Start the script
CMD ["/start-autossh.sh"]
