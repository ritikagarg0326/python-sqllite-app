pipeline {

    agent any

    environment {

        // AWS + ECR
        AWS_REGION = "us-east-1"
        ECR_REPO = "flask-app"
        EKS_CLUSTER = "my-eks-cluster"

        AWS_ACCOUNT_ID = credentials('aws-account-id')

        IMAGE = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${BUILD_NUMBER}"

        // Terraform
        TF_IN_AUTOMATION = "true"
    }

    stages {

        ////////////////////////////////////////////////////////
        // 1️⃣ Checkout
        ////////////////////////////////////////////////////////

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        ////////////////////////////////////////////////////////
        // 2️⃣ Configure AWS Credentials
        ////////////////////////////////////////////////////////

        stage('Configure AWS') {

            steps {

                withCredentials([

                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')

                ]) {

                    sh '''

                    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID

                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY

                    aws configure set default.region $AWS_REGION

                    '''
                }
            }
        }

        ////////////////////////////////////////////////////////
        // 3️⃣ Terraform Infrastructure
        ////////////////////////////////////////////////////////

        stage('Terraform Init') {

            steps {

                dir('terraform') {

                    sh '''
                    terraform init
                    '''
                }
            }
        }

        stage('Terraform Format Check') {

            steps {

                dir('terraform') {

                    sh '''
                    terraform fmt -check
                    '''
                }
            }
        }

        stage('Terraform Validate') {

            steps {

                dir('terraform') {

                    sh '''
                    terraform validate
                    '''
                }
            }
        }

        stage('Terraform Plan') {

            steps {

                dir('terraform') {

                    sh '''
                    terraform plan
                    '''
                }
            }
        }

        stage('Terraform Apply') {

            steps {

                dir('terraform') {

                    sh '''
                    terraform apply -auto-approve
                    '''
                }
            }
        }

        ////////////////////////////////////////////////////////
        // 4️⃣ Login to ECR
        ////////////////////////////////////////////////////////

        stage('Login to ECR') {

            steps {

                sh '''

                aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS --password-stdin \
                ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

                '''
            }
        }

        ////////////////////////////////////////////////////////
        // 5️⃣ Build Docker Image
        ////////////////////////////////////////////////////////

        stage('Build Docker Image') {

            steps {

                sh '''

                docker build -t $IMAGE .

                '''
            }
        }

        ////////////////////////////////////////////////////////
        // 6️⃣ Trivy Security Scan
        ////////////////////////////////////////////////////////

        stage('Security Scan') {

            steps {

                sh '''

                trivy image $IMAGE

                '''
            }
        }

        ////////////////////////////////////////////////////////
        // 7️⃣ Push Docker Image
        ////////////////////////////////////////////////////////

        stage('Push Docker Image') {

            steps {

                sh '''

                docker push $IMAGE

                '''
            }
        }

        ////////////////////////////////////////////////////////
        // 8️⃣ Run Docker Container Test
        ////////////////////////////////////////////////////////

        stage('Run Container Test') {

            steps {

                sh '''

                docker run -d \
                -p 5050:5050 \
                --name flask-test-container \
                $IMAGE

                sleep 15

                '''
            }
        }

        ////////////////////////////////////////////////////////
        // 9️⃣ Health Check
        ////////////////////////////////////////////////////////

        stage('Health Check') {

            steps {

                sh '''

                curl http://localhost:5050

                '''
            }
        }

        ////////////////////////////////////////////////////////
        // 🔟 Configure kubectl
        ////////////////////////////////////////////////////////

        stage('Update kubeconfig') {

            steps {

                sh '''

                aws eks update-kubeconfig \
                --region $AWS_REGION \
                --name $EKS_CLUSTER

                '''
            }
        }

        ////////////////////////////////////////////////////////
        // 1️⃣1️⃣ Create Kubernetes Secret
        ////////////////////////////////////////////////////////

        stage('Create DB Secret') {

            steps {

                withCredentials([

                    string(credentialsId: 'db-host', variable: 'DB_HOST'),
                    string(credentialsId: 'db-user', variable: 'DB_USER'),
                    string(credentialsId: 'db-pass', variable: 'DB_PASS')

                ]) {

                    sh '''

                    kubectl create secret generic db-secret \
                    --from-literal=DB_HOST=$DB_HOST \
                    --from-literal=DB_USER=$DB_USER \
                    --from-literal=DB_PASS=$DB_PASS \
                    --dry-run=client -o yaml | kubectl apply -f -

                    '''
                }
            }
        }

        ////////////////////////////////////////////////////////
        // 1️⃣2️⃣ Deploy Application using Helm
        ////////////////////////////////////////////////////////

        stage('Helm Deploy') {

            steps {

                sh '''

                helm upgrade --install flask-app ./helm-chart \
                --set image.repository=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO} \
                --set image.tag=${BUILD_NUMBER}

                '''
            }
        }

        ////////////////////////////////////////////////////////
        // 1️⃣3️⃣ Verify Kubernetes Resources
        ////////////////////////////////////////////////////////

        stage('Verify Deployment') {

            steps {

                sh '''

                kubectl get nodes

                kubectl get pods

                kubectl get svc

                kubectl get ingress

                '''
            }
        }

        ////////////////////////////////////////////////////////
        // 1️⃣4️⃣ Rollout Status
        ////////////////////////////////////////////////////////

        stage('Check Rollout Status') {

            steps {

                sh '''

                kubectl rollout status deployment/flask-app

                '''
            }
        }
    }

    ////////////////////////////////////////////////////////
    // Cleanup
    ////////////////////////////////////////////////////////

    post {

        always {

            sh '''

            docker stop flask-test-container || true

            docker rm flask-test-container || true

            '''
        }

        success {

            echo 'Pipeline completed successfully 🚀'

        }

        failure {

            echo 'Pipeline failed ❌'

        }
    }
}