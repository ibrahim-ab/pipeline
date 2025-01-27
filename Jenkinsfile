def git_branch_name = "main" // The name of the branch.
def git_url = "https://github.com/ibrahim-ab/pipeline.git" // The address of the GitHub repository.

pipeline {
    agent any
    environment {
        GITHUB_REPO = 'github.com/ibrahim-ab/pipeline.git'
        DOCKER_REPO = 'ialbakri/pipeline'
    }
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
                sh 'docker --version'
            }
        }

        stage('Checkout Git Repo') {
    steps {
        script {
            withCredentials([usernamePassword(credentialsId: 'Github_Credentials', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN')]) {
                sh 'git config --global http.sslVerify false'
                sh "git clone https://${GITHUB_USER}:${GITHUB_TOKEN}@${GITHUB_REPO} || exit 1"
            }
            dir('pipeline') {
                sh 'ls -la'  // Confirm repo clone
                sh 'git status'
                sh 'git branch'
            }
        }
    }
}


        stage('Set Tag Version') {
            steps {
                script {
                    // Use Docker Hub API to fetch the latest tag
                    def response = sh(
                        script: '''
                            curl -s https://registry.hub.docker.com/v2/repositories/${DOCKER_REPO}/tags/?page_size=100 | \
                            jq -r '.results[].name' | grep -E '^[0-9]+\\.[0-9]+\\.[0-9]+$' | sort -V | tail -1
                        ''',
                        returnStdout: true
                    ).trim()

                    def latestTag = response ?: "0.0.0" // Fallback to initial version if no tags exist

                    // Extract and increment the version (assuming format is x.y.z)
                    def versionParts = latestTag.tokenize('.')
                    def patch = versionParts[2].toInteger() + 1
                    def newTagVersion = "${versionParts[0]}.${versionParts[1]}.${patch}"

                    env.TAG_VERSION = newTagVersion
                    echo "New tag version: ${newTagVersion}"
                }
            }
        }

        stage('Build Image') {
            steps {
                script {
                    dir('pipeline') {
                        sh "docker build -t ${DOCKER_REPO}:${TAG_VERSION} ."
                    }
                }
            }
        }

        stage('Push Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerHub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "docker login --username=${DOCKER_USERNAME} --password=${DOCKER_PASSWORD}"
                        sh "docker push ${DOCKER_REPO}:${TAG_VERSION}"
                    }
                }
            }
        }

        stage('Update YAML File') {
            steps {
                script {
                    dir('pipeline/hello') {
                        // Update the image tag in the YAML file
                        sh """
                            sed -i 's|image: ${DOCKER_REPO}:.*|image: ${DOCKER_REPO}:${TAG_VERSION}|' hello-ui-deployment.yaml
                        """
                    }
                }
            }
        }

        stage('Commit and Push Changes') {
            steps {
                script {
                    dir('pipeline') {
                        withCredentials([usernamePassword(credentialsId: 'Github_Credentials', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_PASSWORD')]) {
                            sh 'git config user.name "jenkins-bot"'
                            sh 'git config user.email "jenkins-bot@example.com"'
                            sh 'git add hello/hello-ui-deployment.yaml'
                            sh "git commit -m 'Update deployment image to version ${TAG_VERSION}'"
                            sh "git push origin ${git_branch_name}"
                        }
                    }
                }
            }
        }
    }
}
