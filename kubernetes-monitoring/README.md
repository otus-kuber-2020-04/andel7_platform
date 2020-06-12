
# ДЗ: Мониторинг сервиса в кластере k8s

  

I've created a file **nginx.yaml** with the following content:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: bitnami/nginx
        ports:
        - containerPort: 8080
      - name: nginx-exporter
        image: nginx/nginx-prometheus-exporter
        args: ["-nginx.scrape-uri", "http://127.0.0.1:8080/status"]
        ports:
        - containerPort: 9113
```
I've used bitnami/nginx image because it's already comes with **ngx_http_stub_status_module** so I didn't have to compile nginx.

Then I also used nginx/nginx-prometheus-exporter and provided arguments -nginx.scrape-uri", "http://127.0.0.1:8080/status" to match default configuration of bitnami nginx.

Next I did the following
```bash
kubectl -n nginx-monitoring expose deployment nginx-deployment --dry-run=client -o yaml
```
And saved it to file **service.yaml**
I install prometheus operator with helm3
```bash
helm install prom-oper stable/prometheus-operator
```

Next I've created the file **service-monitor.yaml**
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: example-app
  labels:
    release: prom-oper
spec:
  selector:
    matchLabels:
      app: nginx
  endpoints:
  - port: port-2
```
I installed prometheus operator , deployment, service and service monitor so it will be easier to handle the RBAC and the discovery of service-monitors.

It took me forever to understand why my service monitor didn't work until my friend explained me the mismatch between  ( I hope it's not considered cheating )
```yaml
  labels:
    release: prom-oper
```

which initially was **team: frontend**
but my prometheus configuration was 
```yaml
    serviceMonitorSelector:
      matchLabels:
        release: prom-oper
```

![ Grafana dashboard I've created ](https://i.ibb.co/BwMdpvx/Screen-Shot-2020-06-10-at-19-57-23.png)