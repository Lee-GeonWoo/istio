## Install Istio and Deploy Bookinfo sample
```
$ chmod +x bookinfo_sample.sh
$ source bookinfo_sample.sh
```

The application will start. As each pod becomes ready, the Istio sidecar will be deployed along with it.  
```
$ kubectl get services

NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
details       ClusterIP   10.0.0.212      <none>        9080/TCP   29s
kubernetes    ClusterIP   10.0.0.1        <none>        443/TCP    25m
productpage   ClusterIP   10.0.0.57       <none>        9080/TCP   28s
ratings       ClusterIP   10.0.0.33       <none>        9080/TCP   29s
reviews       ClusterIP   10.0.0.28       <none>        9080/TCP   29s
```
and
```
$ kubectl get pods

NAME                              READY   STATUS    RESTARTS   AGE
details-v1-558b8b4b76-2llld       2/2     Running   0          2m41s
productpage-v1-6987489c74-lpkgl   2/2     Running   0          2m40s
ratings-v1-7dc98c7588-vzftc       2/2     Running   0          2m41s
reviews-v1-7f99cc4496-gdxfn       2/2     Running   0          2m41s
reviews-v2-7d79d5bd5d-8zzqd       2/2     Running   0          2m41s
reviews-v3-7dbcdcbc56-m8dph       2/2     Running   0          2m41s
```

Verify everything is working correctly up to this point.
```
kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"

<title>Simple Bookstore App</title>
```

### Apply Istio Gateway and VirtualService
```
$ kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

gateway.networking.istio.io/bookinfo-gateway created
virtualservice.networking.istio.io/bookinfo created
```

### Apply default destination rules
Before you can use Istio to control the Bookinfo version routing, you need to define the available versions, called subsets, in destination rules.
```
$ kubectl apply -f samples/bookinfo/networking/destination-rule-all.yaml
```
Wait a few seconds for the destination rules to propagate.

You can display the destination rules with the following command:
```
$ kubectl get destinationrules -o yaml
```

## View the dashboard
Use the following instructions to deploy the Kiali dashboard, along with Prometheus, Grafana, and Jaeger.
```
$ kubectl apply -f samples/addons
$ kubectl rollout status deployment/kiali -n istio-system
Waiting for deployment "kiali" rollout to finish: 0 of 1 updated replicas are available...
deployment "kiali" successfully rolled out
```

Access the Kiali dashboard.
```
$ istioctl dashboard kiali
```
or
```
$ kubectl edit svc kiali -n istio-system

spec:
  type: ClusterIP → NodePort
  ports:
  ...
    nodePort: {30000 ~ 32767}     # add nodePort
```


### Cleanup
Delete the routing rules and terminate the application pods
```
chmod +x cleanup.sh
source cleanup.sh
```

