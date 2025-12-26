pipeline {
    agent any

    tools {
        maven 'Maven_3_8_7'
    }

    stages {

        stage('Build') {
            steps {
                bat 'mvn clean package -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                bat 'docker build -t asecurityguru/testeb .'
            }
        }

        stage('Security Scans') {

            stages {

                stage('Snyk Container') {
                    steps {
                        bat '"C:\\snyk\\snyk-win.exe" container test asecurityguru/testeb || exit /b 0'
                    }
                }

                stage('Snyk SCA') {
                    steps {
                        bat 'mvn snyk:test -fn || exit /b 0'
                    }
                }

                stage('ZAP DAST') {
                    steps {
                        bat 'if not exist "%WORKSPACE%\\ZAP_Reports" mkdir "%WORKSPACE%\\ZAP_Reports"'
                        bat 'cd /d "C:\\ZAP\\ZAP_2.16.0_Crossplatform\\ZAP_2.16.0" && zap.bat -cmd -quickurl https://www.example.com -quickout "%WORKSPACE%\\ZAP_Reports\\ZAP_Output.html"'
                    }
                }

                stage('Checkov') {
                    steps {
                        bat '"C:\\Users\\Akshay Bharadwaj\\AppData\\Roaming\\Python\\Python313\\Scripts\\checkov.exe" -s -f main.tf || exit /b 0'
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'ZAP_Reports/ZAP_Output.html', allowEmptyArchive: true
        }
    }
}
