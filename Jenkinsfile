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
        withKubeConfig([credentialsId: 'kubeconfig']) {
          sh "sed -i 's#replace#desbonnet/devops-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
          sh 'kubectl apply -f k8s_deployment_service.yaml'
        }
      }
    }
  }
}

