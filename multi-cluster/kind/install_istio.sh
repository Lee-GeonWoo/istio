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
