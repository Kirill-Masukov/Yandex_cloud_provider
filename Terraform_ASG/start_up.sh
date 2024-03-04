#!/bin/bash

set -x
echo GET version
version=$(curl -X GET http://127.0.0.1:8500/v1/kv/release_version | jq .[0].Value | tr -d '"' | base64 -d)
my_ip=$(hostname -I)
echo $my_ip

sleep 30

curl -X PUT --data "{ \"Name\" : \"$HOSTNAME\", \"Port\" : 9100, \"Address\" : \"$(echo $my_ip | awk '{print $1}')\"}"  http://62.84.125.29:8500/v1/agent/service/register

docker run -d registry.gitlab.com/kirill/skillbox-diploma:$version
