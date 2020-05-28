# ДЗ: Сетевое взаимодействие Pod, сервисы
## Задание со ⭐ | DNS через MetalLB

I've create a file **coredns-lb.yaml**

This creates 2 services coredns-lb-udp and coredns-lb-tcp. Each expose UDP and TCP ports. To use the same IP in MetalLB I've used:
```yaml
  annotations:
    metallb.universe.tf/allow-shared-ip: coredns-lb
```
This is the content of   **coredns-lb.yaml**
```yaml
apiVersion: v1
kind: Service
metadata:
  namespace: kube-system
  labels:
    k8s-app: kube-dns-lb-udp
  name: coredns-lb-udp
  annotations:
    metallb.universe.tf/allow-shared-ip: coredns-lb
spec:
  type: LoadBalancer
  ports:
  - name: port-2
    port: 53
    protocol: UDP
    targetPort: 53
  selector:
    k8s-app: kube-dns
---
apiVersion: v1
kind: Service
metadata:
  namespace: kube-system
  labels:
    k8s-app: kube-dns-lb-tcp
  name: coredns-lb-tcp
  annotations:
    metallb.universe.tf/allow-shared-ip: coredns-lb
spec:
  type: LoadBalancer
  ports:
  - name: port-1
    port: 53
    protocol: TCP
    targetPort: 53
  selector:
    k8s-app: kube-dns
```
To test it you can do 
```bash
nslookup web-svc-cip.default.svc.cluster.local < external IP of the service >
```

## Задания со ⭐ | Ingress для Dashboard
I've created a file **dashboard-ingress.yaml** with the following content:
```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: dashboard
  namespace: kubernetes-dashboard
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  rules:
  - http:
      paths:
      - path: /dashboard(/|$)(.*)
        backend:
          serviceName: kubernetes-dashboard
          servicePort: 443
```

I had 2 issues:

 1. Dashboard  service runs over HTTPS and my ingress is HTTP
 2. Dashboard has to run under /dashboard path and all the resources (HTML,CSS,JS) need to have rewrite rule for /dashboard

To resolve first issue I did the following annotation:
```yaml
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
 ```
To resolve the second issue I did the following annotation:
```yaml
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
```
and in path I had to do : /dashboard(/|$)(.*)

to test it you have to browse the IP of the ingress with /dashboard/

## Задания со ⭐ | Canary для Ingress

I've created 2 file pod1 and pod2 - this (not intuitively) creates service and deployment.
pod1 creates service that respond with "server one":

```                                                              
  ______ ______________  __ ___________    ____   ____   ____  
 /  ___// __ \_  __ \  \/ // __ \_  __ \  /  _ \ /    \_/ __ \ 
 \___ \\  ___/|  | \/\   /\  ___/|  | \/ (  <_> )   |  \  ___/ 
/____  >\___  >__|    \_/  \___  >__|     \____/|___|  /\___  >
-                                           
``` 
pod2 create service that respond with "server two":
```
                                           __                 
  ______ ______________  __ ___________  _/  |___  _  ______  
 /  ___// __ \_  __ \  \/ // __ \_  __ \ \   __\ \/ \/ /  _ \ 
 \___ \\  ___/|  | \/\   /\  ___/|  | \/  |  |  \     (  <_> )
/____  >\___  >__|    \_/  \___  >__|     |__|   \/\_/ \____/ 
```
In addition I've created 2 ingress files **ingress.yaml** and **ingress-can.yaml**
Both ingress listen for Host my-app.com and path /web
** For some reason with Host and only with Path I couldn't make it work **

I've add the following annotations for canary deployment support
```yaml
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-header: "canary"
    nginx.ingress.kubernetes.io/canary-by-header-value: "true"
```

In order to test you can do the following:
```bash
curl http://172.17.255.3/web -H "Host: my-app.com" -H "canary: true"
curl http://172.17.255.3/web -H "Host: my-app.com"
```
replace 172.17.255.3 to the IP of the external IP of the ingress-nginx service.