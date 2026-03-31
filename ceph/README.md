# helm
helm repo add rook-release https://charts.rook.io/release
helm repo update

# ns
kubectl create namespace rook-ceph


# install operator
helm install rook-ceph rook-release/rook-ceph --namespace rook-ceph

# create cr
kubectl apply -f ceph-cluster.yaml


# dashboard pwd
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{.data.password}" | base64 --decode


