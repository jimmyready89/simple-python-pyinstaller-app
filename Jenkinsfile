import org.jenkinsci.plugins.pipeline.modeldefinition.Utils

node {
    boolean PullSuccess = false
    boolean BuiltSuccess = false
    boolean TestSuccess = false
    boolean ReleaseSuccess = false

    stage('cek tipe os') {
        if (isUnix() == false) {
            error "node harus berjalan di os unix"
        }
    }
    stage('Pull scripts dari repository github') {
        catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
            git branch: 'master', url: 'https://github.com/jimmyready89/simple-python-pyinstaller-app.git'
            PullSuccess = true
        }
    }
    stage('Build') {
        if (PullSuccess == true) {
            docker.image('python:3.7.14-alpine3.16').inside('-p 3000:3000') {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    sh 'python -m py_compile sources/add2vals.py sources/calc.py'
                    BuiltSuccess = true
                }
            }
        }else{
            Utils.markStageSkippedForConditional(STAGE_NAME)
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
    stage('AppCreate') { 
        if (TestSuccess == true) {
            catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                docker.image('python:3.7.14-alpine3.16').inside('-p 3000:3000 -it --user=root') {
                    sh 'apk add binutils'
                    sh 'pip install pyinstaller'
                    sh 'pyinstaller --onefile sources/add2vals.py'
                }
                archiveArtifacts 'dist/add2vals'

                ReleaseSuccess = true
            }
        }else{
            Utils.markStageSkippedForConditional(STAGE_NAME)
        }
    }
    withCredentials([string(credentialsId: 'heroku-api-key', variable: 'HEROKU_API_KEY')]) {
        withEnv(['IMAGE_NAME=jimmy/submision', 'IMAGE_TAG=latest', 'APP_NAME=base-file']) {
            stage('Deploy') { 
                if (ReleaseSuccess == true) {
                    // input message: 'Yakin Melakukan Deployment ?' 

                    // sleep time: 1, unit: 'MINUTES'

                    catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                        sh 'echo $HEROKU_API_KEY | docker login --username=_ --password-stdin registry.heroku.com'

                        sh '''
                            docker build -t $IMAGE_NAME:$IMAGE_TAG .
                            docker tag $IMAGE_NAME:$IMAGE_TAG registry.heroku.com/$APP_NAME/$BUILD_NUMBER
                            docker push registry.heroku.com/$APP_NAME/$BUILD_NUMBER
                        '''

                        docker.image('debian:buster-slim').inside('-p 3000:3000 -it --user=root') {
                            sh 'sudo apt install curl'
                            sh 'curl https://cli-assets.heroku.com/install-ubuntu.sh | sh'
                            sh "HEROKU_API_KEY='${HEROKU_API_KEY}' heroku container:release image-${BUILD_NUMBER} --app=${APP_NAME}"
                        }
                    }

                    sh 'docker logout'
                }else{
                    Utils.markStageSkippedForConditional(STAGE_NAME)
                }
            }
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