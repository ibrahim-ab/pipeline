/* Requires the Docker Pipeline plugin */
pipeline {
    agent { docker { image 'node:20.18.0-alpine3.20'
                   label 'docker-node' // label for the ecs node with docker} }
    stages {
        stage('build') {
            steps {
                sh 'node --version'
            }
        }
    }
}
