## K8S Cluster

Create your own Kubernetes cluster

## Prerequisite

- [Vagrant](https://www.vagrantup.com/) v2.2.7
- [Virtualbox](https://www.virtualbox.org/) v6.1.4
- [Ansible](https://www.ansible.com/) v2.9.6
- [Vagrant DigitalOcean](https://github.com/devopsgroup-io/vagrant-digitalocean) v0.9.4
- [Direnv](https://github.com/direnv/direnv) v2.21.2

> ensure you have the specified version or above for all the above mentioned tools

## Installation

### Mac OS

1. Vagrant
```sh
$ brew cask install vagrant
```

2. Virtualbox
```sh
$ brew cask install virtualbox
```

3. Ansible
```sh
$ brew install ansible
```

4. Vagrant DigitalOcean
```sh
$ vagrant plugin install vagrant-digitalocean
```

5. Direnv

```sh
$ brew install direnv
```

Make sure to hook direnv into your shell.

If you are using `bash` shell, then add the following line at the end of the ~/.bashrc file:

```bash
eval "$(direnv hook bash)"
```

If you are using `zsh` shell, then add the following line at the end of the ~/.zshrc file:

```bash
eval "$(direnv hook zsh)"
```

for other shell, refer [here](https://github.com/direnv/direnv/blob/master/docs/hook.md)

> Note, if you are have spwaned multiple tabs / windows / split of your terminal, whenever you make changes to .envrc
> ensure to press just enter in all the instances to loaded the updated environment variables into the instance of the
> terminal window
>
> failing to do will result in undesired output

## Usage

> When you provision a cluster, a kubeconfig file generated with `$USER-$CLUSTER_NAME_PREFIX`.conf and placed inside `$HOME/.kube/configs`, ensure to backup the file if one exists in the path

### Virtualbox

1. For setting up VirtualBox, copy the `.envrc.sample` as `.envrc` file and allow it via direnv

```bash
$ cp .envrc.sample .envrc
$ direnv allow .
```

2. To setup k8s cluster locally using virtualbox, execute

```bash
$ make provision.cluster
```

3. To access the cluster, set the KUBECONFIG environment variable as

```bash
$ export KUBECONFIG=$HOME/.kube/configs/$USER.conf
```

4. To teardown the cluster, execute
```bash
$ make destroy
```

## Dobby

To deploy dobby app

```bash
kubectl apply -f https://raw.githubusercontent.com/thecasualcoder/dobby/master/examples/kubernetes/deployment.yaml
kubectl apply -f https://raw.githubusercontent.com/thecasualcoder/dobby/master/examples/kubernetes/service.yaml
```
