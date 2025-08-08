Sample HTML App deployed via Jenkins -> Docker -> Kubernetes.

Files:
- index.html
- Dockerfile
- k8s-deployment.yaml
- Jenkinsfile

Usage:
1. Push to GitHub.
2. Create Jenkins pipeline pointing to this repo.
3. Run pipeline, choose K8S_NAMESPACE parameter.

Access: http://<node-ip>:30080

