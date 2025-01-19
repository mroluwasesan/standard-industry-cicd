## Setting up Jenkins

Create a bash script using the command

```bash
vim jenkin-setup.sh
```

```bash
#!/bin/bash

# Install OpenJDK 17 JRE Headless
sudo apt install openjdk-17-jre-headless -y

# Download Jenkins GPG key
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add Jenkins repository to package manager sources
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package manager repositories
sudo apt-get update

# Install Jenkins
sudo apt-get install jenkins -y
```

Save this script in a file, for example, `jenkin-setup.sh`, and make it executable using:

```bash
chmod +x jenkin-setup.sh
```

Then, you can run the script using:

```bash
./jenkin-setup.sh
```

This script will automate the installation process of OpenJDK 17 JRE Headless and Jenkins.


## Install docker for future use

```bash
#!/bin/bash

# Update package manager repositories
sudo apt-get update

# Install necessary dependencies
sudo apt-get install -y ca-certificates curl

# Create directory for Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings

# Download Docker's GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# Ensure proper permissions for the key
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository to Apt sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package manager repositories
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 
```

Save this script in a file, for example, `install-docker.sh`, and make it executable using:

```bash
chmod +x install-docker.sh
```

Then, you can run the script using:

```bash
./install-docker.sh
```


## Installing trivy

Create a bash script using the command

```bash
vim trivy-install.sh
```

```bash
#!/bin/bash

# Install prerequisites
sudo apt-get install wget apt-transport-https gnupg lsb-release

# Add Trivy's public signing key
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -

# Add Trivy's repository to APT sources
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list

# Update package manager repositories
sudo apt-get update

# Install Trivy
sudo apt-get install trivy -y
```

Save this script in a file, for example, `trivy-install.sh`, and make it executable using:

```bash
chmod +x trivy-install.sh
```

Then, you can run the script using:

```bash
./trivy-install.sh
```

## Installing kubectl

Create a bash script using the command

```bash
vim k8-setup.sh
```

```bash
#!/bin/bash

# Install prerequisites

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
kubectl version --short --client

```
Save this script in a file, for example, `k8-setup.sh`, and make it executable using:

```bash
chmod +x k8-setup.sh
```

Then, you can run the script using:

```bash
./k8-setup.sh
```


This script will automate the installation process of OpenJDK 17 JRE Headless, Trivy, kubectl and Jenkins.