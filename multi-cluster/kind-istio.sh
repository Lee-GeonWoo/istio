##################### INSTALL DOCKER ########################
apt update && apt install docker.io -y
apt install make


##################### INSTALL KUBECTL #######################
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv ./kubectl /usr/local/bin/kubectl


##################### INSTALL KIND ##########################
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin


##################### INSTALL ISTIO #########################
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.14.3 TARGET_ARCH=x86_64 sh -
cd istio-1.14.3
export PATH=$PWD/bin:$PATH

cd


##############################################################
##################### CREATE KIND CLUSTER ####################
##############################################################
set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=util.sh
NUM_CLUSTERS="${NUM_CLUSTERS:-2}"
KIND_IMAGE="${KIND_IMAGE:-}"
KIND_TAG="${KIND_TAG:-v1.19.4@sha256:796d09e217d93bed01ecf8502633e48fd806fe42f9d02fdd468b81cd4e3bd40b}"
OS="$(uname)"

function create-clusters() {
  local num_clusters=${1}

  local image_arg=""
  if [[ "${KIND_IMAGE}" ]]; then
    image_arg="--image=${KIND_IMAGE}"
  elif [[ "${KIND_TAG}" ]]; then
    image_arg="--image=kindest/node:${KIND_TAG}"
  fi
  for i in $(seq "${num_clusters}"); do
    kind create cluster --name "cluster${i}" "${image_arg}"
    fixup-cluster "${i}"
    echo

  done
}

function fixup-cluster() {
  local i=${1} # cluster num
  if [ "$OS" != "Darwin" ];then
    # Set container IP address as kube API endpoint in order for clusters to reach kube API servers in other clusters.
    local docker_ip
    docker_ip=$(docker inspect --format='{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "cluster${i}-control-plane")
    kubectl config set-cluster "kind-cluster${i}" --server="https://${docker_ip}:6443"
  fi

  # Simplify context name
  kubectl config rename-context "kind-cluster${i}" "cluster${i}"
}


echo "Creating ${NUM_CLUSTERS} clusters"
create-clusters "${NUM_CLUSTERS}"
kubectl config use-context cluster1

echo "Kind CIDR is $(docker network inspect -f '{{$map := index .IPAM.Config 0}}{{index $map "Subnet"}}' kind)"

echo "Complete"

sed -i 's/kind-//g' /root/.kube/config



###################### SETTING METALLB ########################


for i in $(seq "${NUM_CLUSTERS}"); do
ip1=$((i*10+1))
ip2=$((i*10+10))
cat <<EOF > metallb-configmap-${i}.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 172.18.255.${ip1}-172.18.255.${ip2}
EOF
done

for i in $(seq "${NUM_CLUSTERS}"); do
  echo "Starting metallb deployment in cluster${i}"
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml --context "cluster${i}"
  kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"   --context "cluster${i}"
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml --context "cluster${i}"
  kubectl apply -f ./metallb-configmap-${i}.yaml --context "cluster${i}"
  echo "----"
done

########################################

cd
cd istio-1.14.3

mkdir -p certs
pushd certs
make -f ../tools/certs/Makefile.selfsigned.mk root-ca

for i in $(seq "${NUM_CLUSTERS}"); do
  make -f ../tools/certs/Makefile.selfsigned.mk "cluster${i}-cacerts"
  kubectl create namespace istio-system --context "cluster${i}"
  kubectl --context="cluster${i}" label namespace istio-system topology.istio.io/network="network${i}"
  kubectl create secret generic cacerts -n istio-system --context "cluster${i}" \
      --from-file="cluster${i}/ca-cert.pem" \
      --from-file="cluster${i}/ca-key.pem" \
      --from-file="cluster${i}/root-cert.pem" \
      --from-file="cluster${i}/cert-chain.pem"
  echo "----"
done

popd

for i in $(seq "${NUM_CLUSTERS}"); do
cat <<EOF > cluster${i}.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  values:
    global:
      meshID: mesh1
      multiCluster:
        clusterName: cluster${i}
      network: network${i}
EOF
done

for i in $(seq "${NUM_CLUSTERS}"); do
istioctl install --force --context=cluster${i} -f cluster${i}.yaml -y
samples/multicluster/gen-eastwest-gateway.sh --mesh mesh${i} --cluster cluster${i} --network network${i} | istioctl --context cluster${i} install -y -f -
kubectl --context=cluster${i} apply -n istio-system -f samples/multicluster/expose-services.yaml
done
