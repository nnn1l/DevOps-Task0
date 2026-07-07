# Documentation
_This repository contains the documentation of the DevOps Internship. It covers virtualization setup, Ubuntu installation, and the configuration of essential DevOps tools._

___

## 1. Virtualization & OS Installation
### Hypervisor setup
_**VMware Fusion**_ was chosen as the hypervisor due to its stability and performance on macOS.

___

## 2. OS Installation
_**[Ubuntu Server 26.04 LTS](https://ubuntu.com/download/server/arm)**_ was installed inside virtual machine.

![VM Installation](screenshots/01_select_installation_method.png)

![VM Installation](screenshots/01.2.png)

![VM Installation](screenshots/02_vm_configuration_settings.png)

![VM Installation](screenshots/03_ubuntu_installation_process.png)

![VM Installation](screenshots/04_ssh_key_install_server.png)

![VM Installation](screenshots/05_ubuntu_successfull_login.png)

___

## 2. Package Managers & System Updates
Before installing the tools, the system was fully updated using `apt`:
```bash
sudo apt update && sudo apt upgrade -y
```

___

## 3. Installed DevOps tools
### _Git & Github CLI_
Installed `git` and configured the official `gh` repository to fetch the latest GitHub CLI.
```bash
git --version
gh --version
```

![VM Installation](screenshots/06_git_gh_installed.png)

### _Docker & Docker Compose_
Set up the official Docker repository and added the user to the `docker` group to run containers without `sudo`.
```bash
docker version
docker compose version
```

![VM Installation](screenshots/07_docker&compose_installed.png)

### _Terraform_
Configured the HashiCorp repository using the `noble` distribution package compatibility and successfully installed Terraform.
```bash
terraform -version
```

![VM Installation](screenshots/08_terraform_installed.png)

### _AWS CLI v2_
Downloaded and installed the AWS CLI binary package compiled specifically for the ARM64 (`aarch64`) architecture.
```bash
aws --version
```

![VM Installation](screenshots/09_aws_installed.png)

___

