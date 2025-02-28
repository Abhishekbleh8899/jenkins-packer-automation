pipeline {
    agent any
    environment {
        PACKER_TEMPLATE = 'task.pkr.hcl'
        AWS_CREDENTIALS = 'credentials(aws-creds)'
    }
    stages {
        stage('checkout code'){
            steps{
                git branch: 'main',
                url: 'https://github.com/Abhishekbleh8899/jenkins-packer-automation.git'
            }
        }
        stage('install dependencies'){
            steps{
                sh '''
                sudo apt-get update
                sudo apt-get install -y packer awscli
                '''
            }
        }
        stage('validate packer template'){
            steps{
                sh 'packer init $PACKER_TEMPLATE'
                sh 'packer validate $PACKER_TEMPLATE'
            }
        }
        stage('build ami with packer'){
            steps{
                sh "packer build $PACKER_TEMPLATE"
            }
        }
    }
    
    post {
        success {
            echo 'AMI build successful'
        }
        failure {
            echo 'AMI build failed'
        }
    }
}


