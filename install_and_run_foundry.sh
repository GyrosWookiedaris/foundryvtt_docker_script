#!/bin/bash

# If one or more of the following variables is in your credentials
# $`"\!
# they have to be escaped with a backslash.
# Example:
# FOUNDRY_PASSWORD_WEB=Start123! 
#      has to change to
# FOUNDRY_PASSWORD_WEB=Start123\!
 
FOUNDRY_USERNAME_WEB=XYZ 
FOUNDRY_PASSWORD_WEB=XYZ
FOUNDRY_ADMIN_KEY_SRV=XYZ
HOSTNAME=XYZ
MAIL=XYZ@DOMAIN.com
FOUNDRY_VERSION=release #Only change if you want to use another version than the actual release

groupadd -g 421 foundry
useradd -u 421 -g foundry -s /usr/sbin/nologin foundry
apt update && apt upgrade
apt install docker.io nginx certbot python3-certbot-nginx -y
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
touch /etc/nginx/sites-available/foundry.conf
ln -s /etc/nginx/sites-available/foundry.conf /etc/nginx/sites-enabled/foundry.conf
mkdir -p /data/foundry/container_cache
mkdir -p /data/foundry/server_scripts

cat << EOF > /etc/nginx/sites-available/foundry.conf
server {
    # Enter your fully qualified domain name or leave blank
    server_name             $HOSTNAME;
    # Listen on port 80 without SSL certificates
    listen                  80;
    # Sets the Max Upload size to 300 MB
    client_max_body_size 300M;
    # Proxy Requests to Foundry VTT
    location / {
        # Set proxy headers
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        # These are important to support WebSockets
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "Upgrade";
        # Make sure to set your Foundry VTT port number
        proxy_pass http://localhost:30000;
    }
}
EOF

service nginx reload
certbot --nginx --non-interactive --agree-tos -m $MAIL --redirect --domains $HOSTNAME

cat << EOF > /data/foundry/docker-compose.yml
version: "3.8"

services:
  foundry:
    image: felddy/foundryvtt:$FOUNDRY_VERSION
    hostname: $HOSTNAME
    init: true
    restart: "unless-stopped"
    volumes:
      - type: bind
        source: /data/foundry
        target: /data
    environment:
      - CONTAINER_CACHE=/data/foundry/container_cache
      - FOUNDRY_USERNAME=$FOUNDRY_USERNAME_WEB
      - FOUNDRY_PASSWORD=$FOUNDRY_PASSWORD_WEB
      - FOUNDRY_ADMIN_KEY=$FOUNDRY_ADMIN_KEY_SRV
      - FOUNDRY_HOSTNAME=$HOSTNAME
      - FOUNDRY_LOCAL_HOSTNAME=$HOSTNAME
      - FOUNDRY_PROXY_PORT=443
      - FOUNDRY_PROXY_SSL=true
    ports:
      - target: 30000
        published: 30000
        protocol: tcp
EOF

cat << EOF > /data/foundry/server_scripts/start.sh
#!/bin/bash
cd /data/foundry
docker-compose up -d
EOF

cat << EOF > /data/foundry/server_scripts/restart.sh
#!/bin/bash
cd /data/foundry
docker-compose restart
EOF

cat << EOF > /data/foundry/server_scripts/stop.sh
#!/bin/bash
cd /data/foundry
docker-compose stop
EOF

cat << EOF > /data/foundry/server_scripts/update_and_restart.sh
#!/bin/bash
cd /data/foundry
docker-compose stop
docker pull felddy/foundryvtt:release
docker-compose up -d
EOF

chown -R foundry:foundry /data/foundry
chmod +x /data/foundry/server_scripts/start.sh
chmod +x /data/foundry/server_scripts/restart.sh
chmod +x /data/foundry/server_scripts/stop.sh
chmod +x /data/foundry/server_scripts/update_and_restart.sh

cd /data/foundry
docker-compose up -d
