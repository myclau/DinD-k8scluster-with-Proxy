Requirements
==============
Install docker
--------------
```shell
$ apt-get update -y
$ apt-get upgrade -y
$ #Docker
$ apt-get install apt-transport-https ca-certificates curl software-properties-common -y
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable"
$ apt-get install docker-ce -y

$ #login again
$ usermod -aG docker $(whoami)
```
or install script for linux

```shell
$ sudo apt install unzip
$ wget https://github.com/myclau/DinD-k8scluster-with-Proxy/archive/master.zip
$ unzip master.zip -d ~
$ cd DinD-k8scluster-with-Proxy-master/install-script
$ . install-docker.sh
$ exit 

$ #login again
$ usermod -aG docker $(whoami)

```
Install kubectl
--------------
Reference from https://kubernetes.io/docs/tasks/tools/install-kubectl

For ubuntu
```shell
$ sudo snap install kubectl --classic
```
Set up cluster
==========
Reference from https://github.com/kubernetes-sigs/kubeadm-dind-cluster
```shell
$ wget https://cdn.rawgit.com/kubernetes-sigs/kubeadm-dind-cluster/master/fixed/dind-cluster-v1.8.sh
$ chmod +x dind-cluster-v1.8.sh

$ # start the cluster
$ ./dind-cluster-v1.8.sh up

$ # add kubectl directory to PATH
$ export PATH="$HOME/.kubeadm-dind-cluster:$PATH"

$ kubectl get nodes
NAME                      STATUS    AGE       VERSION
kube-master   Ready     6m        v1.8.6
kube-node-1   Ready     5m        v1.8.6
kube-node-2   Ready     5m        v1.8.6

$ # k8s dashboard available at http://localhost:8080/api/v1/namespaces/kube-system/services/kubernetes-dashboard:/proxy

```

Set up Proxy with nginx
==========
checkout script and config file into cluster host
```shell
$ sudo apt install unzip
$ wget https://github.com/myclau/DinD-k8scluster-with-Proxy/archive/master.zip
$ unzip master.zip -d ~
$ cd DinD-k8scluster-with-Proxy-master/nginx-proxy
$ . buildscript.sh
Sending build context to Docker daemon  4.096kB
Step 1/3 : From nginx:1.15.1
 ---> 8b89e48b5f15
Step 2/3 : COPY default.conf /etc/nginx/conf.d/default.conf
 ---> Using cache
 ---> 90165260042f
Step 3/3 : CMD ["nginx", "-g", "daemon off;"]
 ---> Using cache
 ---> 5a5e9b887b33
Successfully built 5a5e9b887b33
Successfully tagged tmpimage:latest
1b7e3a652c0036b320c8470e2d12bc80729b2b87667aa95843eb5ce2e999a3d5
Untagged: tmpimage:latest
$ docker ps
CONTAINER ID        IMAGE                                COMMAND                  CREATED             STATUS              PORTS                       NAMES
5b8bf7322bdb        nginx-proxy                          "nginx -g 'daemon of…"   18 minutes ago      Up 17 minutes       0.0.0.0:80->80/tcp          nginx-proxy
f9fcad196bd2        mirantis/kubeadm-dind-cluster:v1.8   "/sbin/dind_init sys…"   21 minutes ago      Up 21 minutes       8080/tcp                    kube-node-2
f446476cf1d6        mirantis/kubeadm-dind-cluster:v1.8   "/sbin/dind_init sys…"   21 minutes ago      Up 21 minutes       8080/tcp                    kube-node-1
0166f65c85b8        mirantis/kubeadm-dind-cluster:v1.8   "/sbin/dind_init sys…"   23 minutes ago      Up 23 minutes       127.0.0.1:32770->8080/tcp   kube-master

```

For example for server local ip is 192.168.56.30
you can access the dashboard by:
http://192.168.56.30/api/v1/namespaces/kube-system/services/kubernetes-dashboard:/proxy/

Remark
=======

if you want to clean the all

Assume you check out the script in home dir
```shell
$ wget https://github.com/myclau/DinD-k8scluster-with-Proxy/archive/master.zip
$ unzip master.zip -d ~
```
```shell
$ cd ~/DinD-k8scluster-with-Proxy-master/nginx-proxy
$ ./proxy-clean.sh
nginx-proxy
nginx-proxy
$ cd ~
$ ./dind-cluster-v1.8.sh clean
WARNING: No swap limit support
WARNING: No swap limit support
WARNING: No swap limit support
WARNING: No swap limit support
* Removing container: f9fcad196bd2
f9fcad196bd2
* Removing container: f446476cf1d6
f446476cf1d6
* Removing container: 0166f65c85b8
0166f65c85b8
* Removing volume: kubeadm-dind-kube-master
kubeadm-dind-kube-master
kubeadm-dind-net
```

if you want to start the cluster and proxy after restart
Start in this sequence:
kube-master >  nodes > nginx-proxy
```shell
$ docker ps -a
CONTAINER ID        IMAGE                                COMMAND                  CREATED             STATUS                            PORTS               NAMES
1c23502eb514        nginx-proxy                          "nginx -g 'daemon of…"   3 minutes ago       Exited (0) About a minute ago                         nginx-proxy
906e077375f8        mirantis/kubeadm-dind-cluster:v1.8   "/sbin/dind_init sys…"   7 minutes ago       Exited (137) About a minute ago                       kube-node-2
03d9af5dd43e        mirantis/kubeadm-dind-cluster:v1.8   "/sbin/dind_init sys…"   7 minutes ago       Exited (130) About a minute ago                       kube-node-1
3d5231374470        mirantis/kubeadm-dind-cluster:v1.8   "/sbin/dind_init sys…"   8 minutes ago       Exited (130) About a minute ago                       kube-master
$ docker start kube-master
kube-master
$ docker start kube-node-1
kube-node-1
$ docker start kube-node-2
kube-node-2
$ docker start nginx-proxy
nginx-proxy

```