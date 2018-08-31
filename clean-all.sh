#!\bin\bash
set -o errexit

cd DinD-k8scluster-with-Proxy-master/nginx-proxy
. proxy-clean.sh
cd ~
./dind-cluster-v1.8.sh clean



