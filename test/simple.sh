#!/bin/sh

dir=$(dirname $0)
runCommand='/sbin/my_init --enable-insecure-key'
. $dir/tools/run-container.sh

curl -o insecure_key -fSL https://github.com/phusion/baseimage-docker/raw/master/image/insecure_key
chmod 600 insecure_key

scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i insecure_key $dir/simple-dist.sh root@$IP:/root/simple-dist.sh

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i insecure_key root@$IP /bin/bash simple-dist.sh

rm insecure_key

mysql -u demo-user -ppassword -h $IP -e "SELECT * FROM testDB.equipment;"

$dir/tools/delete-container.sh
