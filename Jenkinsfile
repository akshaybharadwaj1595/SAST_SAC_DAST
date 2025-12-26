pipeline {
  agent any
  tools {
    maven 'Maven_3_8_7'
  }

  stages {
    stage('CompileandRunSonarAnalysis') {
      steps {
        withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
          bat("mvn -Dmaven.test.failure.ignore verify sonar:sonar -Dsonar.token=%SONAR_TOKEN% -Dsonar.projectKey=easybuggy1 -Dsonar.host.url=http://localhost:9000/")
        }
      }
    }

    stage('Build') {
      steps {
        withDockerRegistry([credentialsId: "dockerlogin", url: ""]) {
          script {
            app = docker.build("asecurityguru/testeb")
          }
        }
      }
    }

    stage('RunContainerScan') {
      steps {
        withCredentials([string(credentialsId: 'SNYK_TOKEN', variable: 'SNYK_TOKEN')]) {
          script {
            try {
              bat("C:\\snyk\\snyk-win.exe container test asecurityguru/testeb")
            } catch (err) {
              echo err.getMessage()
            }
          }
        }
      }
    }

    stage('RunSnykSCA') {
      steps {
        withCredentials([string(credentialsId: 'SNYK_TOKEN', variable: 'SNYK_TOKEN')]) {
          bat("mvn snyk:test -fn")
        }
      }
    }

    stage('RunDASTUsingZAP') {
      steps {
        bat """
          if not exist "%WORKSPACE%\\ZAP_Reports" mkdir "%WORKSPACE%\\ZAP_Reports"
          """
        bat """
          java -Xmx512m -jar "C:\\zap\\ZAP_2.12.0_Crossplatform\\ZAP_2.12.0\\zap-2.12.0.jar" ^
          -port 9393 ^
          -cmd ^
          -quickurl https://www.example.com ^
          -quickprogress ^
          -quickout "%WORKSPACE%\\ZAP_Reports\\ZAP_Output.html"
          """
      }
    }

    stage('ArchiveZAPReport') {
      steps {
        archiveArtifacts artifacts: 'ZAP_Reports\\ZAP_Output.html', fingerprint: true
      }
    }

    stage('checkov') {
      steps {
        bat("checkov -s -f main.tf")
      }
    }
  }
}
