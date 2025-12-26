# AutoSetup Scripts

A collection of scripts and configurations to automate the setup of development environments, home servers, and virtual machines. This repository simplifies the process of installing software, configuring tools, and deploying services across macOS, Windows, and Linux.

## 📂 Project Structure

- **mac/**: Scripts for macOS setup (Homebrew, CLI tools, Apps).
- **home/**: Docker Compose files and VM configurations for home server hosting.
- **win/**: Utilities for Windows setup.

---

## 🍎 macOS Setup

The `mac/macos.sh` script is an all-in-one installer for setting up a fresh macOS machine.

### Features
- **Homebrew & mas**: Automatically installs Homebrew and Mac App Store CLI.
- **CLI Tools**: Installs essential developer tools like Node.js, Python, Go, Git, Docker, etc.
- **GUI Applications**: Installs popular apps via Homebrew Cask (VS Code, Chrome, Spotify, etc.).
- **Mac App Store Apps**: Automates installation of apps like Xcode, Microsoft Office, Slack, etc.
- **NPM Globals**: Sets up global npm packages like `typescript`, `vite`, `wrangler`.
- **Utilities**: `bulk_ssh.sh` allows for opening multiple SSH sessions in separate Terminal tabs.

### Usage
Run the script from the terminal:
```bash
cd mac
chmod +x macos.sh
./macos.sh
```
*Note: You will be prompted for your `sudo` password and installation choices.*

---

## 🏠 Home Server & Docker

The `home/` directory contains configurations for self-hosted services and virtual machines.

### Docker Services (`home/docker/`)
Ready-to-use `docker-compose` files for various services. 

**Available Services:**
- **Productivity & Automation**: `n8n`, `postiz`.
- **Infrastructure**: `minio-s3` (Object Storage), `wireguard` (VPN), `pihole` (DNS/Adblock).
- **Monitoring & Tools**: `influx-vmboard`, `networktools`.
- **Hosting**: `static-cdn`.

**Usage:**
Navigate to `home/docker` and check for any `.env.example` files to configure your environment variables before running. 
> For detailed configuration instructions, specifically for MinIO and Static CDN, please refer to the `home/docker/README.md`.

```bash
docker-compose -f <filename>.yml up -d
```

### Virtual Machines (`home/vms/`)
Configurations for Ubuntu 22 Server tailored for:
- `s3-and-db-ubuntu-22-server`
- `static-cdn-ubuntu-22-server`

---

## 🪟 Windows Setup

The `win/` directory currently contains specific utilities for Windows environments.

---

## 🚀 Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/devarshishimpi/autosetup-devarshi-dev.git
   cd autosetup-devarshi-dev
   ```

2. Navigate to the relevant directory for your OS or use case.

3. Follow the specific instructions for each script or configuration file.

## ⚠️ Disclaimer
These scripts are customized for personal development workflows. Please review the scripts before running them to ensure they match your requirements.