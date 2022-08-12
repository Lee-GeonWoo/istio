## Istio multi-cluster in KinD

### Prerequisite
> Docker
```
$ apt update && apt install docker.io -y
$ apt install make
```
<br/>

> kubectl  

Install kubectl
```
$ curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
$ chmod +x kubectl
$ mv ./kubectl /usr/local/bin/kubectl
```
<br/>

> kind

Install kind
```
$ curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
$ chmod +x ./kind
$ mv ./kind /usr/local/bin
```
#### Set number of clusters

```
$ export NUM_CLUSTERS=3
```
<br/>

### Download Istio (ver. 1.14.3)
```
$ curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.14.3 TARGET_ARCH=x86_64 sh -
$ cd istio-1.14.3
$ export PATH=$PWD/bin:$PATH
$ cd
```

### Create kind cluster
```
$ chmod +x util.sh
$ source util.sh
```

### Set MetalLB
```
$ chmod +x metallb.sh
$ source metallb.sh
```

### Install Istio on every clusters
#### Configure Trust
```
$ cd /root/istio/istio
```
```
$
```
