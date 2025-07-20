def git_branch_name = "main" // The name of the branch.
def git_url = "https://github.com/ibrahim-ab/pipeline.git" // The address of the GitHub repository.

pipeline {
    agent any
    environment {
        GITHUB_REPO = 'github.com/ibrahim-ab/pipeline.git'
        DOCKER_REPO = 'ialbakri/pipeline'
    }
    stages {

stage('Check Commit Message') {
    steps {
        script {
            dir('pipeline') { // Ensure you are in the cloned repo directory
                def commitMessage = sh(
                    script: "git log -1 --pretty=%B",
                    returnStdout: true
                ).trim()
                if (commitMessage.contains('[skip-pipeline]')) {
                    echo "Skipping pipeline due to '[skip-pipeline]' in commit message."
                    currentBuild.result = 'SUCCESS'
                    error("Pipeline terminated: Skipped due to commit message.")
                }
            }
        }
    }
}
        
        stage('Clean Workspace') {
            steps {
                cleanWs()
                sh 'docker --version'
            }
        }

        stage('Checkout Git Repo') {
  steps {
    withCredentials([string(credentialsId: 'github-pat', variable: 'GITHUB_TOKEN')]) {
      // clone using only the token
      sh "git clone https://${GITHUB_TOKEN}@github.com/ibrahim-ab/pipeline.git pipeline"
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
    dir('pipeline') {
      withCredentials([string(credentialsId: 'github-pat', variable: 'GITHUB_TOKEN')]) {
        sh """
          git config user.name  "jenkins-bot"
          git config user.email "jenkins-bot@example.com"

          git add hello/hello-ui-deployment.yaml
          git commit -m "Update deployment image to version ${TAG_VERSION} [skip-pipeline]"

          # reset origin to include your token
          git remote set-url origin https://${GITHUB_TOKEN}@github.com/ibrahim-ab/pipeline.git

          git push origin ${git_branch_name}
        """
      }
    }
  }
}
    }
}
