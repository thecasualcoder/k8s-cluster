1. Create a user account using kubeadm command

```sh
$ kubeadm alpha kubeconfig user --client-name endgame > endgame.config
```

```sh
$ vagrant ssh-config
```

copy the content of this file into ~/.ssh/config


2. Copy the user account to your machine

```sh
$ vagrant k8s-master
$ scp k8s-master:<your-desired-user-name>.config .
```

3. Use the user account to access the cluster

```sh
export KUBECONFIG=$PWD/endgame.config
```

4. Try accessing the pod

5. Create necessary kubernetes resources to list the pods

6. Deploy the sample app using the newly created user
