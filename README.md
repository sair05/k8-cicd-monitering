# Calculator App CI/CD with Jenkins, GitHub Actions, and Kubernetes

This project demonstrates a complete DevOps pipeline for a Flask calculator application using:

- Minikube
- Jenkins
- Argo CD
- GitHub Actions
- Prometheus
- Grafana

## Project Overview

The application is containerized, deployed to a Kubernetes cluster, and monitored using Prometheus and Grafana. CI/CD is implemented using both Jenkins and GitHub Actions to automate build, test, image push, and deployment workflows.

## Tech Stack

- Python / Flask
- Docker
- Kubernetes / Minikube
- Jenkins
- Argo CD
- GitHub Actions
- Prometheus
- Grafana

## Repository Structure

- app.py: Flask application
- requirements.txt: Python dependencies
- templates/: HTML templates
- Dockerfile: Container image definition
- deployment.yml: Kubernetes deployment manifest
- Jenkinsfile: Jenkins pipeline configuration
- .github/workflows/cicd.yml: GitHub Actions workflow
- test_app.py: Unit tests

## Prerequisites

Make sure the following tools are installed and configured:

- Docker
- Minikube
- kubectl
- Jenkins
- Argo CD
- GitHub Actions runner or GitHub-hosted runners
- Prometheus and Grafana

## Local Setup

### 1. Start Minikube

```bash
minikube start
```

### 2. Build and Run the Application Locally

```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py
```

### 3. Build Docker Image

```bash
docker build -t calculator-app:latest .
```

### 4. Deploy to Kubernetes

```bash
kubectl apply -f deployment.yml
```

## Jenkins Pipeline

The Jenkins pipeline defined in Jenkinsfile performs the following steps:

1. Checkout source code
2. Install Python dependencies
3. Run unit tests
4. Build Docker image
5. Push image to Docker Hub
6. Update Kubernetes deployment manifest
7. Trigger GitOps update flow

### Jenkins Requirements

- Configure Jenkins with:
  - Docker credentials
  - GitHub credentials
  - SonarQube integration (if enabled)

## GitHub Actions Workflow

The GitHub Actions workflow in .github/workflows/cicd.yml automates:

1. Checkout repository
2. Install dependencies
3. Run tests
4. Build Docker image
5. Push image to Docker Hub
6. Deploy or update deployment configuration

## Argo CD

Argo CD can be used to continuously sync the Kubernetes manifests from Git to your cluster.

## Monitoring

Prometheus and Grafana are used for monitoring application health and metrics.

### Access Prometheus

```bash
kubectl port-forward svc/prometheus-server 9090:80 -n monitoring
```

### Access Grafana

```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

## Useful Commands

```bash
kubectl get pods
kubectl get svc
kubectl describe deployment calculator-deployment
kubectl logs <pod-name>
```

## Notes

- Update image names and repository URLs according to your Docker Hub and GitHub settings.
- Ensure your Kubernetes cluster has access to the required images and manifests.
- For production deployments, secure secrets using Kubernetes secrets or Jenkins/GitHub secret stores.

## License

This project is for learning and demonstration purposes.
