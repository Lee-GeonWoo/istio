## Multi-primary

Follow this guide to install the **Istio control plane** on **both cluster1 and cluster2**, making each a primary cluster. Both clusters reside on the network1 network, meaning there is direct connectivity between the pods in both clusters.  

In this configuration, each control plane observes the API Servers in both clusters for endpoints.  

Service workloads communicate directly (pod-to-pod) across cluster boundaries.  
<br></br>

![image](https://user-images.githubusercontent.com/70263403/184888541-9f81926c-b17c-4db1-ac55-997d788eb6db.png)

### Configure cluster1 as a primary
```
$ cat <<EOF > cluster1.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  values:
    global:
      meshID: mesh1
      multiCluster:
        clusterName: cluster1
      network: network1
EOF
```

##### Apply the configuration to cluster1:
```
$ istioctl install --context="${CTX_CLUSTER1}" -f cluster1.yaml
```

### Configure cluster2 as a primary
```
$ cat <<EOF > cluster2.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  values:
    global:
      meshID: mesh1
      multiCluster:
        clusterName: cluster2
      network: network1
EOF
```

##### Apply the configuration to cluster2:
```
$ istioctl install --context="${CTX_CLUSTER2}" -f cluster2.yaml
```

### Enable Endpoint Discovery
Install a remote secret in cluster2 that provides access to cluster1’s API server.
```
$ istioctl x create-remote-secret \
    --context="${CTX_CLUSTER1}" \
    --name=cluster1 | \
    kubectl apply -f - --context="${CTX_CLUSTER2}"
```
<br></br>
Install a remote secret in cluster1 that provides access to cluster2’s API server.
```
$ istioctl x create-remote-secret \
    --context="${CTX_CLUSTER2}" \
    --name=cluster2 | \
    kubectl apply -f - --context="${CTX_CLUSTER1}"
```
