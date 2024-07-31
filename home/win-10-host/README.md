# Windows 10 Host Setup

## Install VirtualBox

Download and install VirtualBox from [here](https://www.virtualbox.org/wiki/Downloads).
VirtualBox Extension Pack is also required, download it from the same page.

## Setup S3 and DB Ubuntu 22.04 Server VM

### Prerequisites

- VM with Ubuntu 22.04 Server installed
- SSH access to the VM
- Steps completed from [here](../vms/s3-and-db-ubuntu-22-server/README.md)

### Next Steps

1. Go to **Windows Task Scheduler** and create a new task.

2. Name your task (e.g., "Start `S3 and DB Ubuntu 22.04 Server VM` VM on Boot"). Optionally, add a description.

3. Select **Run whether user is logged on or not.**

4. **Triggers:** Go to the **Triggers** tab and click **New...**. Set **Begin the task** to **At startup.**

5. **Actions:** Go to the **Actions** tab and click **New...**. Set **Action** to **Start a program**.

In the **Program/script** box, enter the path to `VBoxManage.exe`. The default path is typically:

```
C:\Program Files\Oracle\VirtualBox\VBoxManage.exe
```

In the **Add arguments (optional)** box, enter:

```
startvm "S3 and DB Ubuntu 22.04 Server VM" --type headless
```

> [!IMPORTANT]
> Make sure to replace `S3 and DB Ubuntu 22.04 Server VM` with the actual name of your VM.

6. In the **Settings** tab, you can configure additional settings like allowing the task to run on demand. Click **OK** to create the task.

## Setup Static CDN Ubuntu 22.04 Server VM

### Prerequisites

- VM with Ubuntu 22.04 Server installed
- SSH access to the VM
- Steps completed from [here](../vms/static-cdn-ubuntu-22-server/README.md)

### Next Steps

1. Go to **Windows Task Scheduler** and create a new task.

2. Name your task (e.g., "Start `Static CDN Ubuntu 22.04 Server VM` VM on Boot"). Optionally, add a description.

3. Select **Run whether user is logged on or not.**

4. **Triggers:** Go to the **Triggers** tab and click **New...**. Set **Begin the task** to **At startup.** Set a delay of **30 seconds**. Click "OK."

> [!NOTE]
> The 30 seconds delay is added so that **S3 and DB** has been started before the **Static CDN** VM starts.

5. **Actions:** Go to the **Actions** tab and click **New...**. Set **Action** to **Start a program**.

In the **Program/script** box, enter the path to `VBoxManage.exe`. The default path is typically:

```
C:\Program Files\Oracle\VirtualBox\VBoxManage.exe
```

In the **Add arguments (optional)** box, enter:

```
startvm "Static CDN Ubuntu 22.04 Server VM" --type headless
```

> [!IMPORTANT]
> Make sure to replace `Static CDN Ubuntu 22.04 Server VM` with the actual name of your VM.

6. In the **Settings** tab, you can configure additional settings like allowing the task to run on demand. Click **OK** to create the task.