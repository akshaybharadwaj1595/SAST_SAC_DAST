pipeline {
    agent any
    tools {
        maven 'Maven_3_8_7'
    }

    environment {
        WORKSPACE_DIR = "${env.WORKSPACE}"
    }

    stages {

        stage('Compile and Sonar Analysis') {
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
                            echo "Snyk container scan found issues, build continues."
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
                            echo "Snyk SCA scan found vulnerabilities, build continues."
                        }
                    }
                }
            }
        }

        stage('Run DAST with ZAP') {
            steps {
                script {
                    // Ensure folder exists
                    bat "mkdir \"%WORKSPACE_DIR%\\ZAP_Reports\" || exit 0"

                    // Headless ZAP scan
                    bat """
                        java -Xmx512m -jar "C:\\zap\\ZAP_2.12.0_Crossplatform\\ZAP_2.12.0\\zap-2.12.0.jar" ^
                        -daemon ^
                        -port 9393 ^
                        -quickurl https://www.example.com ^
                        -quickprogress ^
                        -quickout "%WORKSPACE_DIR%\\ZAP_Reports\\ZAP_Output.html" ^
                        -noSplash ^
                        -newsession "%WORKSPACE_DIR%\\ZAP_Reports\\zap_session.session"
                    """
                }
            }
        }

        stage('Run Checkov Scan') {
            steps {
                bat "checkov -s -f main.tf"
            }
        }
    }

    post {
        always {
            // Archive ZAP HTML report
            archiveArtifacts artifacts: 'ZAP_Reports/ZAP_Output.html', allowEmptyArchive: true

            // Optional: archive Snyk HTML report if generated
            archiveArtifacts artifacts: '**/target/snyk-report.html', allowEmptyArchive: true
        }
    }
}
