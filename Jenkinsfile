pipeline {
  agent any

  environment {
    MAVEN_OPTS = '-Dmaven.test.failure.ignore=false'
  }

  stages {
    stage('Build Artifact') {
      steps {
        sh 'mvn clean package -DskipTests=true'
        archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
      }
    }

    stage('Test Unitaire') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          sh 'mvn test'
        }
      }
      post {
        always {
          junit 'target/surefire-reports/*.xml'
        }
      }
    }

    stage('Mutation Tests - PIT') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          sh 'mvn org.pitest:pitest-maven:mutationCoverage'
        }
      }
      post {
        always {
          archiveArtifacts artifacts: '**/target/pit-reports/**/*.*', allowEmptyArchive: true
        }
      }
    }

    stage('Vulnerability Scan - OWASP') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          sh 'mvn dependency-check:check'
        }
      }
      post {
        always {
          archiveArtifacts artifacts: 'target/dependency-check-report.*', allowEmptyArchive: true
          publishHTML(target: [
            reportName: 'Dependency Check',
            reportDir: 'target',
            reportFiles: 'dependency-check-report.html',
            keepAll: true,
            alwaysLinkToLastBuild: true
          ])
        }
      }
    }

    stage('Docker Build and Push') {
      steps {
        withCredentials([string(credentialsId: 'DOCKER_HUB_PASSWORD_PIERRE', variable: 'DOCKER_HUB_PASSWORD')]) {
          sh 'docker login -u pierrot2804 -p $DOCKER_HUB_PASSWORD'
          sh 'docker build -t pierrot2804/devops-app:$GIT_COMMIT .'
          sh 'docker push pierrot2804/devops-app:$GIT_COMMIT'
        }
      }
    }

    stage('Deployment Kubernetes') {
      steps {
        withKubeConfig([credentialsId: 'kubeconfigachraf']) {
          sh "sed -i 's#replace#pierrot2804/devops-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
          sh 'kubectl apply -f k8s_deployment_service.yaml'
        }
      }
    }
  }

  post {
    always {
      echo 'Pipeline completed.'
    }
  }
}