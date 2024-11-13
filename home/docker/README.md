# Docker Support for Self Hosting

## Services

The setup consists of two separate Docker Compose files:

1. **docker-compose-minio-s3.yml**:
   - Runs a MinIO S3 server for local development and testing purposes.
   - Listens on ports `9000` (S3 API) and `9001` (web console).
   - Requires the `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD` environment variables to be set.

2. **docker-compose-static-cdn.yml**:
   - Contains the following services:
     - **static-devarshi-dev-cdn**:
       - Runs a Node.js server using the `node:22-alpine` image.
       - Serves the static content from the `./static-devarshi-dev` directory using the `serve` package.
       - Listens on port `8082`.
     - **static-devarshi-dev-cloudflared**:
       - Runs the Cloudflare Tunneling agent (`cloudflare/cloudflared`) to expose the static content to the public internet.
       - Requires the `CLOUDFLARE_STATIC_DEVARSHI_DEV_TUNNEL_TOKEN` environment variable to be set.
     - **static-devarshi-dev-minio-sync**:
       - Periodically synchronizes the `./static-devarshi-dev-cdn` directory with a MinIO S3 storage.
       - Requires the `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD` environment variables to be set.
     - **static-devarshi-dev-aws-backup**:
       - Periodically backs up the `./static-devarshi-dev-cdn` directory to an AWS S3 bucket.
       - Requires the `AWS_STATIC_DEVARSHI_DEV_ACCESS_KEY_ID` and `AWS_STATIC_DEVARSHI_DEV_SECRET_KEY_ID` environment variables to be set.

## Setup

1. Clone the repository and navigate to the project directory.
2. Create a `.env` file in the project directory and set the required environment variables:
   - `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD`

3. Run the MinIO Docker Compose setup:
   ```bash
   docker-compose -f minio-compose.yml up -d
   ```
4. Once the MinIO service is running, create a new bucket named **static-devarshi-dev** using the MinIO web console (`http://localhost:9001`) or the command-line interface.
5. Create another `.env` file in the project directory and set the remaining required environment variables:
   - `CLOUDFLARE_STATIC_DEVARSHI_DEV_TUNNEL_TOKEN`
   - `AWS_STATIC_DEVARSHI_DEV_ACCESS_KEY_ID` and `AWS_STATIC_DEVARSHI_DEV_SECRET_KEY_ID`

6. Run the static-devarshi-dev Docker Compose setup:
   ```bash
   docker-compose -f static-devarshi-dev-compose.yml up -d
   ```

## Usage

1. The static content will be served at `http://localhost:8082`.
2. The MinIO web console will be available at `http://localhost:9001`.

## Notes

- The `./static-devarshi-dev-cdn` directory is used to store the static content that will be served by the `static-devarshi-dev-cdn` service.
- The `./minio-storage` directory is used to store the data for the local MinIO S3 server.
- The Docker Compose configurations use the `internal` network to isolate the services from the outside world.
- The `static-devarshi-dev-minio-sync` and `static-devarshi-dev-aws-backup` services run periodically to keep the static content synchronized and backed up.

> [!IMPORTANT]
> **Incase of the following error in cloudflared:**
> ```
> failed to sufficiently increase receive buffer size (was: 208 kiB, wanted: 2048 kiB, got: 416 kiB). See https://github.com/lucas-clemente/quic-go/wiki/UDP-Receive-Buffer-Size for details.
> ```
> **Please run the following commands:**
> ```bash
> sysctl -w net.core.rmem_max=7500000
> sysctl -w net.core.wmem_max=7500000
> ```
> Then restart the cloudflared service. [Reference](https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes).

