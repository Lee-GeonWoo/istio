### Download Istio
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.14.3 TARGET_ARCH=x86_64 sh -
cd istio-1.14.3
export PATH=$PWD/bin:$PATH
cd /root


### Install Egress, Ingress gateway and Istio control plane
istioctl install --set profile=demo -y


### Inject Envoy sidecar
kubectl label namespace default istio-injection=enabled

### Deploy the Bookinfo sample application
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

# service/details created
# serviceaccount/bookinfo-details created
# deployment.apps/details-v1 created
# service/ratings created
# serviceaccount/bookinfo-ratings created
# deployment.apps/ratings-v1 created
# service/reviews created
# serviceaccount/bookinfo-reviews created
# deployment.apps/reviews-v1 created
# deployment.apps/reviews-v2 created
# deployment.apps/reviews-v3 created
# service/productpage created
# serviceaccount/bookinfo-productpage created
# deployment.apps/productpage-v1 created

