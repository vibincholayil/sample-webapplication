pipeline {
    agent any

    parameters {
        string(name: 'K8S_NAMESPACE', defaultValue: 'default', description: 'Kubernetes namespace for deployment')
    }

    environment {
        DOCKERHUB_USER = 'YOUR_DOCKERHUB_USERNAME'
        DOCKER_CRED_ID = 'dockerhub-creds' // Jenkins credential ID for DockerHub
        BUILD_ID_CUSTOM = sh(script: "date +%Y%m%d.%H%M", returnStdout: true).trim()
        IMAGE_TAG = "${DOCKERHUB_USER}/sample-html-app:${BUILD_ID_CUSTOM}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/YOUR_GITHUB_USERNAME/sample-html-k8s-project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${IMAGE_TAG}"
                sh "docker build -t ${IMAGE_TAG} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CRED_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push ${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "Deploying to namespace: ${params.K8S_NAMESPACE}"
                sh """
                sed 's|REPLACE_IMAGE|${IMAGE_TAG}|' k8s-deployment.yaml | kubectl apply -n ${params.K8S_NAMESPACE} -f -
                kubectl rollout status deployment/sample-html-app -n ${params.K8S_NAMESPACE} --timeout=120s
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                sh "kubectl get pods -n ${params.K8S_NAMESPACE} -l app=sample-html-app"
                sh "kubectl get svc sample-html-service -n ${params.K8S_NAMESPACE}"
            }
        }
    }

    post {
        success {
            echo "✅ Deployment completed successfully with Build ID: ${BUILD_ID_CUSTOM}"
        }
        failure {
            echo "❌ Pipeline failed."
        }
    }
}

