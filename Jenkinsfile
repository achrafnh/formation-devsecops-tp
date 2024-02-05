pipeline {
  agent any

  stages {
      stage('Build 666 Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }   
    }
}
