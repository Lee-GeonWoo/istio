## Install Istio and Deploy Bookinfo sample
```
$ chmod +x bookinfo_sample.sh
$ source bookinfo_sample.sh
```

The application will start. As each pod becomes ready, the Istio sidecar will be deployed along with it.  
```
$ kubectl get services

# NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
# details       ClusterIP   10.0.0.212      <none>        9080/TCP   29s
# kubernetes    ClusterIP   10.0.0.1        <none>        443/TCP    25m
# productpage   ClusterIP   10.0.0.57       <none>        9080/TCP   28s
# ratings       ClusterIP   10.0.0.33       <none>        9080/TCP   29s
# reviews       ClusterIP   10.0.0.28       <none>        9080/TCP   29s
```
and
```
$ kubectl get pods

# NAME                              READY   STATUS    RESTARTS   AGE
# details-v1-558b8b4b76-2llld       2/2     Running   0          2m41s
# productpage-v1-6987489c74-lpkgl   2/2     Running   0          2m40s
# ratings-v1-7dc98c7588-vzftc       2/2     Running   0          2m41s
# reviews-v1-7f99cc4496-gdxfn       2/2     Running   0          2m41s
# reviews-v2-7d79d5bd5d-8zzqd       2/2     Running   0          2m41s
# reviews-v3-7dbcdcbc56-m8dph       2/2     Running   0          2m41s
```

Verify everything is working correctly up to this point.
```
kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"

<title>Simple Bookstore App</title>
```

### Apply Istio Gateway and VirtualService
```
$ kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

# gateway.networking.istio.io/bookinfo-gateway created
# virtualservice.networking.istio.io/bookinfo created
```
