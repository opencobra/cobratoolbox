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
      echo 'This will always run'
    }

    success {
      echo 'This will run only if the pipeline was successful'
    }

    failure {
      echo 'This will run only if the pipeline failed'
    }

  }
}