pipeline {

    agent any

    environment {
        AWS_REGION = "us-east-1"
        ECR_REPO = "flask-app"
        CLUSTER = "my-eks-cluster"
        IMAGE = "xxxxxxxx.dkr.ecr.us-east-1.amazonaws.com/flask-app:${BUILD_NUMBER}"
    }

    options {
        timestamps()
        timeout(time: 45, unit: 'MINUTES')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform') {
            steps {
                dir('terraform') {
                    sh '''
                    terraform init
                    terraform validate
                    terraform plan
                    terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t $IMAGE ."
            }
        }

        stage('Trivy Scan') {
            steps {
                sh '''
                trivy image \
                --severity HIGH,CRITICAL \
                --exit-code 1 \
                $IMAGE
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS --password-stdin xxxxxxxx.dkr.ecr.$AWS_REGION.amazonaws.com

                docker push $IMAGE
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                aws eks update-kubeconfig \
                --region $AWS_REGION \
                --name $CLUSTER

                helm upgrade --install flask-app ./helm-chart \
                --set image.repository=xxxxxxxx.dkr.ecr.$AWS_REGION.amazonaws.com/flask-app \
                --set image.tag=$BUILD_NUMBER
                '''
            }
        }

        stage('Verify') {
            steps {
                sh '''
                kubectl rollout status deployment/flask-app
                kubectl get pods
                kubectl get svc
                '''
            }
        }
    }

    post {

        success {
            echo "Deployment Successful 🚀"
        }

        failure {
            sh "kubectl rollout undo deployment/flask-app || true"
            echo "Deployment Failed ❌"
        }

        always {
            sh '''
            docker image prune -af || true
            '''
            cleanWs()
        }
    }
}