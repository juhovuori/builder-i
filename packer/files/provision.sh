#!/bin/bash

sudo apt-get -y update
sudo apt-get -y install nginx golang
sudo service nginx start

cat >builder.nginx <<FILE
server {
  listen 80;
  server_name builder.juhovuori.net;

  location / {
    proxy_pass http://127.0.0.1:8080;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}
FILE

cat >builder.service <<FILE
[Unit]
Description=Builder

[Service]
WorkingDirectory=/home/ubuntu
Environment=BUILDER_TOKEN=public-secret
ExecStart=/home/ubuntu/builder server -f https://raw.githubusercontent.com/juhovuori/builder/master/builder.hcl

Restart=always
User=ubuntu

[Install]
WantedBy=multi-user.target
FILE

sudo cp builder.nginx /etc/nginx/sites-available/builder
sudo cp builder.service /etc/systemd/system/builder.service

echo Copying files
for FILE in builder builder.hcl project.hcl version.json
do
  curl -o "$FILE" "https://s3.eu-central-1.amazonaws.com/juhovuori/builder/$FILE"
done
chmod 755 builder

sudo ln -s /etc/nginx/sites-available/builder /etc/nginx/sites-enabled/builder
sudo rm /etc/nginx/sites-enabled/default
sudo service ngingx reload
sudo systemctl daemon-reload
sudo systemctl start builder.service
