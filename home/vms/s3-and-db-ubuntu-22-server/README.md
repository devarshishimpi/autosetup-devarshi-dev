# Setup S3 and DB Ubuntu 22.04 Server VM

## Prerequisites

- VM with Ubuntu 22.04 Server installed
- SSH access to the VM
- VM Username set to `devarshi`

## Next Steps

Download and run the installation script

```bash
wget https://autosetup.devarshi.dev/home/vms/s3-and-db-ubuntu-22-server/setup.sh
```

```bash
chmod +x setup.sh
```

```bash
./setup.sh
```

## Setup Local S3 with Backups to AWS S3

1. Install MinIO Server from [here](https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-single-node-single-drive.html)

Alternates: (As of June 2024)

```bash
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio_20240716234641.0.0_amd64.deb -O minio.deb
sudo dpkg -i minio.deb
```

2. Install MinIO MC Client from [here](https://min.io/docs/minio/linux/reference/minio-mc.html#quickstart)

Alternates: (As of June 2024)

```bash
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc

chmod +x $HOME/minio-binaries/mc
export PATH=$PATH:$HOME/minio-binaries/

mc --help
```

4. Download and run the following bash script to setup MinIO Server to run on startup.

```bash
wget https://autosetup.devarshi.dev/home/vms/s3-and-db-ubuntu-22-server/scripts/configure_minio.sh
```

```bash
chmod +x configure_minio.sh
```

```bash
./configure_minio.sh
```

> [!TIP]
> Check the systemctl status if the services are running as expected.
> ```bash
> sudo systemctl status minio
> ```

5. Set region from MinIO Web UI Dashboard to `ap-main1`.

> [!NOTE]
> The MinIO WebUI Dashboard with have the default credentials.
> ```
> username: minio
> password: minioadmin
> ```

### Setup Static CDN

1. Create a bucket named `static-assets` or whatever you want to name it and save it if you are setting up [a static cdn local server](../static-cdn-ubuntu-22-server/README.md) on MinIO Server. Please create S3 credentials for the same and save them.

2. Download and run the following bash script to setup MinIO Server to run on startup.

```bash
wget https://autosetup.devarshi.dev/home/vms/s3-and-db-ubuntu-22-server/scripts/configure_minio_cdn_backup.sh
```

```bash
chmod +x configure_minio_cdn_backup.sh
```

```bash
./configure_minio_cdn_backup.sh
```

> [!IMPORTANT]
> There are multiple environment variables that need to be set in the script. Please set them before running the script.

> [!TIP]
> Check the systemctl status if the services are running as expected.
> ```bash
> sudo systemctl status minio-aws-sync
> ```