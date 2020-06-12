# ДЗ: Volumes, Storages, StatefulSet
## Задание со *

I've created a file **secret.yaml** with the following content:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: creds
type: Opaque
data:
  username: bWluaW8K
  password: bWluaW8xMjMK
```

username and password is minio and minio123 after base64 decoding

Then I've changed environment variables in the **minio-statefulset.yaml** file
to the following:
```yaml
        env:
        - name: MINIO_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              name: creds
              key: username
        - name: MINIO_SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: creds
              key: password
```
How to test it:
```bash
kubectl exec -it minio-0 sh
env | grep 'KEY'
```