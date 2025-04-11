pipeline {
  agent any
 
  stages {

        //---------------------------------------------------
              stage('Build Artifact') {
                    steps {
                      sh "sudo mvn clean package -DskipTests=true"
                      archive 'target/*.jar' //so that they can be downloaded later
                    }
                }
        //---------------------------------------------------
            

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
              sh "sudo mvn dependency-check:check"
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
                 
                  sh 'sudo docker build -t hrefnhaila/devops-app:""$GIT_COMMIT"" .'
                  sh 'sudo docker push hrefnhaila/devops-app:""$GIT_COMMIT""'
                }
        
              }
            }
//-----------------------------

stage('Vulnerability Scan - Kubernetes') {
  steps {
    parallel(
      "OPA Scan": {
        sh 'sudo docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
      },
      "Kubesec Scan": {
        sh "sudo bash kubesec-scan.sh"
      },
      "Trivy Scan": {
        sh "sudo bash trivy-k8s-scan.sh"
      }
    )
  }
}



        //---------------------------------------------------
            stage('Deployment Kubernetes  ') {
              steps {
                withKubeConfig([credentialsId: 'kubeconfigachraf']) {
                      sh "sudo sed -i 's#replace#hrefnhaila/devops-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                      sh "sudo kubectl apply -f k8s_deployment_service.yaml"
                    }
              }
        
            }



    }
}
