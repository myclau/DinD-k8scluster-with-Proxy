#!\bin\bash
set -o errexit
cd ~
[ -e ~/dind-cluster-v1.8.shp ] && rm -f dind-cluster-v1.8.sh
wget https://cdn.rawgit.com/kubernetes-sigs/kubeadm-dind-cluster/master/fixed/dind-cluster-v1.8.sh
chmod +x dind-cluster-v1.8.sh
./dind-cluster-v1.8.sh up

[ -e ~/DinD-k8scluster-with-Proxy ] && rm -rf DinD-k8scluster-with-Proxy
[ -e ~/master.zip ] && rm -f master.zip


[ "$(dpkg -s unzip | grep Status)" != "Status: install ok installed" ] && sudo apt install unzip -y
wget https://github.com/myclau/DinD-k8scluster-with-Proxy/archive/master.zip
unzip -o master.zip -d ~

cd DinD-k8scluster-with-Proxy-master/nginx-proxy
. proxy-run.sh
cd ~
