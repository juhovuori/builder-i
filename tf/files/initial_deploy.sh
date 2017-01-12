#!/bin/bash
FILES="builder builder.hcl project.hcl version.json"

cd /home/ubuntu
echo Copying files
for FILE in $FILES
do
  echo $FILE
  sudo -u ubuntu curl -o "$FILE" "https://s3.eu-central-1.amazonaws.com/juhovuori/builder/$FILE"
done
chmod 755 builder
