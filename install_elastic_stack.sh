#!/bin/bash
# ======================================================
# Elastic Stack Fresh Install with HTTPS (Ubuntu/Unix)
# Version: v0.1
# Author: Daniel Jeremiah
# ======================================================

set -euo pipefail

PASSWORD="El4sticSecu4ity"
HOSTNAME="elastic.securitysoc"
ES_VERSION="9.x"

echo "=================================================="
echo " Elastic Stack Fresh Installation with HTTPS"
echo " Hostname: $HOSTNAME"
echo " Password: $PASSWORD"
echo "=================================================="

# ------------------------
# 0. Cleanup
# ------------------------
echo "[*] Cleaning up old Elasticsearch and Kibana installs..."
sudo systemctl stop elasticsearch kibana 2>/dev/null || true
sudo apt-get remove --purge -y elasticsearch kibana 2>/dev/null || true
sudo rm -rf /var/lib/elasticsearch /etc/elasticsearch /usr/share/elasticsearch
sudo rm -rf /var/lib/kibana /etc/kibana /usr/share/kibana
sudo rm -f /etc/apt/sources.list.d/elastic-*.list
sudo rm -f /etc/apt/trusted.gpg.d/elastic-archive-keyring.gpg
sudo apt-get autoremove -y
sudo apt-get autoclean -y

# ------------------------
# 1. Dependencies
# ------------------------
echo "[*] Installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y curl gpg apt-transport-https software-properties-common lsb-release net-tools openssl

echo "[*] Adding Elastic GPG key and repository..."
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | \
  sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/elastic-archive-keyring.gpg

echo "deb https://artifacts.elastic.co/packages/${ES_VERSION}/apt stable main" | \
  sudo tee /etc/apt/sources.list.d/elastic-${ES_VERSION}.list

sudo apt-get update -y

# ------------------------
# 2. Grab system IP (from en*)
# ------------------------
echo "[*] Detecting IP address from en* interface..."
IPS=($(ifconfig | awk '/^en/{iface=$1} /inet /{print $2}' | cut -d: -f2))

if [ ${#IPS[@]} -eq 0 ]; then
  read -rp "No en* IPs found. Enter IP manually: " IP_ADDR
elif [ ${#IPS[@]} -eq 1 ]; then
  IP_ADDR=${IPS[0]}
  echo "[*] Found IP: $IP_ADDR"
else
  echo "Multiple IPs found:"
  for i in "${!IPS[@]}"; do echo "$((i+1)). ${IPS[$i]}"; done
  read -rp "Select IP: " choice
  IP_ADDR=${IPS[$((choice-1))]}
fi
echo "[*] Using IP: $IP_ADDR"

sudo sed -i "/$HOSTNAME/d" /etc/hosts
echo "$IP_ADDR    $HOSTNAME" | sudo tee -a /etc/hosts

# ------------------------
# 3. Install Elasticsearch + Kibana
# ------------------------
echo "[*] Installing Elasticsearch + Kibana..."
sudo apt-get install -y elasticsearch kibana

# JVM heap tuning
echo "-Xms512m" | sudo tee /etc/elasticsearch/jvm.options.d/heap.options
echo "-Xmx512m" | sudo tee -a /etc/elasticsearch/jvm.options.d/heap.options

# Kernel limits
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=65536
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=65536" | sudo tee -a /etc/sysctl.conf

# Configure Elasticsearch
sudo sed -i '/network.host/d' /etc/elasticsearch/elasticsearch.yml
sudo sed -i '/cluster.initial_master_nodes/d' /etc/elasticsearch/elasticsearch.yml
echo "network.host: $IP_ADDR" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo "discovery.type: single-node" | sudo tee -a /etc/elasticsearch/elasticsearch.yml

# ------------------------
# 4. Start Elasticsearch and set password
# ------------------------
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch
echo "[*] Waiting 40s for Elasticsearch startup..."
sleep 40

echo "[*] Setting elastic superuser password..."
sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -i <<EOF
y
$PASSWORD
$PASSWORD
EOF

# Verify Elasticsearch
if ! curl -k -u elastic:$PASSWORD "https://$IP_ADDR:9200" >/dev/null; then
  echo "ERROR: Elasticsearch not responding on https://$IP_ADDR:9200"
  echo "Check logs: /var/log/elasticsearch/elasticsearch.log"
  exit 1
fi
echo "[*] Elasticsearch is running successfully on https://$IP_ADDR:9200"

# ------------------------
# 5. Configure Kibana
# ------------------------
sudo /usr/share/kibana/bin/kibana-encryption-keys generate -q | sudo tee -a /etc/kibana/kibana.yml
echo "server.host: \"$HOSTNAME\"" | sudo tee -a /etc/kibana/kibana.yml

sudo systemctl enable kibana
sudo systemctl start kibana
echo "[*] Waiting 40s for Kibana startup..."
sleep 40

if ! curl -s "http://$IP_ADDR:5601" >/dev/null; then
  echo "WARNING: Kibana not yet responding on http://$IP_ADDR:5601"
else
  echo "[*] Kibana is running on http://$IP_ADDR:5601"
fi

# ------------------------
# 6. Enrollment
# ------------------------
ENROLL_TOKEN=$(sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana)
echo "Enrollment Token: $ENROLL_TOKEN"
sudo /usr/share/kibana/bin/kibana-verification-code

echo "=================================================="
echo " Elastic Stack running in HTTP mode"
echo " Kibana: http://$IP_ADDR:5601"
echo " Username: elastic"
echo " Password: $PASSWORD"
echo "=================================================="

# ------------------------
# 7. Enable HTTPS for Kibana
# ------------------------
echo "[*] Enabling HTTPS for Kibana..."
cd /usr/share/elasticsearch

/usr/share/elasticsearch/bin/elasticsearch-certutil ca --out elastic-stack-ca.p12 --pass $PASSWORD <<EOF
$PASSWORD
EOF

/usr/share/elasticsearch/bin/elasticsearch-certutil cert \
  --ca elastic-stack-ca.p12 \
  --dns $HOSTNAME,elastic.security.soc,elastic.security \
  --out kibana-server.p12 \
  --pass $PASSWORD <<EOF
$PASSWORD
$PASSWORD
EOF

sudo openssl pkcs12 -in kibana-server.p12 -out /etc/kibana/kibana-server.crt -clcerts -nokeys -passin pass:$PASSWORD
sudo openssl pkcs12 -in kibana-server.p12 -out /etc/kibana/kibana-server.key -nocerts -nodes -passin pass:$PASSWORD

sudo chown root:kibana /etc/kibana/kibana-server.*
sudo chmod 660 /etc/kibana/kibana-server.*

# Update Kibana config
{
  echo "server.ssl.enabled: true"
  echo "server.ssl.certificate: /etc/kibana/kibana-server.crt"
  echo "server.ssl.key: /etc/kibana/kibana-server.key"
  echo "server.publicBaseUrl: \"https://$HOSTNAME:5601\""
} | sudo tee -a /etc/kibana/kibana.yml

sudo systemctl restart kibana
echo "[*] Waiting 30s for Kibana HTTPS..."
sleep 30

echo "=================================================="
echo " Have Fun..."
echo " Elastic Stack now running in HTTPS mode"
echo " Kibana: https://$IP_ADDR:5601"
echo " Username: elastic"
echo " Password: $PASSWORD"
echo "=================================================="
