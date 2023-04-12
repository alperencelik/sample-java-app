pipeline {
  agent {
    kubernetes {
      label 'kaniko'
      defaultContainer 'kaniko'
      yaml """
        apiVersion: v1
        kind: Pod
        metadata:
          labels:
            jenkins/kind: kaniko
        spec:
          containers:
          - name: kaniko
            image: gcr.io/kaniko-project/executor:debug
            command: ['sh', '-c', 'sleep 999999']
            volumeMounts:
            - name: dockercfg
              mountPath: /kaniko/.docker
          volumes:
          - name: dockercfg
            secret:
              secretName: dockerhub-secret
      """
    }
  }
  stages {
    stage('Build and Push Docker Image') {
      steps {
        container('kaniko') {
          sh 'sleep 20'
          sh '/kaniko/executor --dockerfile=./java-app/Dockerfile --context=git://github.com/alperencelik/sample-java-app-challenge.git --destination=alperencelik/sample-java-app:1 '
        }
      }
    }
  }
}