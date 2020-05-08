## To init
kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address ${PRIVATE_IP_ADDRESS}

## In case join command is lost
## To create hash digest
## On master
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
kubeadm token create --ttl 1m

## On worker
kubeadm join --token ${TOKEN} --discovery-token-ca-cert-hash sha256:{{ discovery_token_hash.stdout }} {{ master_ip }}:6443

