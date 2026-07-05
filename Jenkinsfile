pipeline {
    agent any
    
    environment {
        DOCKER_HUB_REGISTRY = 'saireddy07/calculator'
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials-id' // ID of credentials stored in Jenkins
        GIT_MANIFEST_REPO = 'github.com/sair05/k8s-cicd-repo.git'
        GIT_CREDENTIALS_ID = 'github-credentials-id'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }
        
        stage('Unit Test') {
            steps {
                sh 'pytest test_app.py --junitxml=test-reports/results.xml'
            }
        }
        
        stage('SonarQube Quality Scan') {
            steps {
                // Ensure SonarQube Server is configured in Jenkins System Settings
                withSonarQubeEnv('SonarQube-Server') {
                    sh 'sonar-scanner -Dsonar.projectKey=calculator-app -Dsonar.sources=.'
                }
            }
        }
        
        stage('Build & Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', DOCKER_CREDENTIALS_ID) {
                        def customImage = docker.build("${DOCKER_HUB_REGISTRY}:${BUILD_NUMBER}")
                        customImage.push()
                        customImage.push('latest')
                    }
                }
            }
        }
        
        stage('Update Git Manifest (ArgoCD Trigger)') {
            steps {
                script {
                    // Clone the separate Git repository holding your Kubernetes manifests
                    dir('manifest-repo') {
                        git url: "https://${GIT_MANIFEST_REPO}", credentialsId: GIT_CREDENTIALS_ID, branch: 'main'
                        
                        // Update the deployment yaml file with the new build tag
                        sh """
                            sed -i 's|image: ${DOCKER_HUB_REGISTRY}:.*|image: ${DOCKER_HUB_REGISTRY}:${BUILD_NUMBER}|g' deployment.yaml
                            git config user.email "jenkins@ci.com"
                            git config user.name "Jenkins CI"
                            git add deployment.yaml
                            git commit -m "Automated image tag update to build ${BUILD_NUMBER} [skip ci]"
                            git push origin main
                        """
                    }
                }
            }
        }
    }
}