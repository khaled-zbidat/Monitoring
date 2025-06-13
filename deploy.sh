#!/bin/bash
set -e

#installing docker ✅🚀✅
if ! command -v docker &> /dev/null; then
  echo "🚀 Docker not found. Installing..."
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
  echo "✅ Docker is already installed."
fi

# 🔁 Re-check that Docker was installed correctly
if ! command -v docker &> /dev/null; then
  echo "❌ Docker installation failed or not found. Exiting."
  exit 1
fi

sudo docker network inspect monitoring-net >/dev/null 2>&1 || docker network create monitoring-net

sudo docker pull prom/prometheus
sudo docker pull grafana/grafana

sudo docker stop prometheus || true
sudo docker rm prometheus || true

sudo docker stop grafana || true
sudo docker rm grafana || true

sudo docker run -d \
  --name prometheus \
  --network monitoring-net \
  -p 9090:9090 \
  -v $(pwd)/prometheus/prometheus.yaml:/etc/prometheus/prometheus.yaml \
  prom/prometheus

sudo docker run -d \
  --name grafana \
  --network monitoring-net \
  -p 3000:3000 \
  grafana/grafana