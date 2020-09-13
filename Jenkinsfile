pipeline{
    agent any
    environment {
      ECR_URL = '199495248340.dkr.ecr.us-east-1.amazonaws.com/tiab-tech-conduit'
      ECS_UPD = 'aws ecs update-service --cluster tiab-tech --service conduit --force-new-deployment --region us-east-1'
      CLUSTER_NAME = 'tiab-tech'
      ECS_SERVICE_NAME = 'conduit'
      AWS_DEFAULT_REGION = 'us-east-1'
    }
    stages{
        stage("Build"){
            steps{
                sh """
                docker build -t ${ECR_URL} .
                """
            }
        }
        stage("Deploy"){
            agent {
                label 'seconday-node'
            }          
            steps{
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                    credentialsId: 'aws_creds', 
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                        sh """
                        aws ecr get-login-password | docker login --username AWS --password-stdin \
                        199495248340.dkr.ecr.us-east-1.amazonaws.com
                        
                        docker push ${ECR_URL}

                        aws ecs update-service --cluster ${CLUSTER_NAME} --service #{ECS_SERVICE_NAME} --force-new-deployment 
                        """
                    }
            }
        }
    }
    post{
        always{
            cleanWs()
        }
    }
}