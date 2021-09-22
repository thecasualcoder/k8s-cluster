#! /bin/bash

cd

apt install jq -y
mkdir -p manifests/
cp /srv/kubelet-setup/nginx.yaml ./manifests/
cat ./manifests/nginx.yaml


kubelet --pod-manifest-path=${PWD}/manifests

curl http://localhost:10255/healthz
curl http://localhost:10255/pods  | jq .


## Copy API Server and ETCD
curl http://localhost:8080/api/v1/pods
curl http://localhost:8080/api/v1/nodes

## Restart with API Server
kubelet --pod-manifest-path=${PWD}/manifests  --kubeconfig ./kubeconfig.yaml

kubectl apply -f src/kubelet-setup/nginx-deployment.yaml
