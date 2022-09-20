import org.jenkinsci.plugins.pipeline.modeldefinition.Utils

node {
    boolean PullSuccess = false
    boolean BuiltSuccess = false
    boolean TestSuccess = false
    boolean ReleaseSuccess = false
    boolean DeployApprove = false

    stage('Build') {
        catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
            if (isUnix() == false) {
                error "node harus berjalan di os unix"
            }

            docker.image('python:3.7.14-alpine3.16').inside('-p 3000:3000') {
                git branch: 'master', url: 'https://github.com/jimmyready89/simple-python-pyinstaller-app.git'

                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    sh 'python -m py_compile sources/add2vals.py sources/calc.py'
                    BuiltSuccess = true
                }
            }
    }
    stage('Test') {
        if( BuiltSuccess == true ){
            catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                docker.image('sureshkvl/pytester:latest').inside('-p 3000:3000') {
                    sh 'py.test --verbose --junit-xml test-reports/results.xml sources/test_calc.py'
                    junit 'test-reports/results.xml'
                    TestSuccess = true
                }
            }
        }else{
            Utils.markStageSkippedForConditional(STAGE_NAME)
        }
    }
    stage('Manual Approval') { 
        if (TestSuccess == true) {
            catchError(buildResult: 'ABORTED', stageResult: 'ABORTED') {
               input message: 'Lanjutkan ke tahap Deploy?' 
               DeployApprove = true
            }
        }else {
            Utils.markStageSkippedForConditional(STAGE_NAME)
        }
    }
    stage('Deploy') { 
        if (DeployApprove == true ) {
            withCredentials([string(credentialsId: 'heroku-api-key', variable: 'HEROKU_API_KEY')]) {
                withEnv(['IMAGE_NAME=jimmy/submision', 'IMAGE_TAG=latest', 'APP_NAME=base-file']) {
                    catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                        docker.image('python:3.7.14-alpine3.16').inside('-p 3000:3000 -it --user=root') {
                            sh 'apk add binutils'
                            sh 'pip install pyinstaller'
                            sh 'pyinstaller --onefile sources/add2vals.py'
                        }

                        archiveArtifacts 'dist/add2vals'

                        sh 'echo $HEROKU_API_KEY | docker login --username=_ --password-stdin registry.heroku.com'

                        sh '''
                            docker build -t $IMAGE_NAME:$IMAGE_TAG .
                            docker tag $IMAGE_NAME:$IMAGE_TAG registry.heroku.com/$APP_NAME/image-$BUILD_NUMBER
                            docker push registry.heroku.com/$APP_NAME/image-$BUILD_NUMBER
                        '''

                        docker.image('debian:buster-slim').inside('-p 3000:3000 -it --user=root') {
                            sh 'apt-get update && apt-get upgrade -y'
                            sh 'apt-get install curl gnupg gnupg2 gnupg1 -y'
                            sh 'curl https://cli-assets.heroku.com/install-ubuntu.sh | sh'
                            sh "HEROKU_API_KEY='${HEROKU_API_KEY}' heroku container:release image-${BUILD_NUMBER} --app=${APP_NAME}"
                        }
                    }

                    sleep time: 1, unit: 'MINUTES'

                    sh 'docker logout'
                }
            }
        }else{
            Utils.markStageSkippedForConditional(STAGE_NAME)
        }
    }
    stage('Post Action Clean UP WS') {
        if( BuiltSuccess == false ){
            cleanWs()
        }else{
            Utils.markStageSkippedForConditional(STAGE_NAME)
        }
    }
}