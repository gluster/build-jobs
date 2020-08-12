pipeline {
    agent { label 'smoke7' }

    stages {
        stage('Build RPM') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '$GERRIT_BRANCH']], userRemoteConfigs: [[name: 'origin', refspec: '$GERRIT_REFSPEC', url: 'git://review.gluster.org/glusterfs']]])
                build job: 'rpm-el7', parameters: [string(name: 'GERRIT_REFSPEC', value: "$GERRIT_REFSPEC"), string(name: 'GERRIT_BRANCH', value: "$GERRIT_BRANCH")], propagate: true
                build job: 'rpm-fedora', parameters: [string(name: 'GERRIT_REFSPEC', value: "$GERRIT_REFSPEC"), string(name: 'GERRIT_BRANCH', value: "$GERRIT_BRANCH")], propagate: true
            }
        }
        stage('Tests') {
            parallel {
                stage('regression') {
                    steps {
                        build job: 'regression-test-burn-in', parameters: [string(name: 'GERRIT_REFSPEC', value: '$GERRIT_REFSPEC'), string(name: 'GERRIT_BRANCH', value: '$GERRIT_BRANCH')], propagate: true
                        echo 'Running centos7 regression'
                    }
                }
                stage('regression-with-multiplex') {
                    steps {
                        build job: 'regression-test-with-multiplex', parameters: [string(name: 'GERRIT_REFSPEC', value: '$GERRIT_REFSPEC'), string(name: 'GERRIT_BRANCH', value: '$GERRIT_BRANCH')], propagate: true
                        echo 'Running centos7 regression with multiplex'
                    }
                }
            }
        }
    }
 post {
        always {
            deleteDir() /* clean up our workspace */
        }
        success {
            emailext (
                mimeType: 'text/html',
                subject: "The Job: '${env.JOB_NAME} - [${env.BUILD_NUMBER}] has passed!'",
                to: "maintainers@gluster.org",
                body: """<p>SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' has passed.</p><br><p>Check console output at : <a href='${env.BUILD_URL}console'>${env.BUILD_URL}console</a></p>""",
                recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']]
            )
        }
        failure {
            emailext (
                mimeType: 'text/html',
                subject: "The Job: '${env.JOB_NAME} - [${env.BUILD_NUMBER}] has failed!'",
                to: "maintainers@gluster.org",
                body: """<p>FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' has failed.</p><br><p>Check console output at : <a href='${env.BUILD_URL}console'>${env.BUILD_URL}console</a></p>""",
                recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']]
            )
        }
    }
}
