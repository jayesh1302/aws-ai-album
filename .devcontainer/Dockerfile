# Image for a Python 3 development environment
FROM python:3.9-slim

# Add any tools that are needed beyond Python 3.11
RUN apt-get update && \
    apt-get install -y sudo vim make git zip tree curl wget jq procps net-tools groff mandoc && \
    apt-get install -y gcc libpq-dev && \
    apt-get autoremove -y && \
    apt-get clean -y

# Create a user for VSCode development
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user with passwordless sudo privileges
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash && \
    usermod -aG sudo $USERNAME && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME

## install terraform
ENV TERRAFORM_VERSION 1.5.7
RUN apt-get install unzip wget -y \
    && wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && terraform --version  # Display version for debugging purposes only

## install aws CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && sudo ./aws/install

## install minikube
RUN curl https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -o "minikube-linux-amd64" \
    && sudo install minikube-linux-amd64 /usr/local/bin/minikube \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && echo "alias k='/usr/local/bin/kubectl'" >> /home/$USERNAME/.bash_aliases \
    && echo "alias kns='kubectl config set-context --current --namespace'" >> /home/$USERNAME/.bash_aliases

## install helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    && chmod 700 get_helm.sh \
    && ./get_helm.sh

# Set up the Python development environment
WORKDIR /app
RUN python -m pip install --upgrade pip wheel poetry
COPY .devcontainer/scripts/requirements.txt .
RUN pip install -r requirements.txt

ENV PORT 8080
EXPOSE $PORT

# Force color terminal for docker exec bash
ENV TERM=xterm-256color

# Become a regular user for development
USER $USERNAME