@Library('slack') _

/////// ******************************* Code for fectching Failed Stage Name ******************************* ///////
import io.jenkins.blueocean.rest.impl.pipeline.PipelineNodeGraphVisitor
import io.jenkins.blueocean.rest.impl.pipeline.FlowNodeWrapper
import org.jenkinsci.plugins.workflow.support.steps.build.RunWrapper
import org.jenkinsci.plugins.workflow.actions.ErrorAction

// Get information about all stages, including the failure cases
// Returns a list of maps: [[id, failedStageName, result, errors]]
@NonCPS
List<Map> getStageResults(RunWrapper build) {
  // Get all pipeline nodes that represent stages
  def visitor = new PipelineNodeGraphVisitor(build.rawBuild)
  def stages = visitor.pipelineNodes.findAll { it.type == FlowNodeWrapper.NodeType.STAGE }

  return stages.collect { stage ->
        // Get all the errors from the stage
        def errorActions = stage.getPipelineActions(ErrorAction)
        def errors = errorActions?.collect { it.error }.unique()

        return [
            id: stage.id,
            failedStageName: stage.displayName,
            result: "${stage.status.result}",
            errors: errors
        ]
  }
}
// Get information of all failed stages not ok
@NonCPS
List<Map> getFailedStages(RunWrapper build) {
  return getStageResults(build).findAll { it.result == 'FAILURE' }
}
pipeline {
  agent any
  environment {
    SLACK_CHANNEL = 'teamDevsecops' // Slack channel to send notifications
  }
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
    stage('Vulnerability Scan - Docker Trivy') {
      steps {
            withCredentials([string(credentialsId: 'trivy_token', variable: 'TOKEN')]) {
          catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
            sh "sed -i 's#token_github#${TOKEN}#g' trivy-image-scan.sh"
            sh 'sudo bash trivy-image-scan.sh'
          }
            }
      }
    }

      stage('Vulnerability Scan - Kubernetes') {
      steps {
        parallel(
               'OPA Scan': {
                 sh 'sudo docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
               },
               'Kubesec Scan': {
                 sh 'sudo bash kubesec-scan.sh'
               },
               'Trivy Scan': {
                 sh 'sudo bash trivy-k8s-scan.sh'
               }
             )
      }
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
    //--------------------------
    stage('Zap report') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          sh 'sudo bash zap.sh'
        }
      }
    }
    //--------------------------
    }//-------fin stages-------------------

    post {
        success {
      script {
        sendNotification('SUCCESS')
      }
        }
        failure {
      script {
        sendNotification('FAILURE')
      }
        }
        unstable {
      script {
        sendNotification('UNSTABLE')
      }
        }
    }
  } //----------fin pipeline----------------
