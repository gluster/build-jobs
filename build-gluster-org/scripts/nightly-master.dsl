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
                        build job: 'regression-test-burn-in', parameters: [string(name: 'GERRIT_REFSPEC', value: 'refs/heads/master'), string(name: 'GERRIT_BRANCH', value: 'master')], propagate: true
                        echo 'Running centos7 regression'
                    }
                }
                stage('regression-with-multiplex') {
                    steps {
                        build job: 'regression-test-with-multiplex', parameters: [string(name: 'GERRIT_REFSPEC', value: 'refs/heads/master'), string(name: 'GERRIT_BRANCH', value: 'master')], propagate: true
                        echo 'Running centos7 regression with multiplex'
                    }
                }
                stage('clang-scan') {
                    steps {
                        build job: 'clang-scan', parameters: [string(name: 'GERRIT_REFSPEC', value: 'refs/heads/master'), string(name: 'GERRIT_BRANCH', value: 'master')], propagate: true
                        echo 'Running clang scan'
                    }
                }
                stage('cppcheck') {
                    steps {
                        build job: 'cppcheck', parameters: [string(name: 'GERRIT_REFSPEC', value: 'refs/heads/master'), string(name: 'GERRIT_BRANCH', value: 'master')], propagate: true
                        echo 'Running cppcheck'
                    }
                }
                stage('line-coverage') {
                    steps {
                        build job: 'line-coverage', parameters: [string(name: 'GERRIT_REFSPEC', value: 'refs/heads/master'), string(name: 'GERRIT_BRANCH', value: 'master')], propagate: true
                        echo 'Running line coverage'
                    }
                }
            }
        }
    }
 post {
        always {
            deleteDir() /* clean up our workspace */
        }
    }
}
