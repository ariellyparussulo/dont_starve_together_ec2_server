#!/bin/bash

DONT_STARVE_TOGETHER_ID=343050

dpkg --add-architecture i386
apt-get update
apt-get install lib32gcc1 lib32stdc++6 libcurl4-gnutls-dev:i386 jq -y

mkdir -p /root/steamcmd
cd /root/steamcmd
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xvzf steamcmd_linux.tar.gz
./steamcmd.sh +login anonymous +force_install_dir /root/steamapps/DST +app_update $DONT_STARVE_TOGETHER_ID validate +quit

mkdir -p /root/.klei/DoNotStarveTogether/Cluster_1/
tee -a /root/.klei/DoNotStarveTogether/Cluster_1/cluster.ini <<EOF
[GAMEPLAY]
game_mode = endless 
max_players = ${max_players}
pvp = false
pause_when_empty = true

[NETWORK]
tick_rate = 30
cluster_description = ${cluster_description}
cluster_name = ${cluster_name}
cluster_intention = ${cluster_intention}
cluster_password = ${cluster_password}

[MISC]
console_enabled = true
EOF

mkdir -p /root/.klei/DoNotStarveTogether/Cluster_1
TOKEN=$(aws ssm get-parameter --name ${cluster_token_parameter} --with-decryption --region ${region} | jq -r .Parameter.Value)
echo -n $TOKEN > /root/.klei/DoNotStarveTogether/Cluster_1/cluster_token.txt

tee -a /opt/dont_starve.sh <<EOF
#!/bin/bash

cd /root/steamapps/DST/bin && ./dontstarve_dedicated_server_nullrenderer -persistent_storage_root /root/.klei
EOF

chmod +x /opt/dont_starve.sh

tee -a /etc/systemd/system/dont_starve.service <<EOF
[Unit]
Description=dont starve together server
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=root
ExecStart=/opt/./dont_starve.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl enable dont_starve
systemctl start dont_starve