# Setup Static CDN Ubuntu 22.04 Server VM

## Prerequisites

- VM with Ubuntu 22.04 Server installed
- SSH access to the VM
- VM Username set to `devarshi`
- S3 Ubuntu 22.04 Server VM setup completed and running. Check [here](../s3-and-db-ubuntu-22-server/README.md)

## Next Steps

1. Download and run the installation script

```bash
wget https://autosetup.devarshi.dev/home/vms/static-cdn-ubuntu-22-server/setup.sh
```

```bash
chmod +x setup.sh
```

```bash
./setup.sh
```

> [!NOTE]
> Environment Variables during setup script example:
> ```bash
> MINIO_IP="192.168.1.35"
> MINIO_ACCESS_KEY="minio"
> MINIO_SECRET_KEY="minio123"
> ```

> [!TIP]
> Check the systemctl status if the services are running as expected.
> `sudo systemctl status static-serve`
> `sudo systemctl status s3-sync`