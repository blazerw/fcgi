#!/bin/sh

set -e
# clear log
echo "Building..."
. ../database_production.sh
export HOSTNAME=lucky.1702.org
export USERNAME=username
echo "Clearing compiled assets..."
rm -rf public/*
echo "Compiling assets..."
yarn run brunch -- build --production
# To Update This Docker Image use the `make_compile_image.sh` script.
docker run --rm -v "$(pwd)":/app -v "$(pwd)"/../fcgi.cr:/app/fcgi -w /app crystal/build-img:0.23.1 sh -c 'crystal build dispatch.cr -o dispatch.fcgi --error-trace'
echo "Copying files..."
rsync -avz ./dispatch.fcgi $USERNAME@$HOSTNAME:~/$HOSTNAME/dispatch.fcgi
rsync -arvz ./public/ $USERNAME@$HOSTNAME:~/$HOSTNAME/public/
echo "Clearing log..."
ssh $USERNAME@$HOSTNAME echo "" \> /home/$USERNAME/$HOSTNAME/fastcgi.cr.log
echo "Testing..."
echo -n "" > out.html
curl --silent -H "X-MyHeader: 123" http://$HOSTNAME/ > out.html
echo "Results:"
ssh $USERNAME@$HOSTNAME cat /home/$USERNAME/$HOSTNAME/fastcgi.cr.log
