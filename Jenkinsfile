pipeline {
  agent any
 
  stages {
    
        //---------------------------------------------------
              stage('Build Artifact') {
                    steps {
                      sh "mvn clean package -DskipTests=true"
                      archive 'target/*.jar' //so that they can be downloaded later
                    }
                }
        //---------------------------------------------------
              stage('test unitaire ') {
                    steps {
                      catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                      sh "mvn test"
                      }
                    
                    }
                post{
                  always{
                    junit 'target/surefire-reports/*.xml'
                  
                  }
                }
                }
 
 
        //--------------------------
            stage('Mutation Tests - PIT') {
              steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                sh "mvn org.pitest:pitest-maven:mutationCoverage"
                }
              }
              post{
                always{
                pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
              
                }
              }
        
            }
        //--------------------------
 
       
        //--------------------------
            stage('Docker Build and Push') {
              steps {
                withCredentials([string(credentialsId: 'DOCKER_HUB_PASSWORD_PIERRE', variable: 'DOCKER_HUB_PASSWORD')]) {
                  sh 'sudo docker login -u pierrot2804 -p $DOCKER_HUB_PASSWORD'
                  sh 'printenv'
                  sh 'sudo docker build -t pierrot2804/devops-app:""$GIT_COMMIT"" .'
                  sh 'sudo docker push pierrot2804/devops-app:""$GIT_COMMIT""'
                }
        
              }
            }
        //---------------------------------------------------
            stage('Deployment Kubernetes  ') {
              steps {
                withKubeConfig([credentialsId: 'kubeconfigachraf']) {
                      sh "sed -i 's#replace#pierrot2804/devops-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                      sh "kubectl apply -f k8s_deployment_service.yaml"
                    }
              }
        
            }
 
 
 
    }
}
 
 