pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/prabhatu012345/maven-project.git'
            }
        }

        stage('Prepare Environment') {
            parallel {
                stage('Setup JUnit and JMeter') {
                    steps {
                        script {
                            def jmeterPod = kubernetesPod(yaml: """
                            apiVersion: v1
                            kind: Pod
                            metadata:
                              name: jmeter-pod
                            spec:
                              containers:
                              - name: jmeter
                                image: jmeter-image
                                command:
                                - cat
                                tty: true
                            """)
                            jmeterPod.run {
                                sh 'apt-get update'
                                sh 'apt-get install -y junit jmeter'
                            }
                        }
                    }
                }

                stage('Setup Maven') {
                    steps {
                        script {
                            def mavenPod = kubernetesPod(yaml: """
                            apiVersion: v1
                            kind: Pod
                            metadata:
                              name: maven-pod
                            spec:
                              containers:
                              - name: maven
                                image: maven-image
                                command:
                                - cat
                                tty: true
                            """)
                            mavenPod.run {
                                sh 'apt-get update'
                                sh 'apt-get install -y maven'
                            }
                        }
                    }
                }
            }
        }

        stage('Execute Test Cases') {
            steps {
                script {
                    sh './junit-runner.sh'
                }
            }
        }

        stage('Build Code') {
            steps {
                script {
                    sh 'mvn clean install'
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
            }
        }
    }
}
