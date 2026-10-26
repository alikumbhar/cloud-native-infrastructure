# DevSecOps CI/CD Pipeline

A declarative Jenkins pipeline demonstrating a production-grade DevSecOps workflow: build → scan → analyze → deploy.

## Pipeline Stages

```
Checkout → Build Docker Image → Trivy Scan → SonarQube → Deploy
```

## Jenkinsfile

```groovy
pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-token')
        SONARQUBE_SERVER = 'SonarQubeServer'
        TRIVY_VERSION = '0.54.1'
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/alikumbhar/cloud-native-infrastructure.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('demo-app:build')
                }
            }
        }
        stage('Trivy Security Scan') {
            steps {
                sh '''
                    wget -q https://github.com/aquasecurity/trivy/releases/download/v0.54.1/trivy_0.54.1_Linux-64bit.deb
                    sudo dpkg -i trivy_0.54.1_Linux-64bit.deb
                    trivy image --exit-code 1 --severity CRITICAL,HIGH demo-app:build
                '''
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'sonar-scanner -Dsonar.projectKey=demo-app'
                }
            }
            post {
                waitForQualityGate abortBuild: true
            }
        }
        stage('Deploy') {
            steps {
                sh 'echo "Deploying demo-app:build to Kubernetes via ArgoCD"'
            }
        }
    }
}
```

## What this demonstrates

- Declarative pipeline with explicit stages and environment-scoped credentials
- Shift-left security: Trivy blocks builds with CRITICAL/HIGH CVEs (exit code 1)
- SonarQube quality gate gating deployment
- Production-ready DevSecOps pattern recruiters look for