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
To install Git and the official GitHub CLI, run the following commands:
```bash
# Update package list and install Git
sudo apt install git -y

# Add GitHub CLI official repository
sudo mkdir -p -m 755 /etc/apt/keyrings
wget -qO- [https://cli.github.com/packages/githubcli-archive-keyring.gpg](https://cli.github.com/packages/githubcli-archive-keyring.gpg) | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] [https://cli.github.com/packages](https://cli.github.com/packages) stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Install GitHub CLI
sudo apt update && sudo apt install gh -y
```
Verification:
```bash
git --version
gh --version
```

![VM Installation](screenshots/06_git_gh_installed.png)

### _Docker & Docker Compose_
To install Docker Engine and the Docker Compose plugin using the official Docker repository, execute:
```bash
# Remove any conflicting packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg -y; done

# Setup Docker GPG key and repository
sudo apt-get update && sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL [https://download.docker.com/linux/ubuntu/gpg](https://download.docker.com/linux/ubuntu/gpg) | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] [https://download.docker.com/linux/ubuntu](https://download.docker.com/linux/ubuntu) $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker packages
sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Configure non-root user access
sudo usermod -aG docker $USER
newgrp docker
```
Verification:
```bash
docker version
docker compose version
```

![VM Installation](screenshots/07_docker&compose_installed.png)

### _Terraform_
To install Terraform on Ubuntu via HashiCorp official repository (with noble distribution compatibility mapping):
```bash
# Add HashiCorp GPG key
wget -O- [https://apt.releases.hashicorp.com/gpg](https://apt.releases.hashicorp.com/gpg) | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Create repository configuration file for Noble package base
echo "deb [arch=arm64 signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] [https://apt.releases.hashicorp.com](https://apt.releases.hashicorp.com) noble main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Clean apt cache and install Terraform
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get update && sudo apt-get install terraform -y
```
Verification:
```bash
terraform -version
```

![VM Installation](screenshots/08_terraform_installed.png)

### _AWS CLI v2_
Since this installation runs on an Apple Silicon (ARM64) virtual machine, the official AWS CLI v2 binary bundle compiled for the `aarch64` architecture was deployed:
```bash
# Install unzip tool, download and run the installer
sudo apt-get install unzip -y
curl "[https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip](https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip)" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Clean up remaining installation archives
rm -rf aws awscliv2.zip
```
Verification:
```bash
aws --version
```

![VM Installation](screenshots/09_aws_installed.png)

___

