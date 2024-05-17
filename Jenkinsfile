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
         withSonarQubeEnv('mysonar') {
           sh "mvn sonar:sonar \
  -Dsonar.projectKey=myapp \
  -Dsonar.host.url=http://newdevsecops1.eastus.cloudapp.azure.com:9999 \
  -Dsonar.login=834557ed8ff507e9a1e56e392793b95a63d03a23"
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
    
    //--------------------------
        stage('Deployment Kubernetes  ') {
      steps {
        withKubeConfig([credentialsId: 'myakskubeconfig']) {
               sh "sed -i 's#replace#hrefnhaila/devops-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
               sh "kubectl apply -f k8s_deployment_service.yaml"
             }
      }

    }


    

  }
}
