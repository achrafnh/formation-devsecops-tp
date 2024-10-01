pipeline {
  agent any

  stages {
//--------------------------

    stage('Build Artifact') {
      steps {
        sh 'mvn clean package -DskipTests=true'
        archive 'target/*.jar'
      }
    }

    //--------------------------
    stage('UNIT test & jacoco ') {
      steps {
        sh 'mvn test'
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
          sh 'mvn org.pitest:pitest-maven:mutationCoverage'
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
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          sh "mvn sonar:sonar \
  -Dsonar.projectKey=newprojectachraf \
  -Dsonar.host.url=http://devsecopstp1.eastus.cloudapp.azure.com:9999 \
  -Dsonar.login=d3cb3232e80fa382cd5c8418c7800d2bb2e2d748"
        }
      }
    }

//--------------------------

    stage('Vulnerability Scan owasp - dependency-check') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          sh 'mvn dependency-check:check'
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
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          withCredentials([string(credentialsId: 'DOCKER_HUB_PASSWORD_ACHRAF', variable: 'DOCKER_HUB_PASSWORD')]) {
            sh 'sudo docker login -u hrefnhaila -p $DOCKER_HUB_PASSWORD'
            sh 'printenv'
            sh 'sudo docker build -t hrefnhaila/devops-app:""$GIT_COMMIT"" .'
            sh 'sudo docker push hrefnhaila/devops-app:""$GIT_COMMIT""'
          }
      }}
      }

    //--------------------------
    stage('Deployment Kubernetes  ') {
      steps {
        withKubeConfig([credentialsId: 'kubeconfigachraf']) {
              sh "sed -i 's#replace#hrefnhaila/devops-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
              sh 'kubectl apply -f k8s_deployment_service.yaml'
        }
      }
    }

    }//-------fin stages-------------------
  } //----------fin pipeline----------------
