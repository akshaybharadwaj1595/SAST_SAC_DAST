pipeline {
    agent any

    tools {
        maven 'Maven_3_8_7'
    }

    stages {

        stage('Compile') {
            steps {
                bat 'mvn clean verify -Dmaven.test.failure.ignore'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                        bat """mvn sonar:sonar -Dsonar.projectKey=easybuggy1 -Dsonar.host.url=http://localhost:9000/ -Dsonar.login=%SONAR_TOKEN%"""
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                withDockerRegistry([credentialsId: 'dockerlogin', url: '']) {
                    script {
                        docker.build('asecurityguru/testeb')
                    }
                }
            }
        }

        stage('Security Scans') {
            parallel {

                stage('Snyk Container Scan') {
                    steps {
                        withCredentials([string(credentialsId: 'SNYK_TOKEN', variable: 'SNYK_TOKEN')]) {
                            bat 'C:\\snyk\\snyk-win.exe container test asecurityguru/testeb || echo "Snyk container scan found issues."'
                        }
                    }
                }

                stage('Snyk SCA Scan') {
                    steps {
                        withCredentials([string(credentialsId: 'SNYK_TOKEN', variable: 'SNYK_TOKEN')]) {
                            bat 'mvn snyk:test -fn || echo "Snyk SCA scan found vulnerabilities."'
                        }
                    }
                }

                stage('DAST ZAP Scan') {
                    steps {
                        // Ensure report folder exists
                        bat 'if not exist C:\\JenkinsWorkspace\\ZAP_Reports mkdir C:\\JenkinsWorkspace\\ZAP_Reports'

                        // Run ZAP in headless mode from its installation folder
                        bat 'cd /d C:\\ZAP\\ZAP_2.16.0_Crossplatform\\ZAP_2.16.0 && zap.bat -cmd -quickurl https://www.example.com -report C:\\JenkinsWorkspace\\ZAP_Reports\\ZAP_Output.html -config api.disablekey=true'
                    }
                }

                stage('Checkov Scan') {
                    steps {
                        // Use full path with quotes to handle space in username
                        bat '"C:\\Users\\Akshay Bharadwaj\\AppData\\Roaming\\Python\\Python313\\Scripts\\checkov.exe" -s -f main.tf || echo "Checkov scan finished with findings."'
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'ZAP_Reports/ZAP_Output.html', allowEmptyArchive: true
            archiveArtifacts artifacts: '**/target/snyk-report.html', allowEmptyArchive: true
        }
    }
}
