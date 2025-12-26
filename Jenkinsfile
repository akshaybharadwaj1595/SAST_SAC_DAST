pipeline {
  agent any
  tools {
    maven 'Maven_3_8_7'
  }

  stages {

    stage('Compile and Run Sonar Analysis') {
      steps {
        withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
          bat("mvn -Dmaven.test.failure.ignore verify sonar:sonar -Dsonar.token=%SONAR_TOKEN% -Dsonar.projectKey=easybuggy1 -Dsonar.host.url=http://localhost:9000/")
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        withDockerRegistry([credentialsId: "dockerlogin", url: ""]) {
          script {
            app = docker.build("asecurityguru/testeb")
          }
        }
      }
    }

    stage('Run Snyk Container Scan') {
      steps {
        withCredentials([string(credentialsId: 'SNYK_TOKEN', variable: 'SNYK_TOKEN')]) {
          script {
            def status = bat(returnStatus: true, script: "C:\\snyk\\snyk-win.exe container test asecurityguru/testeb --fail-on=none")
            echo "Snyk container scan exit code: ${status}"
          }
        }
      }
    }

    stage('Run Snyk SCA') {
      steps {
        withCredentials([string(credentialsId: 'SNYK_TOKEN', variable: 'SNYK_TOKEN')]) {
          script {
            def status = bat(returnStatus: true, script: "mvn snyk:test -fn")
            echo "Snyk SCA scan exit code: ${status}"
          }
        }
      }
    }

    stage('Run DAST Using ZAP') {
      steps {
        script {
          // Ensure ZAP_Reports directory exists
          bat("if not exist \"%WORKSPACE%\\ZAP_Reports\" mkdir \"%WORKSPACE%\\ZAP_Reports\"")

          // Set output file
          def zapOutput = "%WORKSPACE%\\ZAP_Reports\\ZAP_Output.html"

          // Run ZAP scan using latest 2.16.0 jar
          def status = bat(returnStatus: true, script: """
            java -Xmx512m -jar "C:\\zap\\ZAP_2.16.0_Crossplatform\\ZAP_2.16.0\\zap-2.16.0.jar" ^
            -port 9393 ^
            -cmd ^
            -quickurl https://www.example.com ^
            -quickprogress ^
            -quickout ${zapOutput}
          """)
          echo "ZAP scan exit code: ${status}"

          // Verify file creation
          bat("if exist \"${zapOutput}\" echo ZAP report created")
        }
      }
    }

    stage('Archive ZAP Report') {
      steps {
        archiveArtifacts artifacts: 'ZAP_Reports\\ZAP_Output.html', fingerprint: true
      }
    }

    stage('Run Checkov') {
      steps {
        script {
          def status = bat(returnStatus: true, script: "checkov -s -f main.tf")
          echo "Checkov exit code: ${status}"
        }
      }
    }
  }
}
