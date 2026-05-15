pipeline {

    agent any

    environment {
        AWS_REGION = "us-east-1"
        ECR_REPO = "flask-app"
        AWS_ACCOUNT_ID = credentials('aws-account-id')

        IMAGE = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:latest"
    }

    stages {

        // 1️⃣ Checkout
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        // 2️⃣ Configure AWS + Login ECR
        stage('Login to ECR') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {

                    sh '''
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                    aws configure set default.region $AWS_REGION

                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin \
                    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    '''
                }
            }
        }

        // 3️⃣ Build Docker Image
        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $IMAGE .
                '''
            }
        }

        // 4️⃣ Push Docker Image
        stage('Push Docker Image') {
            steps {
                sh '''
                docker push $IMAGE
                '''
            }
        }

        // 5️⃣ Run Container Test
        stage('Run Container') {
            steps {
                sh '''
                docker run -d -p 5050:5050 --name test-container $IMAGE

                sleep 10
                '''
            }
        }

        // 6️⃣ Health Check
        stage('Test Endpoint') {
            steps {
                sh '''
                curl http://localhost:5050
                '''
            }
        }
    }

    // 7️⃣ Cleanup
    post {
        always {
            sh '''
            docker stop test-container || true
            docker rm test-container || true
            '''
        }
    }
}