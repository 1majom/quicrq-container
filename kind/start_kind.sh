kind create cluster

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
kubectl wait --namespace metallb-system \
                --for=condition=ready pod \
                --selector=app=metallb \
                --timeout=40s  \
                --all 
echo "You should check the IP address range with \"docker network inspect -f {{.IPAM.Config}} kind\" and change it if needed in the next yaml"
echo "kubectl apply -f kind/metallb-config.yaml"
# kubectl apply -f metallb-config.yaml
