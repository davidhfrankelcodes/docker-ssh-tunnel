# Docker SSH Tunnel

This project sets up an SSH tunnel using Docker and autossh. It allows you to create either a local or remote tunnel to securely forward traffic between ports on different machines.

## Prerequisites

- Docker
- Docker Compose
- SSH key pair for authentication with the remote server

## Quick Start

1. Create a `.env` file based on the `.env.template`:
   ```
   cp .env.template .env
   ```

2. Edit the `.env` file and fill in the required information:
   - `CONTAINER_NAME`: Name for your Docker container
   - `LOCAL_PORT`: The port on your local machine
   - `REMOTE_SERVER`: The address of your remote SSH server
   - `REMOTE_USER`: Your username on the remote server
   - `REMOTE_PORT`: The port on the remote server
   - `TUNNEL_TYPE`: Set to `L` for local tunnel or `R` for remote tunnel

3. Ensure your SSH key is in the `~/.ssh` directory on your local machine.

4. Start the Docker container:
   ```
   docker-compose up -d
   ```

## Usage

1. To stop the tunnel:
   ```
   docker-compose down
   ```

2. To view logs:
   ```
   docker-compose logs -f
   ```

## Tunnel Types

- Local Tunnel (`L`): Forwards a port from the remote server to your local machine.
- Remote Tunnel (`R`): Forwards a port from your local machine to the remote server.

## Advanced Usage and Development

### Building the Image Locally

For development or customization purposes, you can build the image locally:

1. Clone the repository:
   ```
   git clone https://github.com/davidhfrankelcodes/docker-ssh-tunnel.git
   cd docker-ssh-tunnel
   ```

2. Modify the `docker-compose.yaml` file:
   - Comment out the `image:` line
   - Uncomment the `build: .` line

3. Build and start the container:
   ```
   docker-compose up -d --build
   ```

### Customization

- Modify `start-autossh.sh` to add additional SSH options or change autossh behavior.
- Extend the `Dockerfile` to include additional tools or configurations.

## Troubleshooting

- Ensure SSH key permissions are correct and the key is set up on the remote server.
- Verify specified ports are open and not in use by other services.
- Check Docker logs for error messages or connection issues.

## Security Considerations

- Use strong SSH keys and keep them secure.
- Regularly update the Docker image and dependencies.
- Be cautious when exposing ports, especially on public networks.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open-source and available under the [MIT License](LICENSE.md).
