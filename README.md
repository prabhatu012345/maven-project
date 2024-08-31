# Create a Hello-World Java Project with Maven and Jenkins

## Create a directory name as "hello-world"
mkdir hello-world
cd hello-world

## Create a new Maven project using the command line:
mvn archetype:generate -DgroupId=com.example -DartifactId=hello-world -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false

This will create a basic Maven project structure with the following:

hello-world/
├── pom.xml
└── src
    ├── main
    │   └── java
    │       └── com
    │           └── example
    │               └── App.java
    └── test
        └── java
            └── com
                └── example
                    └── AppTest.java

## Initialize Git Repository:
git init
## Create a .gitignore File:
echo "target/" > .gitignore

## Commit the Project:
git add .
git commit -m "Initial commit - Hello World Maven project"
## Push to GitHub:
git remote add origin https://github.com/your-username/hello-world.git
git branch -M main
git push -u origin main

# Create a Jenkins Pipeline to Build, Test with JMeter, and Create an Artifact

## Install Required Plugins:

Ensure that Jenkins has Maven, Git, and JMeter installed.
Install the "Maven Integration Plugin" and "Performance Plugin" for JMeter support.

## Create a Pipeline Job:
Open Jenkins and create a new pipeline job named hello-world-pipeline.
Configure the pipeline to pull from the GitHub repository.
# Jenkins Pipeline Script:
pipeline {
    agent any

    tools {
        maven 'Maven 3.x'  // Ensure you have Maven installed and configured
        jdk 'JDK 11'       // Ensure Java JDK is installed
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/your-username/hello-world.git', branch: 'main'
            }
        }

        stage('Build') {
            steps {
                script {
                    // Clean and build the project
                    sh 'mvn clean package'
                }
            }
        }

        stage('Test with JMeter') {
            steps {
                script {
                    // Run JMeter tests (ensure JMeter script is available in the workspace)
                    sh '/path/to/jmeter -n -t test-plan.jmx -l results.jtl'
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}

since Jenkins is running on a GKE (Google Kubernetes Engine) cluster, you need to ensure that Maven, JMeter, and any other required tools are available within the Jenkins environment on the cluster.
Install Maven and JMeter on GKE Cluster
Since Jenkins is running in a containerized environment on GKE, you need to install these tools inside the Jenkins container. There are two main approaches:

Approach A: Customize Jenkins Docker Image
Create a custom Docker image for Jenkins that includes Maven, JMeter, and any other dependencies. This approach ensures that all necessary tools are consistently available whenever Jenkins is restarted or scaled.

Steps:

Create a Dockerfile for Jenkins with Maven and JMeter:

Here is a sample Dockerfile:

Dockerfile
Copy code
# Start with the official Jenkins image
FROM jenkins/jenkins:lts

# Install required packages
USER root
RUN apt-get update && apt-get install -y \
    maven \
    wget \
    unzip \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install JMeter
ARG JMETER_VERSION=5.5
RUN wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz \
    && tar -xzf apache-jmeter-${JMETER_VERSION}.tgz -C /opt \
    && rm apache-jmeter-${JMETER_VERSION}.tgz

# Set JMeter environment variable
ENV PATH="/opt/apache-jmeter-${JMETER_VERSION}/bin:${PATH}"

# Switch back to the Jenkins user
USER jenkins
Build and Push the Docker Image:

Build the Docker image with Maven and JMeter, and push it to a container registry (like Docker Hub or Google Container Registry):

bash
Copy code
docker build -t your-docker-repo/jenkins-maven-jmeter:latest .
docker push your-docker-repo/jenkins-maven-jmeter:latest
Update Jenkins Deployment in GKE:

Modify your Jenkins deployment configuration in GKE to use the new custom image:

yaml
Copy code
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      containers:
      - name: jenkins
        image: your-docker-repo/jenkins-maven-jmeter:latest
        ports:
        - containerPort: 8080
Approach B: Install Tools Directly on the Running Jenkins Pod
If you prefer not to build a custom image, you can install Maven and JMeter directly on the Jenkins pod each time it starts. This is less stable and slower but can be used for quick tests.

Steps:

Open a Terminal in the Jenkins Pod:

Get the Jenkins pod name and open a terminal:

bash
Copy code
kubectl get pods -n jenkins
kubectl exec -it <jenkins-pod-name> -n jenkins -- /bin/bash
Install Maven and JMeter Inside the Pod:

Install Maven and JMeter manually:

bash
Copy code
apt-get update && apt-get install -y maven wget unzip openjdk-11-jdk

# Install JMeter
JMETER_VERSION=5.5
wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz
tar -xzf apache-jmeter-${JMETER_VERSION}.tgz -C /opt
export PATH="/opt/apache-jmeter-${JMETER_VERSION}/bin:${PATH}"
Persist Changes (if required):

Note that changes made directly inside the pod are not persistent. For a more permanent solution, consider using a custom image (Approach A).

2. Update Jenkins Pipeline
Make sure the Jenkins pipeline script uses the correct path for JMeter (/opt/apache-jmeter-5.5/bin/jmeter in this case) and Maven commands are correctly configured.

Here’s a revised snippet of the Jenkins pipeline:

pipeline {
    agent any

    tools {
        maven 'Maven 3.x'
        jdk 'JDK 11'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/your-username/hello-world.git', branch: 'main'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Test with JMeter') {
            steps {
                // Adjust the JMeter command path based on installation location
                sh '/opt/apache-jmeter-5.5/bin/jmeter -n -t test-plan.jmx -l results.jtl'
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}





