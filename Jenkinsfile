import org.jenkinsci.plugins.pipeline.modeldefinition.Utils

node {
    boolean PullSuccess = false
    boolean BuiltSuccess = false

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
    stage('Built') {
        if (PullSuccess == true) {
            docker.image('sureshkvl/pytester:latest').inside('-p 3000:3000') {

            }
            // docker.image('python:3.7.14-alpine3.16').inside {
            //     catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
            //         sh 'python -m py_compile sources/add2vals.py sources/calc.py'
            //         BuiltSuccess = true
            //     }
            // }
        }else{
            Utils.markStageSkippedForConditional(STAGE_NAME)
        }
    }
    stage('Test') {
        if( BuiltSuccess == true ){
            catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                docker.image('sureshkvl/pytester:latest', '-p 3000:3000').inside {
                    sh 'py.test --verbose --junit-xml test-reports/results.xml sources/test_calc.py'
                    junit 'test-reports/results.xml'
                    BuiltSuccess = true
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