#!/bin/bash
function clean-nginx-proxy {
    if [ "$(docker ps -f name=nginx-proxy -aq)" != "" ];
    then
        docker stop nginx-proxy
        docker rm nginx-proxy
    fi
}
function run-nginx-proxy {
    docker run -d --name=nginx-proxy -p 80:80 --network="kubeadm-dind-net"  --link=kube-master:localnode nginx-proxy

}