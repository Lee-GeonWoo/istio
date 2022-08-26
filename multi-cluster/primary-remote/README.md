## Primary-Remote

Follow this guide to install the Istio control plane on **cluster1 (the primary cluster)** and configure **cluster2 (the remote cluster)** to use the control plane in cluster1. Both clusters reside on the network1 network, meaning there is direct connectivity between the pods in both clusters.

### Requirements
#### Cluster
This guide requires that you have two Kubernetes clusters with any of the supported Kubernetes versions: 1.21, 1.22, 1.23, 1.24.
<br></br>

#### Environment Variables
|Variable|Description|
|-|-|
|CTX_CLUSTER1|The context name in the default Kubernetes configuration file used for accessing the cluster1 cluster.|
|CTX_CLUSTER2|The context name in the default Kubernetes configuration file used for accessing the cluster2 cluster.|

Set the two variables before proceeding:
```
$ export CTX_CLUSTER1=<your cluster1 context>
$ export CTX_CLUSTER2=<your cluster2 context>
```

#### MetalLB
```

```
<br></br>

In this configuration, cluster cluster1 will observe the API Servers in both clusters for endpoints. In this way, the control plane will be able to provide service discovery for workloads in both clusters.

Service workloads communicate directly (pod-to-pod) across cluster boundaries.

Services in cluster2 will reach the control plane in cluster1 via a dedicated gateway for **east-west** traffic.

![image](https://user-images.githubusercontent.com/70263403/186866036-5e05a2cc-5087-4ff8-b57f-9f750fc58753.png)

### Configure cluster1 as a primary
##### Apply the configuration to cluster1:
```
$ istioctl install --context="${CTX_CLUSTER1}" -f cluster1.yaml
```

### Install the east-west gateway in cluster1
Install a gateway in cluster1 that is dedicated to east-west traffic. By default, this gateway will be public on the Internet. Production systems may require additional access restrictions (e.g. via firewall rules) to prevent external attacks. Check with your cloud vendor to see what options are available.
```
$ samples/multicluster/gen-eastwest-gateway.sh \
    --mesh mesh1 --cluster cluster1 --network network1 | \
    istioctl --context="${CTX_CLUSTER1}" install -y -f -
```

Wait for the east-west gateway to be assigned an external IP address:
```
$ kubectl --context="${CTX_CLUSTER1}" get svc istio-eastwestgateway -n istio-system
NAME                    TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)   AGE
istio-eastwestgateway   LoadBalancer   10.80.6.124   34.75.71.237   ...       51s
```

### Expose the control plane in cluster1
Before we can install on cluster2, we need to first expose the control plane in cluster1 so that services in cluster2 will be able to access service discovery:
```
$ kubectl apply --context="${CTX_CLUSTER1}" -n istio-system -f \
    samples/multicluster/expose-istiod.yaml
```

### Enable API Server Access to cluster2
Before we can configure the remote cluster, we first have to give the control plane in cluster1 access to the API Server in cluster2. This will do the following:

* Enables the control plane to authenticate connection requests from workloads running in cluster2. Without API Server access, the control plane will reject the requests.

* Enables discovery of service endpoints running in cluster2.

To provide API Server access to cluster2, we generate a remote secret and apply it to cluster1:
```
$ istioctl x create-remote-secret \
    --context="${CTX_CLUSTER2}" \
    --name=cluster2 | \
    kubectl apply -f - --context="${CTX_CLUSTER1}"
```

### Configure cluster2 as a remote
Save the address of cluster1’s east-west gateway.
```
$ export DISCOVERY_ADDRESS=$(kubectl \
    --context="${CTX_CLUSTER1}" \
    -n istio-system get svc istio-eastwestgateway \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

Now create a remote configuration for cluster2.
```
$ istioctl install --context="${CTX_CLUSTER2}" -f cluster2.yaml
```


