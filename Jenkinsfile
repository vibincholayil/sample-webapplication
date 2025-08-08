// helper functions (can be reused)
def buildDocker(imageTag) {
    echo "Building Docker image: ${imageTag}"
    sh "docker build -t ${imageTag} ."
}

def pushDocker(imageTag, credsId) {
    echo "Pushing Docker image: ${imageTag}"
    withCredentials([usernamePassword(credentialsId: credsId, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
        sh '''
           echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
           docker push ${IMAGE_TAG}
        '''.replace('${IMAGE_TAG}', imageTag)
    }
}

def deployToK8s(imageTag, namespace) {
    echo "Deploying ${imageTag} to namespace ${namespace}"
    // try to update existing deployment; if not present, apply manifest with image substitution
    script {
        sh "kubectl -n ${namespace} get deployment sample-html-app >/dev/null 2>&1 || true"
        def out = sh(returnStatus: true, script: "kubectl -n ${namespace} get deployment sample-html-app")
        if (out == 0) {
            sh "kubectl -n ${namespace} set image deployment/sample-html-app sample-html-app=${imageTag} --record"
        } else {
            // replace placeholder and apply
            sh "sed 's|REPLACE_IMAGE|${imageTag}|' k8s-deployment.yaml | kubectl -n ${namespace} apply -f -"
        }
        sh "kubectl -n ${namespace} rollout status deployment/sample-html-app --timeout=120s || true"
    }
}

pipeline {
    agent any

    parameters {
        string(name: 'K8S_NAMESPACE', defaultValue: 'default', description: 'Kubernetes namespace for deployment')
    }

    environment {
        DOCKERHUB_REPO = 'YOUR_DOCKERHUB_USERNAME/sample-html-app'
        DOCKER_CRED_ID = 'dockerhub-creds' // create this credential in Jenkins
    }

    stages {
        stage('Prepare') {
            steps {
                // compute build ID based on current date/time (safer to use shell)
                script {
                    env.BUILD_ID_CUSTOM = sh(returnStdout: true, script: "date +%Y%m%d.%H%M").trim()
                    env.IMAGE_TAG = "${env.DOCKERHUB_REPO}:${env.BUILD_ID_CUSTOM}"
                }
                echo "Custom Build ID = ${env.BUILD_ID_CUSTOM}"
                echo "Image will be: ${env.IMAGE_TAG}"
            }
        }

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/YOUR_GITHUB_USERNAME/sample-html-k8s-project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // call reusable function
                    buildDocker(env.IMAGE_TAG)
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    pushDocker(env.IMAGE_TAG, env.DOCKER_CRED_ID)
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    deployToK8s(env.IMAGE_TAG, params.K8S_NAMESPACE)
                }
            }
        }

        stage('Verify') {
            steps {
                sh "kubectl -n ${params.K8S_NAMESPACE} get pods -l app=sample-html-app -o wide"
                sh "kubectl -n ${params.K8S_NAMESPACE} get svc sample-html-service -o wide || true"
            }
        }
    }

    post {
        success {
            echo "Deployment successful. Build ID: ${env.BUILD_ID_CUSTOM}"
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
