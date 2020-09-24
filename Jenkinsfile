pipeline{
    agent any

    environment {
      AWS_DEFAULT_REGION = 'us-east-1'
    }
    
    stages{
        stage("Build"){
            steps{
                withAWSParameterStore(
                        credentialsId: 'aws_creds',
                        naming: 'basename',
                        path: "/${env.BRANCH_NAME}",
                        regionName: "${env.AWS_DEFAULT_REGION}"
                    ){
                        sh """
                        docker build -t ${params.ECR_URL}/${params.IMAGE_NAME} .
                        """
                    }
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
                    withAWSParameterStore(
                        credentialsId: 'aws_creds',
                        naming: 'basename',
                        path: "/${env.BRANCH_NAME}",
                        regionName: "${env.AWS_DEFAULT_REGION}"
                    ){
                        sh """
                        aws ecr get-login-password | docker login --username AWS --password-stdin \
                        ${env.ECR_URL}
                        
                        docker push ${params.ECR_URL}/${params.IMAGE_NAME}

                        aws ecs update-service --cluster ${params.CLUSTER_NAME} --service ${params.ECS_SERVICE_NAME} \
                        --force-new-deployment 
                        """
                    }
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