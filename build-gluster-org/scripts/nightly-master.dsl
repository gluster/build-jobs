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
                checkout([$class: 'GitSCM', branches: [[name: '$GERRIT_BRANCH']], userRemoteConfigs: [[name: 'origin', refspec: '$GERRIT_REFSPEC', url: 'git://review.gluster.org/glusterfs']]])
                build job: 'rpm-el7', parameters: [string(name: 'GERRIT_REFSPEC', value: "$GERRIT_REFSPEC"), string(name: 'GERRIT_BRANCH', value: "$GERRIT_BRANCH")], propagate: true
                build job: 'rpm-fedora', parameters: [string(name: 'GERRIT_REFSPEC', value: "$GERRIT_REFSPEC"), string(name: 'GERRIT_BRANCH', value: "$GERRIT_BRANCH")], propagate: true
            }
        }
        stage('Tests') {
            parallel {
                stage('regression') {
                    steps {
                        script {
                            try{
                                def buildReg = build job: 'regression-test-burn-in', parameters: [string(name: 'GERRIT_REFSPEC', value: 'refs/heads/master'), string(name: 'GERRIT_BRANCH', value: 'master')], propagate: false
                                echo 'Running centos7 regression'
                                STATUSDICT.put("${env.STAGE_NAME}", buildReg.getResult())
                            } catch(err) {
                                "Caught exception ignore: ${err}"
                            }
                        }
                    }
                }
                stage('regression-with-multiplex') {
                    steps {
                        script {
                            try{
                                def regWithMul = build job: 'regression-test-with-multiplex', parameters: [string(name: 'GERRIT_REFSPEC', value: 'refs/heads/master'), string(name: 'GERRIT_BRANCH', value: 'master')], propagate: false
                                echo 'Running centos7 regression with multiplex'
                                STATUSDICT.put("${env.STAGE_NAME}", regWithMul.getResult())
                            } catch(err) {
                                "Caught exception ignore: ${err}"
                            }
                        }
                    }
                }
                stage('clang-scan') {
                    steps {
                        script {
                            try{
                                def clangScan = build job: 'clang-scan', parameters: [string(name: 'GERRIT_REFSPEC', value: 'refs/heads/master'), string(name: 'GERRIT_BRANCH', value: 'master')], propagate: false
                                echo 'Running clang scan'
                                STATUSDICT.put("${env.STAGE_NAME}", clangScan.getResult())
                            } catch(err) {
                                "Caught exception ignore: ${err}"
                            }
                        }
                    }
                }
                stage('cppcheck') {
                    steps {
                        script {
                            try{
                                def cppCheck = build job: 'cppcheck', parameters: [string(name: 'GERRIT_REFSPEC', value: 'refs/heads/master'), string(name: 'GERRIT_BRANCH', value: 'master')], propagate: false
                                echo 'Running cppcheck'
                                STATUSDICT.put("${env.STAGE_NAME}", cppCheck.getResult())
                            } catch(err) {
                                "Caught exception ignore: ${err}"
                            }
                        }
                    }
                }
                stage('line-coverage') {
                    steps {
                        script {
                            try{
                                def lineCov = build job: 'line-coverage', parameters: [string(name: 'GERRIT_REFSPEC', value: 'refs/heads/master'), string(name: 'GERRIT_BRANCH', value: 'master')], propagate: false
                                echo 'Running line coverage'
                                STATUSDICT.put("${env.STAGE_NAME}", lineCov.getResult())
                            } catch(err) {
                                "Caught exception ignore: ${err}"
                            }
                        }
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
            //All the stages will pass as there's a try and catch block.
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
