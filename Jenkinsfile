/* Requires the Docker Pipeline plugin */
pipeline {
    agent { sudo docker { image 'node:20.18.0-alpine3.20' } }
    stages {
        stage('build') {
            steps {
                sh 'node --version'
            }
        }
    }
}
