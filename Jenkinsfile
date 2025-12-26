pipeline {
    agent any
    tools {
        maven 'Maven_3_8_7'
    }

    stages {
        stage('Compile and Run Sonar Analysis') {
            steps {
                withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                    bat "mvn -Dmaven.test.failure.ignore verify sonar:sonar -Dsonar.token=%SONAR_TOKEN% -Dsonar.projectKey=easybuggy1 -Dsonar.host.url=http://localhost:9000/"
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

        stage('Run Container Scan') {
            steps {
                withCredentials([string(credentialsId: 'SNYK_TOKEN', variable: 'SNYK_TOKEN')]) {
                    script {
                        try {
                            bat("C:\\snyk\\snyk-win.exe container test asecurityguru/testeb")
                        } catch (err) {
                            echo "Container scan found issues, but build will continue."
                        }
                    }
                }
            }
        }

        stage('Run Snyk SCA') {
            steps {
                withCredentials([string(credentialsId: 'SNYK_TOKEN', variable: 'SNYK_TOKEN')]) {
                    script {
                        try {
                            bat "mvn snyk:test -fn"
                        } catch (err) {
                            echo "Snyk found vulnerabilities. Build will continue, see report above."
                        }
                    }
                }
            }
        }

        stage('Run DAST Using ZAP') {
            steps {
                script {
                    // Ensure output folder exists
                    bat "mkdir \"%WORKSPACE%\\ZAP_Reports\" || exit 0"
                    bat """
                        java -Xmx512m -jar "C:\\zap\\ZAP_2.12.0_Crossplatform\\ZAP_2.12.0\\zap-2.12.0.jar" \
                        -port 9393 \
                        -cmd \
                        -quickurl https://www.example.com \
                        -quickprogress \
                        -quickout "%WORKSPACE%\\ZAP_Reports\\ZAP_Output.html"
                    """
                }
            }
        }

        stage('Checkov Scan') {
            steps {
                bat "checkov -s -f main.tf"
            }
        }
    }

    post {
        always {
            // Archive ZAP report
            archiveArtifacts artifacts: 'ZAP_Reports/ZAP_Output.html', allowEmptyArchive: true

            // Optional: archive Snyk report if it generates HTML (adjust path if needed)
            archiveArtifacts artifacts: '**/target/snyk-report.html', allowEmptyArchive: true
        }
    }
}
