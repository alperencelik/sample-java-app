curl -X POST -H "Content-Type: application/json" -d '{
  "kind": "Deployment",
  "apiVersion": "apps/v1",
  "metadata": {
    "name": "test-deployment",
    "namespace": "default"
  },
  "spec": {
    "replicas": 1,
    "selector": {
      "matchLabels": {
        "app": "test"
      }
    },
    "template": {
      "metadata": {
        "labels": {
          "app": "test"
        }
      },
      "spec": {
        "containers": [
          {
            "name": "test-container",
            "image": "nginx",
          }
        ]
      }
    }
  }
}' http:/localhost:8081/validate
