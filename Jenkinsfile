pipeline {
    agent any

    environment {
        IMAGE_NAME         = "saireddy07/calculator-app"
        DOCKER_CREDENTIALS = "docker-hub-credentials-id"

        GITOPS_REPO        = "https://github.com/sair05/k8-cicd-monitering.git"
        GIT_CREDENTIALS    = "github-credentials-id"

        SONARQUBE_SERVER   = "SonarQube-Server"
    }

    triggers {
        pollSCM('H/1 * * * *')
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

        stage('Build Docker Image') {
            steps {
                script {
                    app = docker.build("${IMAGE_NAME}:${BUILD_NUMBER}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {

                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS) {

                        app.push("${BUILD_NUMBER}")
                        app.push("latest")

                    }

                }
            }
        }

        stage('Update GitOps Repository') {
            steps {
                dir('gitops') {
                    git(
                        url: GITOPS_REPO,
                        branch: 'main',
                        credentialsId: GIT_CREDENTIALS
                    )

                    // Bind your username/password credential to environment variables
                    withCredentials([usernamePassword(credentialsId: GIT_CREDENTIALS, passwordVariable: 'GIT_PASS', usernameVariable: 'GIT_USER')]) {
                        sh """
                            sed -i 's|replaceImageTag|${BUILD_NUMBER}|g' deployment.yml

                            git config user.name "sair05"
                            git config user.email "saireddysm123@gmail.com"

                            git add deployment.yml

                            if git diff --cached --quiet
                            then
                                echo "No changes detected."
                            else
                                git commit -m "Update calculator image to ${BUILD_NUMBER} [skip ci]"
                                # Dynamically inject user and token/password into the URL
                                git push https://\${GIT_USER}:\${GIT_PASS}@github.com/sair05/k8-cicd-monitering.git main
                            fi
                        """
                    }
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