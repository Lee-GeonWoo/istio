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
