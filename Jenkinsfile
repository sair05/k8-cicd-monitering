pipeline {
    agent any

    environment {
        IMAGE_NAME           = "saireddy07/calculator"
        DOCKER_CREDENTIALS   = "docker-hub-credentials-id"

        GITOPS_REPO          = "https://github.com/sair05/k8-cicd-monitering.git"
        GIT_CREDENTIALS       = "github-credentials-id"

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

                    withSonarQubeEnv('SonarQube-Server') {
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

        // stage('Build Docker Image') {
        //     steps {
        //         script {
        //             app = docker.build("${IMAGE_NAME}:${BUILD_NUMBER}")
        //         }
        //     }
        // }

        stage('Push Docker Image') {
            steps {
                script {
                    // Wrap the registry block and ensure all strings are explicitly quoted
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials-id') {
                        
                        // Note the single quotes around the entire string, except for the variable interpolation
                        def myImage = docker.build("saireddy07/calculator-app:${env.BUILD_NUMBER}", "-f Dockerfile .")
                        
                        myImage.push()
                        myImage.push('latest')
                    }
                }
            }
        }

        stage('Update GitOps Repository') {
            steps {
                dir('gitops') {
                    git(
                        branch: 'main',
                        credentialsId: GIT_CREDENTIALS,
                        url: GITOPS_REPO
                    )

                    sh """
                    # Safe regex replacement that specifically updates the tag number
                    sed -i 's|image:[[:space:]]*${IMAGE_NAME}:[a-zA-Z0-9._-]*|image: ${IMAGE_NAME}:${BUILD_NUMBER}|g' deployment.yaml

                    git config user.name "Jenkins CI"
                    git config user.email "jenkins@ci.com"

                    git add deployment.yaml

                    if git diff --cached --quiet
                    then
                        echo "No changes to commit."
                    else
                        git commit -m "Update calculator image to ${BUILD_NUMBER}"
                        git push origin main
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