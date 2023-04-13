pipeline {
  agent {
    kubernetes {
      label 'ansible-deploy'
      defaultContainer 'ansible-deploy'
      yaml """
        apiVersion: v1
        kind: Pod
        metadata:
          labels:
            jenkins: ansible-deploy
        spec:
          containers:
          - name: ansible-deploy
            image: litmuschaos/ansible-runner 
            command: ['bash', '-c', 'sleep 999999']
      """
    }
  }
  stages {
    stage('Build and Push Docker Image') {
      steps {
        container('ansible-deploy') {
            sh '''
            apt update -y && apt install -y git
            git clone https://github.com/alperencelik/sample-java-app-challenge.git
            cd deploy-playbook
            ansible-playbook deploy.yaml
          '''
        
        }
      }
    }
  }
}