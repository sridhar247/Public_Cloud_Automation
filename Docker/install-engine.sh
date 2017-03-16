#!/bin/bash
# Docker repo on RHEL 7
# This script sets up the official Docker YUM repo on a RHEL 7 machine.
# See https://docs.docker.com/engine/articles/configuring/#centos-red-hat-enterprise-linux-fedora

# Configuration.
ENGINE_VERSION=1.11.0
DATA_DIR=/data/docker

mkdir -p $DATA_DIR

# Remove existing Docker
yum remove -yt docker docker-selinux

# Install official Docker yum repo. See http://docs.docker.com/engine/installation/rhel/
cat << EOF > /etc/yum.repos.d/docker.repo
[Docker]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

# Install docker-engine
yum install -y "docker-engine-$ENGINE_VERSION"

# Add environment file. Update to match the particular host. Note the renamed
# argument from --add-registry to --registry-mirror. See https://access.redhat.com/articles/881893
cat << EOF > /etc/sysconfig/docker
# /etc/sysconfig/docker

DOCKER_CERT_PATH=/etc/docker

OPTIONS="--selinux-enabled --graph=$DATA_DIR --host=unix:///var/run/docker.sock --group=docker --registry-mirror=https://registry.access.redhat.com"
EOF

# Ensure the system directory is created.
mkdir -p /etc/systemd/system

# Override config since ExecStart cannot be extended (per the systemd docs).
cat << EOF > /etc/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network.target docker.socket
Requires=docker.socket

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/docker
ExecStart=/usr/bin/docker daemon \$OPTIONS
MountFlags=slave
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF

# Reload config and start the daemon
systemctl daemon-reload
systemctl enable docker
systemctl start docker

# Check status
systemctl status -l docker