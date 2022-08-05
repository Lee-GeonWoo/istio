## Prerequisite  
1. Setup Istio by following the instructions in the Installation guide.
2. Deploy the Bookinfo sample application.
3. Understand terms such as DestinationRule, VirtualService and subset

### Apply a Virtual Service
##### To route to one version only, you apply virtual services that set the default version for the microservices. In this case, the virtual services will route all traffic to v1 of each microservice.
Run the following command to apply the virtual services:
```
$ kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml
```
