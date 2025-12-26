pipeline {
    agent any

    tools {
        maven 'Maven_3_8_7'
    }

    environment {
        WORKSPACE_DIR = "${env.WORKSPACE}"
        ZAP_HOME = "C:\\zap\\ZAP_2.16.0_Crossplatform\\ZAP_2.16.0"
    }

    stages {

        stage('Compile and Sonar Analysis') {
            steps {
                withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                    bat """
                        mvn -Dmaven.test.failure.ignore verify sonar:sonar ^
                        -Dsonar.token=%SONAR_TOKEN% ^
                        -Dsonar.projectKey=easybuggy1 ^
                        -Dsonar.host.url=http://localhost:9000/
                    """
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
                    def zapReportDir = "${WORKSPACE_DIR}\\ZAP_Reports"
                    def zapReportHtml = "${zapReportDir}\\ZAP_Output.html"
                    def zapSession = "${zapReportDir}\\zap_session.session"

                    // Create report folder if it doesn't exist
                    bat "if not exist \"${zapReportDir}\" mkdir \"${zapReportDir}\""

                    // Run ZAP in daemon mode
                    bat """
                        java -Xmx512m -jar "${ZAP_HOME}\\zap-2.16.0.jar" ^
                        -daemon ^
                        -port 9393 ^
                        -quickurl https://www.example.com ^
                        -quickprogress ^
                        -quickout "${zapReportHtml}" ^
                        -noSplash ^
                        -newsession "${zapSession}"
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

            // Archive Snyk HTML report if generated
            archiveArtifacts artifacts: '**/target/snyk-report.html', allowEmptyArchive: true
        }
    }
}
