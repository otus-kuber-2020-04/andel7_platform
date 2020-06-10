local kube = import "https://raw.githubusercontent.com/bitnami-labs/kube-libsonnet/master/kube.libsonnet";
{
  kind: 'ReplicationController',
  apiVersion: 'v1',
  metadata: {
    name: 'spark-master-controller',
  },
  spec: {
    replicas: 1,
    selector: {
      component: 'spark-master',
    },
    template: {
      metadata: {
        labels: {
          component: 'spark-master',
        },
      },
      spec: {
        containers: [
          {
            name: 'spark-master',
            image: 'k8s.gcr.io/spark:1.5.2_v1',
            command: [
              '/start-master',
            ],
            ports: [
              {
                containerPort: 7077,
              },
              {
                containerPort: 8080,
              },
            ],
            resources: {
              requests: {
                cpu: '100m',
              },
            },
          },
        ],
      },
    },
  },
}