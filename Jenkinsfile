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
            stage('scan sonarqube') {
              steps {

            withCredentials([string(credentialsId: 'sonarqubetoken', variable: 'sonarqubetoken')]) {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {

  sh "sudo mvn clean verify sonar:sonar \
  -Dsonar.projectKey=devsecopsjenkins \
  -Dsonar.projectName='devsecopsjenkins' \
  -Dsonar.host.url=http://devopstssr.eastus.cloudapp.azure.com:9998 \
  -Dsonar.token=sqa_153810ae0e910e1943fe0ea9fa4478d9f643d936"


                }
              }
            }
            
        
            }

        //--------------------------

        stage('Vulnerability Scan - Docker') {
          steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              sh "mvn dependency-check:check"
            }
          }
          post {
            always {
              dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
              jacoco(execPattern: 'target/jacoco.exec')
            }
          }
        }
        //--------------------------
            stage('Docker Build and Push') {
              steps {
                withCredentials([string(credentialsId: 'DOCKER_HUB_PASSWORD_ACHRAF', variable: 'DOCKER_HUB_PASSWORD')]) {
                  sh 'sudo docker login -u hrefnhaila -p $DOCKER_HUB_PASSWORD'
                  sh 'printenv'
                  sh 'sudo docker build -t hrefnhaila/devops-app:""$GIT_COMMIT"" .'
                  sh 'sudo docker push hrefnhaila/devops-app:""$GIT_COMMIT""'
                }
        
              }
            }
        //---------------------------------------------------
            stage('Deployment Kubernetes  ') {
              steps {
                withKubeConfig([credentialsId: 'kubeconfigachraf']) {
                      sh "sed -i 's#replace#hrefnhaila/devops-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                      sh "kubectl apply -f k8s_deployment_service.yaml"
                    }
              }
        
            }



    }
}
