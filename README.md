## K8S Cluster

Create your own Kubernetes cluster

## Prerequisite

- [Vagrant](https://www.vagrantup.com/) 2.26
- [Virtualbox](https://www.virtualbox.org/) 6.0
- [Ansible](https://www.ansible.com/) 2.9.2
- [Vagrant DigitalOcean](https://github.com/devopsgroup-io/vagrant-digitalocean)

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

## Usage

### Virtualbox

> When you provision cluster, a kubeconfig file generated with `$USER`.conf and placed inside `$HOME/.kube/configs`, ensure to backup the file if one exists in the path

To setup k8s cluster locally using virtualbox, execute

```bash
$ make bootstrap
```

### DigitalOcean

To setup k8s-cluster in DigitalOcean,

1. Follow the instruction [here](https://www.digitalocean.com/docs/api/create-personal-access-token/) to setup personal token
2. Follow the instruction [here](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/to-account/) to upload your ssh key to your digital ocean account
3. `$ cp .env.sample .env`
4. open the `.env` file in your favourite editor and fill in the following details
```yaml
  DIGITAL_OCEAN_TOKEN: the token your have created in step 1
  DIGITAL_OCEAN_SSH_KEY_NAME: the ssh key you have created in step 2
  DIGITAL_OCEAN_PRIVATE_KEY: the private key file name (assumption is the file will be located under $HOME/.ssh/private_key_file_name) for which you have uploaded the public key in step 2
```
5. `$ source .env`

To create the cluster,

```bash
$ make bootstrap
```

To teardown the cluster, execute
```bash
$ make destroy
```

## Troubleshooting

If you face the following issue when issuing `make`, `vagrant` commands for managing kubernetes cluster in digitalocean,

```sh
There was an issue with the JSON response from the DigitalOcean
API at:

Path: /v2/droplets
URI Params: {}

The response JSON from the API was:

Response: Unable to authenticate you
```

simple source the .env file once. (`$ source .env`), also ensure your .env configurations are correct

If you are using Virtualbox 6.1 and for some reason if you are not able to downgrade check the [link](https://github.com/oracle/vagrant-boxes/issues/178)
