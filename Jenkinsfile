pipeline {
  agent any
  stages {
    stage('test') {
      steps {
        sh '''#!/bin/bash
env
/usr/local/MATLAB/R2020a/bin/matlab -nodesktop -nosplash < ./test/testAll.m'''
      }
    }

  }
  post {
        always {
            // This will always run, even if the pipeline fails
            echo 'This will always run'
        }
        success {
            // This will only run if the pipeline was successful
            echo 'This will run only if the pipeline was successful'
        }
        failure {
            // This will only run if the pipeline failed
            echo 'This will run only if the pipeline failed'
        }
    }
}
