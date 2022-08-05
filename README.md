# Download Istio
##### ※ Version 1.14.3  
```
$ curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.14.3 TARGET_ARCH=x86_64 sh -
```

Move to the Istio package directory. For example, if the package is istio-1.14.3:
```
$ cd istio-1.14.3
```

Add the istioctl client to your path
```
$ export PATH=$PWD/bin:$PATH
```

# In single-cluster
```
cd single-cluster
```

# In multi-cluster
```
cd multi-cluster
```
