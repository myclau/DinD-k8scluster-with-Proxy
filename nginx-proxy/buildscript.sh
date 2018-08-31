#!/bin/bash
. lib.sh
#please cd to here before you run the script
docker build -t tmpimage .

clean-nginx-proxy

docker tag tmpimage nginx-proxy
run-nginx-proxy
docker rmi tmpimage