/*
Variable to capture the result of each stage.
NOTE: In case of addition of new stage(s) the changes has to be made to append the STATUS of those stage to STATUSDICT.
*/

def STATUSDICT = [:]
def FAILED_STAGES = []
def JOB_STATUS = ""

pipeline {
    agent { label 'smoke7' }

    stages {
        stage('Build RPM') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '$sha1']], userRemoteConfigs: [[name: 'origin', url: 'https://github.com/gluster/glusterfs.git']]])
                build job: 'rpm-el7', parameters: [string(name: 'sha1', value: "$sha1")], propagate: true
                build job: 'rpm-fedora', parameters: [string(name: 'sha1', value: "$sha1")], propagate: true
            }
        }
        stage('Tests') {
            parallel {
                stage('regression') {
                    steps {
                        script {
                            echo 'Running centos7 regression'
                            def buildReg = build job: 'regression-test-burn-in', propagate: false
                            STATUSDICT.put("${env.STAGE_NAME}", buildReg.getResult())
                        }
                    }
                }
                stage('regression-with-multiplex') {
                    steps {
                        script {
                            echo 'Running centos7 regression with multiplex'
                            def regWithMul = build job: 'regression-test-with-multiplex', propagate: false
                            STATUSDICT.put("${env.STAGE_NAME}", regWithMul.getResult())
                        }
                    }
                }
                stage('clang-scan') {
                    steps {
                        script {
                            echo 'Running clang scan'
                            def clangScan = build job: 'clang-scan', parameters: [string(name: 'sha1', value: "$sha1")], propagate: false
                            STATUSDICT.put("${env.STAGE_NAME}", clangScan.getResult())
                        }
                    }
                }
                stage('cppcheck') {
                    steps {
                        script {
                            echo 'Running cppcheck'
                            def cppCheck = build job: 'cppcheck', parameters: [string(name: 'sha1', value: "$sha1")], propagate: false
                            STATUSDICT.put("${env.STAGE_NAME}", cppCheck.getResult())
                        }
                    }
                }
                stage('line-coverage') {
                    steps {
                        script {
                            echo 'Running line coverage'
                            def lineCov = build job: 'line-coverage', parameters: [string(name: 'sha1', value: "$sha1")], propagate: false
                            STATUSDICT.put("${env.STAGE_NAME}", lineCov.getResult())
                        }
                    }
                }
            }
        }
    }
 post {
        always {
            deleteDir() /* clean up our workspace */
            script {
                STATUSDICT.each { key, val ->
                    println "STAGE: $key = STATUS $val"
                    if ("${val}" == "FAILURE") {
                        FAILED_STAGES.add("${key}")
                        JOB_STATUS="FAILED"
                    }
                }
            }
            script {
                if ("${JOB_STATUS}" == "FAILED") {
                    emailext (
                        mimeType: 'text/html',
                        subject: "The Job: '${env.JOB_NAME} - [${env.BUILD_NUMBER}] has failed at a stage(s)!'",
                        to: "maintainers@gluster.org",
                        body: """<p>FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' has failed at the below Stages:</p><br><p>${FAILED_STAGES}</p><br>
                        <p>Check console output at : <a href='${env.BUILD_URL}console'>${env.BUILD_URL}console</a></p>""",
                        recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']]
                    )
                    currentBuild.result = 'FAILURE'
                } else {
                    currentBuild.result = 'SUCCESS'
                }
            }
        }
    }
}
