# percona-test

This repo replicates an issue with the percona operator, where it always tries to get images 
from the internet, therefore failing to deploy if there is no internet connection even when the images are cached.

We set up the percona cluster once, and it will cache all container images:

```shell
# crete the namespace where we will run the test
kubectl create namespace test-percona

# get the operator running in the cluster, in the test namespace
mkdir -p ./no-vcs
git clone https://github.com/percona/percona-xtradb-cluster-operator.git ./no-vcs/percona-xtradb-cluster-operator
kubectl apply -f ./no-vcs/percona-xtradb-cluster-operator/deploy/bundle.yaml -n test-percona

# install the percona cluster
helm install -f .helm/values.yaml dummy-app .helm -n test-percona
```

Then we remove the percona cluster:

```shell
helm uninstall dummy-app -n test-percona
```

At this point we need to **disconnect our computer from the internet**.

And we try to install the cluster again:

```shell
helm install -f .helm/values.yaml dummy-app .helm -n test-percona
```

The pods list is as follows:
```shell
$ kubect get pods -n test-percona
NAME                                              READY   STATUS              RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
dummy-app-cluster-haproxy-0                       1/2     Running             0          32s   172.17.0.14   minikube   <none>           <none>
dummy-app-cluster-pxc-0                           0/3     Init:ErrImagePull   0          32s   172.17.0.13   minikube   <none>           <none>
percona-xtradb-cluster-operator-d65896bcb-jlrdr   1/1     Running             0          25m   172.17.0.12   minikube   <none>           <none>
```

To inspect the cluster pod we can run:
```shell
$ kubectl describe pod dummy-app-cluster-pxc-0 -n test-percona
# ...
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  66s                default-scheduler  Successfully assigned test-percona/dummy-app-cluster-pxc-0 to minikube
  Normal   Pulling    22s (x3 over 65s)  kubelet            Pulling image "percona/percona-xtradb-cluster-operator:1.7.0"
  Warning  Failed     22s (x3 over 65s)  kubelet            Failed to pull image "percona/percona-xtradb-cluster-operator:1.7.0": rpc error: code = Unknown desc = Error response from daemon: Get https://registry-1.docker.io/v2/: dial tcp: lookup registry-1.docker.io on 192.168.122.1:53: server misbehaving
  Warning  Failed     22s (x3 over 65s)  kubelet            Error: ErrImagePull
  Normal   BackOff    11s (x4 over 64s)  kubelet            Back-off pulling image "percona/percona-xtradb-cluster-operator:1.7.0"
  Warning  Failed     11s (x4 over 64s)  kubelet            Error: ImagePullBackOff
```

And of course, the haproxy fails because it can't connect to mysql:
```shell
$ kubectl describe pod dummy-app-cluster-haproxy-0 -n test-percona
# ...
Events:
  Type     Reason     Age                    From               Message
  ----     ------     ----                   ----               -------
  Normal   Scheduled  6m37s                  default-scheduler  Successfully assigned test-percona/dummy-app-cluster-haproxy-0 to minikube
  Normal   Pulled     6m35s                  kubelet            Container image "percona/percona-xtradb-cluster-operator:1.7.0-haproxy" already present on machine
  Normal   Created    6m35s                  kubelet            Created container haproxy
  Normal   Started    6m35s                  kubelet            Started container haproxy
  Normal   Pulled     6m35s                  kubelet            Container image "percona/percona-xtradb-cluster-operator:1.7.0-haproxy" already present on machine
  Normal   Created    6m35s                  kubelet            Created container pxc-monit
  Normal   Started    6m34s                  kubelet            Started container pxc-monit
  Warning  Unhealthy  4m54s (x2 over 5m25s)  kubelet            Liveness probe failed: ERROR 2013 (HY000): Lost connection to MySQL server at 'reading initial communication packet', system error: 2
  Warning  Unhealthy  91s (x55 over 6m16s)   kubelet            Readiness probe failed: ERROR 2013 (HY000): Lost connection to MySQL server at 'reading initial communication packet', system error: 2

```

Now, my question is, why is it even trying to pull the operator image, if the operator pod is already running?
