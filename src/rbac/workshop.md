## RBAC

### Service Account

Lets create a subjects (service account)

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: endgame
  namespace: default
```

Now, lets use the created service account to access the cluster using cURL

```sh
$ kubectl get secret | grep endgame
```

export the secret name into a environment variable

```sh
$ export SECRET_NAME=$(kubectl get secret --no-headers | grep endgame | awk '{print $1}')
```

lets look at the content of the secret

```sh
$ kubectl get secret/$SECRET_NAME -o yaml
```

export the secret token into an environment variable

```sh
$ export BEARER_TOKEN=$(kubectl get secret/$SECRET_NAME -o json | jq -r '.data.token' | base64 -D)
```

lets try making a cURL

```sh
$ vagrant ssh k8s-master
```

in the remote machine

```sh
$ ip addr | grep eth0
```

```sh
# Use the ip address from the above command
$ curl -k -H "Authorization: Bearer $BEARER_TOKEN" https://206.189.132.226:6443/api/v1/pods

# list the pods in default namespace
$ curl -k -H "Authorization: Bearer $BEARER_TOKEN" https://206.189.132.226:6443/api/v1/namespaces/default/pods
```

### Role

We need to provide necessary access, so define a role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: basic
  namespace: default
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
  - list
```

How do i know about all the apiGroups and resources availabe in the cluster?

```sh
$ kubectl api-resources
```

Let try again to list the pods

```sh
# Use the ip address from the above command
$ curl -k -H "Authorization: Bearer $BEARER_TOKEN" https://206.189.132.226:6443/api/v1/pods

# list the pods in default namespace
$ curl -k -H "Authorization: Bearer $BEARER_TOKEN" https://206.189.132.226:6443/api/v1/namespaces/default/pods
```

### RoleBinding

We need to associate the role with the subjects

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: endgame-basic-role-binding
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: basic
subjects:
- kind: ServiceAccount
  name: endgame
  namespace: default
```

Let try again to list the pods

```sh
# Use the ip address from the above command
$ curl -k -H "Authorization: Bearer $BEARER_TOKEN" https://206.189.132.226:6443/api/v1/pods

# list the pods in default namespace
$ curl -k -H "Authorization: Bearer $BEARER_TOKEN" https://206.189.132.226:6443/api/v1/namespaces/default/pods

# Try access the pods in kube-system namespace
$ curl -k -H "Authorization: Bearer $BEARER_TOKEN" https://206.189.132.226:6443/api/v1/namespaces/kube-system/pods
```
