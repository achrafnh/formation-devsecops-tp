pipeline {
  agent any

  stages {
      stage('Build Artifact') {
      steps {
        sh 'mvn clean package -DskipTests=true'
        archive 'target/*.jar' //so that they can be downloaded later test aa
      }
      }

  //--------------------------
    stage('UNIT test & jacoco ') {
      steps {
        sh "mvn test"
      }
      post {
        always {
          junit 'target/surefire-reports/*.xml'
          jacoco execPattern: 'target/jacoco.exec'
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
        post { 
         always { 
           pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
         }
       }
    }

//--------------------------
 
     stage('SonarQube - SAST') {
       steps {
         withSonarQubeEnv('MySonar') {
           sh "mvn sonar:sonar \
  -Dsonar.projectKey=App_Java \
  -Dsonar.host.url=http://devsecopsm2i.eastus.cloudapp.azure.com:9999 \
  -Dsonar.login=8d7823763ffa253494c99930a0b9988581cf8d53"
         }

       }
     }

    //------------------------
    
stage('Vulnerability Scan - Docker Trivy') {
       steps {
//--------------------------replace variable  token_github on file trivy-image-scan.sh
         withCredentials([string(credentialsId: 'trivy_github_token', variable: 'TOKEN')]) {
  sh "sed -i 's#token_github#${TOKEN}#g' trivy-image-scan.sh"      
  sh "sudo bash trivy-image-scan.sh"
        }
       }
     }


    
    //--------------------------
    stage('Docker Build and Push') {
      steps {
        withCredentials([string(credentialsId: 'devsecops', variable: 'DOCKER_HUB_PASSWORD')]) {
          sh 'sudo docker login -u desbonnet -p $DOCKER_HUB_PASSWORD'
          sh 'printenv'
          sh 'sudo docker build -t desbonnet/devops-app:""$GIT_COMMIT"" .'
          sh 'sudo docker push desbonnet/devops-app:""$GIT_COMMIT""'
        }
      }
    }
    //--------------------------
    stage('Deployment Kubernetes  ') {
      steps {
        withKubeConfig([credentialsId: 'myakskubeconfig']) {
          sh "sed -i 's#replace#desbonnet/devops-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
          sh 'kubectl apply -f k8s_deployment_service.yaml'
        }
      }
    }
  }
}

