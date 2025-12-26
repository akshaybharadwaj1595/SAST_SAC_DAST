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
                        bat '''
                            mvn sonar:sonar \
                                -Dsonar.projectKey=easybuggy1 \
                                -Dsonar.host.url=http://localhost:9000/ \
                                -Dsonar.login=%SONAR_TOKEN%
                        '''
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
                        bat 'if not exist C:\\JenkinsWorkspace\\ZAP_Reports mkdir C:\\JenkinsWorkspace\\ZAP_Reports'
                        bat '''
                            java -Xmx512m -jar C:\\zap\\ZAP_2.16.0_Crossplatform\\ZAP_2.16.0\\zap-2.16.0.jar \
                                -quickurl https://www.example.com \
                                -quickprogress \
                                -quickout C:\\JenkinsWorkspace\\ZAP_Re_
