*Setting up the Metrics Server*

The Kubernetes Metrics Server is a cluster-wide aggregator of resource usage data and is the successor of Heapster. The metrics server collects CPU and memory usage for nodes and pods by pooling data from the kubernetes.summary_api. The summary API is a memory-efficient API for passing data from Kubelet/cAdvisor to the metrics server.


Deploy the Metrics Server in the monitoring namespace:

kubectl create -f ./metrics-server

After one minute the metric-server starts reporting CPU and memory usage for nodes and pods.

View nodes metrics:

kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" | jq .

View pods metrics:

kubectl get --raw "/apis/metrics.k8s.io/v1beta1/pods" | jq .



Auto Scaling based on CPU and memory usage

We will use a small Golang-based web app to test the Horizontal Pod Autoscaler (HPA).

Deploy podinfo to the default namespace:

kubectl create -f ./podinfo/podinfo-svc.yaml,./podinfo/podinfo-dep.yaml


Next define a HPA that maintains a minimum of two replicas and scales up to ten if the CPU average is over 80% or if the memory goes over 200Mi.



Create the HPA:

kubectl create -f ./podinfo/podinfo-hpa.yaml

After a couple of seconds the HPA controller contacts the metrics server and then fetches the CPU and memory usage:

kubectl get hpa

NAME      REFERENCE            TARGETS                      MINPODS   MAXPODS   REPLICAS   AGE
podinfo   Deployment/podinfo   2826240 / 200Mi, 15% / 80%   2         10        2          5m

In order to increase the CPU usage, run a load test with rakyll/hey:

#install hey
go get -u github.com/rakyll/hey

#do 10K requests
hey -n 10000 -q 10 -c 5 http://<K8S_PUBLIC_IP>:31198/

You can monitor the HPA events with:

$ kubectl describe hpa

Events:
  Type    Reason             Age   From                       Message
  ----    ------             ----  ----                       -------
  Normal  SuccessfulRescale  7m    horizontal-pod-autoscaler  New size: 4; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  3m    horizontal-pod-autoscaler  New size: 8; reason: cpu resource utilization (percentage of request) above target





Setting up a Custom Metrics Server

In order to scale based on custom metrics you need to have two components. One component that collects metrics from your applications and stores them the Prometheus time series database. And a second component that extends the Kubernetes custom metrics API with the metrics supplied by the collect, the k8s-prometheus-adapter.

Custom-Metrics-Server

We will deploy Prometheus and the adapter in a dedicated namespace.

Create the monitoring namespace:

kubectl create -f ./namespaces.yaml

Deploy Prometheus v2 in the monitoring namespace:

kubectl create -f ./prometheus

Generate the TLS certificates needed by the Prometheus adapter:

touch metrics-ca.key metrics-ca.crt metrics-ca-config.json
make certs

Deploy the Prometheus custom metrics API adapter:

kubectl create -f ./custom-metrics-api

List the custom metrics provided by Prometheus:

kubectl get --raw "/apis/custom.metrics.k8s.io/v1" | jq .

Get the FS usage for all the pods in the monitoring namespace:

kubectl get --raw "/apis/custom.metrics.k8s.io/v1/namespaces/monitoring/pods/*/kubelet_container_log_filesystem_used_bytes" | jq .



Auto Scaling based on custom metrics

Create podinfo NodePort service and deployment in the default namespace:

kubectl create -f ./podinfo/podinfo-svc.yaml,./podinfo/podinfo-dep.yaml

The podinfo app exposes a custom metric named http_requests_total. The Prometheus adapter removes the _total suffix and marks the metric as a counter metric.

Get the total requests per second from the custom metrics API:

kubectl get --raw "/apis/custom.metrics.k8s.io/v1/namespaces/default/pods/*/http_requests" | jq .


Create a HPA that will scale up the podinfo deployment if the number of requests goes over 10 per second.

Deploy the podinfo HPA in the default namespace:

kubectl create -f ./podinfo/podinfo-hpa-custom.yaml

After a couple of seconds the HPA fetches the http_requests value from the metrics API:

kubectl get hpa

NAME      REFERENCE            TARGETS     MINPODS   MAXPODS   REPLICAS   AGE
podinfo   Deployment/podinfo   899m / 10   2         10        2          1m

Apply some load on the podinfo service with 25 requests per second:

#install hey
go get -u github.com/rakyll/hey

#do 10K requests rate limited at 25 QPS
hey -n 10000 -q 5 -c 5 http://<K8S-IP>:31198/healthz

After a few minutes the HPA begins to scale up the deployment:

kubectl describe hpa

Name:                       podinfo
Namespace:                  default
Reference:                  Deployment/podinfo
Metrics:                    ( current / target )
  "http_requests" on pods:  9059m / 10
Min replicas:               2
Max replicas:               10

Events:
  Type    Reason             Age   From                       Message
  ----    ------             ----  ----                       -------
  Normal  SuccessfulRescale  2m    horizontal-pod-autoscaler  New size: 3; reason: pods metric http_requests above target

At the current rate of requests per second the deployment will never get to the max value of 10 pods. Three replicas are enough to keep the RPS under 10 per each pod.

After the load tests finishes, the HPA down scales the deployment to it's initial replicas:

Events:
  Type    Reason             Age   From                       Message
  ----    ------             ----  ----                       -------
  Normal  SuccessfulRescale  5m    horizontal-pod-autoscaler  New size: 3; reason: pods metric http_requests above target
  Normal  SuccessfulRescale  21s   horizontal-pod-autoscaler  New size: 2; reason: All metrics below target

