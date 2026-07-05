pipeline {
    agent any

    environment {
        IMAGE_NAME           = "saireddy07/calculator-app"
        DOCKER_CREDENTIALS   = "docker-hub-credentials-id"

        GITOPS_REPO          = "https://github.com/sair05/k8-cicd-monitering.git"
        GIT_CREDENTIALS      = "github-credentials-id"

        SONARQUBE_SERVER     = "SonarQube-Server"
    }

    stages {

        stage('Checkout Source Code') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                python3 -m venv venv
                . venv/bin/activate

                pip install --upgrade pip
                pip install -r requirements.txt
                '''
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh '''
                . venv/bin/activate

                mkdir -p test-reports

                pytest test_app.py --junitxml=test-reports/results.xml
                '''
            }
        }

        stage('Publish Test Results') {
            steps {
                junit 'test-reports/results.xml'
            }
        }

        stage('SonarQube Scan') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'

                    withSonarQubeEnv("${SONARQUBE_SERVER}") {
                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=calculator-app \
                        -Dsonar.projectName=calculator-app \
                        -Dsonar.sources=. \
                        -Dsonar.python.version=3
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS}") {
                        def myImage = docker.build("${IMAGE_NAME}:${env.BUILD_NUMBER}", "-f Dockerfile .")
                        
                        myImage.push()
                        myImage.push('latest')
                    }
                }
            }
        }

        stage('Update GitOps Repository') {
    steps {
        dir('gitops') {
            git credentialsId: 'github-credentials-id', url: 'https://github.com/sair05/k8-cicd-monitering.git'
            
            sh "sed -i 's|image:[[:space:]]*saireddy07/calculator-app:[a-zA-Z0-9._-]*|image: saireddy07/calculator-app:${BUILD_NUMBER}|g' deployment.yml"
            
            sh 'git config user.name "sair05"'
            sh 'git config user.email "saireddysm123@gmail.com"'
            sh 'git add deployment.yml'
            
            // Commit if there are changes
            sh '''
            if ! git diff --cached --quiet; then
                git commit -m "Update calculator image to ${BUILD_NUMBER}"
            fi
            '''
            
            // Add the backslashes (\$) to GIT_USER and GIT_TOKEN here:
            withCredentials([usernamePassword(
                credentialsId: 'github-credentials-id', 
                usernameVariable: 'GIT_USER', 
                passwordVariable: 'github-credentials-id'
            )]) {
                sh """
                if ! git diff origin/main..HEAD --quiet; then
                    git push https://\${GIT_USER}:\${GIT_TOKEN}@github.com/sair05/k8-cicd-monitering.git main
                else
                    echo "Nothing to push."
                fi
                """
            }
        }
    }
}

    post {

        success {
            echo "CI Pipeline completed successfully."
        }

        failure {
            echo "CI Pipeline failed."
        }

        always {
            cleanWs()
        }
    }
}