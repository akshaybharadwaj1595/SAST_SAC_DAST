pipeline {
    agent any

    tools {
        maven 'Maven_3_8_7'
    }

    stages {

        stage('Compile and Sonar Analysis') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                        try {
                            bat 'mvn -Dmaven.test.failure.ignore verify sonar:sonar -Dsonar.token=%SONAR_TOKEN% -Dsonar.projectKey=easybuggy1 -Dsonar.host.url=http://localhost:9000/'
                        } catch (err) {
                            echo 'SonarQube server unreachable or error occurred, skipping analysis.'
                        }
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                withDockerRegistry([credentialsId: 'dockerlogin', url: '']) {
                    script {
                        app = docker.build('asecurityguru/testeb')
                    }
                }
            }
        }

        stage('Run Container Scan') {
            steps {
                withCredentials([string(credentialsId: 'SNYK_TOKEN', variable: 'SNYK_TOKEN')]) {
                    echo 'Running Snyk Container Scan...'
                    bat 'C:\\snyk\\snyk-win.exe container test asecurityguru/testeb || echo Snyk container scan found issues, build continues.'
                }
            }
        }

        stage('Run Snyk SCA') {
            steps {
                withCredentials([string(credentialsId: 'SNYK_TOKEN', variable: 'SNYK_TOKEN')]) {
                    echo 'Running Snyk SCA Scan...'
                    bat 'mvn snyk:test -fn || echo Snyk SCA scan found vulnerabilities, build continues.'
                }
            }
        }

        stage('Run DAST with ZAP') {
            steps {
                echo 'Running ZAP DAST scan...'
                bat 'if not exist C:\\JenkinsWorkspace\\ZAP_Reports mkdir C:\\JenkinsWorkspace\\ZAP_Reports'
                bat 'java -Xmx512m -jar C:\\zap\\ZAP_2.16.0_Crossplatform\\ZAP_2.16.0\\zap-2.16.0.jar -quickurl https://www.example.com -quickprogress -quickout C:\\JenkinsWorkspace\\ZAP_Reports\\ZAP_Output.html -noSplash -newsession C:\\JenkinsWorkspace\\ZAP_Reports\\zap_session.session'
            }
        }

        stage('Run Checkov Scan') {
            steps {
                echo 'Running Checkov Scan...'
                bat 'checkov -s -f main.tf || echo Checkov scan finished with findings, build continues.'
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
