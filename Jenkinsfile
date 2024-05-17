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
  -Dsonar.host.url=http://devsecopsm2i.eastus.cloudapp.azure.com:9999"
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


    //----------------------------------------
stage('Vulnerability Scan owasp - dependency-check') {
   steps {
	    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
     		sh "mvn dependency-check:check"
	    }
		}
 
	       post { 
         always { 
          dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
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

	  //------------------------------------
	      stage('Vulnerability Scan - Kubernetes') {
      steps {
        parallel(
          "OPA Scan": {
            sh 'sudo docker run --rm -v $(pwd):/home/devsecops/formation-devsecops-tp/ openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
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


