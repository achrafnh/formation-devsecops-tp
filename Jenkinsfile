pipeline {
  agent any

  stages {
     
//--------------------------

    stage('Build Artifact') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archive 'target/*.jar'
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
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
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
	 stage('Vulnerability Scan - Docker Trivy') {
       steps {
	        withCredentials([string(credentialsId: 'trivy_token_achraf', variable: 'TOKEN')]) {
			 catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                 sh "sed -i 's#token_github#${TOKEN}#g' trivy-image-scan.sh"
                 sh "sudo bash trivy-image-scan.sh"
	       }
		}
       }
     }


//--------------------------

stage('Vulnerability Scan owasp - dependency-check') {
   steps {
	    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
     		sh "mvn dependency-check:check"
	    }
		}
	
 }

//--------------------------




    }
}
