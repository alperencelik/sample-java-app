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
            image: alperencelik/ansible-deploy:latest 
            command: ['bash', '-c', 'sleep 999999']
            env:
            - name: github_token
              valueFrom:
                secretKeyRef:
                  name: github-token
                  key: token
      """
    }
  }
  stages {
    stage('Build and Push Docker Image') {
      steps {
        container('ansible-deploy') {
            sh '''
            echo $github_token
            apt update -y && apt install -y git
            git config --global user.email "alperencelik58@gmail.com"
            git config --global user.name "alperencelik"
            git clone https://github.com/alperencelik/sample-java-app-challenge.git
            cd deploy-playbook
            ansible-playbook deploy.yaml --extra-vars "COMMIT_SHA=$GIT_COMMIT GITHUB_TOKEN=$github_token"
          '''
        
        }
      }
    }
  }
}