pipeline{
    agent any

    environment {
      IMAGE_NAME = 'tiab-tech-conduit'
      ECR_URL = '199495248340.dkr.ecr.us-east-1.amazonaws.com'
      CLUSTER_NAME = 'tiab-tech'
      ECS_SERVICE_NAME = 'conduit'
      AWS_DEFAULT_REGION = 'us-east-1'
    }
    
    stages{
        stage("Build"){
            steps{
                sh """
                docker build -t ${env.ECR_URL}/${env.IMAGE_NAME} .
                """
            }
        }
        stage("Deploy"){
            agent {
                label 'secondary-node'
            }          
            steps{
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                    credentialsId: 'aws_creds', 
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                        sh """
                        env 
                        aws ecr get-login-password | docker login --username AWS --password-stdin \
                        ${env.ECR_URL}
                        
                        docker push ${env.ECR_URL}/${env.IMAGE_NAME}

                        aws ecs update-service --cluster ${env.CLUSTER_NAME} --service ${env.ECS_SERVICE_NAME} \
                        --force-new-deployment 
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