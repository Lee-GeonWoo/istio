## Install Multi-cluster

### Prerequisite
#### Cluster
This guide requires that you have two Kubernetes clusters with any of the supported Kubernetes versions: 1.21, 1.22, 1.23, 1.24.

<br />

### Environment Variables
```
$ export CTX_CLUSTER1=<your cluster1 context>
$ export CTX_CLUSTER2=<your cluster2 context>
```

<br />

### Configure Trust
This guide will assume that you use a common root to generate intermediate certificates for each cluster. Follow the instructions to generate and push a CA certificate secret to both the cluster1 and cluster2 clusters.

#### Plug in CA Certificates
![image](https://user-images.githubusercontent.com/70263403/184887078-ed05e945-ae9b-43b4-bc7f-165a10537898.png)

##### Plug in certificates and key into the cluster
1. In the top-level directory of the Istio installation package, create a directory to hold certificates and keys:
```
$ mkdir -p certs
$ pushd certs
```

2. Generate the root certificate and key:
```
$ make -f ../tools/certs/Makefile.selfsigned.mk root-ca
```

This will generate the following files:

- root-cert.pem: the generated root certificate
- root-key.pem: the generated root key
- root-ca.conf: the configuration for openssl to generate the root certificate
- root-cert.csr: the generated CSR for the root certificate

3. For each cluster, generate an intermediate certificate and key for the Istio CA. The following is an example for cluster1:
```
$ make -f ../tools/certs/Makefile.selfsigned.mk cluster1-cacerts
```

This will generate the following files in a directory named cluster1:

- ca-cert.pem: the generated intermediate certificates
- ca-key.pem: the generated intermediate key
- cert-chain.pem: the generated certificate chain which is used by istiod
- root-cert.pem: the root certificate

4. In each cluster, create a secret cacerts including all the input files ca-cert.pem, ca-key.pem, root-cert.pem and cert-chain.pem. For example, for cluster1:
```
$ kubectl create namespace istio-system
$ kubectl create secret generic cacerts -n istio-system \
      --from-file=cluster1/ca-cert.pem \
      --from-file=cluster1/ca-key.pem \
      --from-file=cluster1/root-cert.pem \
      --from-file=cluster1/cert-chain.pem
```

5. Return to the top-level directory of the Istio installation:
```
$ popd
```
