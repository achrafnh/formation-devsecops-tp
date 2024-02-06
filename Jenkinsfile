pipeline {
  agent any
  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }  
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
    stage('Mutation Tests - PIT') {
  	steps {
    	sh "mvn org.pitest:pitest-maven:mutationCoverage"
  	}
    	post {
     	always {
       	pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
     	}
   	}
	}
     stage('Vulnerability Scan - Docker Trivy') {
   	steps {
        	withCredentials([string(credentialsId: 'trivy_adam', variable: 'TOKEN')]) {catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') 
{sh "sed -i 's#token_github#${TOKEN}#g' trivy-image-scan.sh" 
 sh "sudo bash trivy-image-scan.sh" 
}
    
    }
}
     }
	  }
	}
