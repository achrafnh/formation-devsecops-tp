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
        
            }
        ///////////////////////

          stage('Vulnerability Scan - Docker') {
            steps {
              catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                sh "mvn dependency-check:check" 
              }
            }
            post{
              always{
               dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
                jacoco(execPattern: 'target/jacoco.exec')
              }
            }
           } 

        
        //--------------------------
            stage('Docker Build and Push') {
              steps {
                withCredentials([string(credentialsId: 'docker-hub-password', variable: 'DOCKER_HUB_PASSWORD')]) {
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
                withKubeConfig([credentialsId: 'kubeconfig']) {
                      sh "sed -i 's#replace#hrefnhaila/devops-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                      sh "kubectl apply -f k8s_deployment_service.yaml"
                    }
              }
        
            }



    }
}
