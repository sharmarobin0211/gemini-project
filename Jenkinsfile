pipeline{
    agent any

    environment{
        
        GIT_REPO = "https://github.com/sharmarobin0211/dev-gemini-clone.git"
        GIT_BRANCH = "DevOps"
        DOCKER_TAG = "${BUILD_NUMBER}"
    }

    stages{
        stage("Clean Workspace"){
            steps{
            
                cleanWs()
            
          }
        }
        stage("code clone"){
            steps {
                
                    git url:"${GIT_REPO}" , branch: "${GIT_BRANCH}"
                
            }
        }
         stage("Prepare Environment File") {
            steps {
               withCredentials([file(credentialsId: ".env.local", variable: 'ENV_FILE')]) {
                sh "cp -f $ENV_FILE .env.local"
                echo " .env.local file has been copied into the workspace."
               }
            }
    c
        stage("Build"){
            steps{
                
                    sh " docker build -t gemini:${DOCKER_TAG} . "
                
            }
        } 
        stage("security check"){
            parallel {
                stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=gemini\
                    -Dsonar.projectKey=gemini '''
                }
            }
        }
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
                }
            }
        }
       
        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
            }
        }
        
        stage("docker push"){
            steps{
                script{
                   withCredentials([usernamePassword(credentialsId:"cred",
                                    usernameVariable:"dockerHubUser",
                                    passwordVariable:"dockerHubPass")]){
                    sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPass}"
                    sh "docker image tag gemini:${DOCKER_TAG} ${env.dockerHubUser}/gemini:${DOCKER_TAG}"
                    sh "docker push ${env.dockerHubUser}/gemini:${DOCKER_TAG}"
          }
                }
            }
        }
    }

}
