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
                    // Pull down your GitOps repo using stored keys
                    git(
                        branch: 'main',
                        credentialsId: "${GIT_CREDENTIALS}",
                        url: "${GITOPS_REPO}"
                    )

                    sh """
                    # Safe regex replacement that updates the target tag matching your deployment file
                    sed -i 's|image:[[:space:]]*${IMAGE_NAME}:[a-zA-Z0-9._-]*|image: ${IMAGE_NAME}:${BUILD_NUMBER}|g' deployment.yml

                    git config user.name "sair05"
                    git config user.email "saireddysm123@gmail.com"

                    git add deployment.yml

                    if git diff --cached --quiet; then
                        echo "No changes to commit."
                    else
                        git commit -m "Update calculator image to ${BUILD_NUMBER}"
                    fi
                    """

                    // Securely push changes using inline environment variables from Jenkins store
                    withCredentials([usernamePassword(
                        credentialsId: "${GIT_CREDENTIALS}", 
                        usernameVariable: 'GIT_USER', 
                        passwordVariable: 'GIT_TOKEN'
                    )]) {
                        sh """
                        if ! git diff origin/main..HEAD --quiet; then
                            git push https://${GIT_USER}:${GIT_TOKEN}@github.com/sair05/k8-cicd-monitering.git main
                        else
                            echo "Nothing to push."
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