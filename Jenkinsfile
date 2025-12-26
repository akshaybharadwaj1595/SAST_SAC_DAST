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
                script {
                    withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                        try {
                            bat """
                                mvn -Dmaven.test.failure.ignore verify sonar:sonar ^
                                -Dsonar.token=%SONAR_TOKEN% ^
                                -Dsonar.projectKey=easybuggy1 ^
                                -Dsonar.host.url=http://localhost:9000/
                            """
                        } catch (err) {
                            echo "SonarQube server unreachable or error occurred, skipping analysis."
                        }
                    }
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
                        echo "Running Snyk Container Scan..."
                        bat """
                            C:\\snyk\\snyk-win.exe container test asecurityguru/testeb || echo "Snyk container scan found issues, build continues."
                        """
                    }
                }
            }
        }

        stage('Run Snyk SCA') {
            steps {
                withCredentials([string(credentialsId: 'SNYK_TOKEN', variable: 'SNYK_TOKEN')]) {
                    script {
                        echo "Running Snyk SCA Scan..."
                        bat """
                            mvn snyk:test -fn || echo "Snyk SCA scan found vulnerabilities, build continues."
                        """
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

                    // Run ZAP in CLI headless mode
                    echo "Running ZAP DAST scan..."
                    bat """
                        java -Xmx512m -jar "${ZAP_HOME}\\zap-2.16.0.jar" ^
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
                echo "Running Checkov Scan..."
                bat "checkov -s -f main.tf || echo \"Checkov scan finished with findings, build continues.\""
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
