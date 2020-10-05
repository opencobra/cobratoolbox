pipeline {
  agent any
  stages {
    stage('test') {
      steps {
        sh '''#!/bin/bash
/usr/local/MATLAB/R2020a/bin/matlab -nodesktop -nosplash < ./test/testAll.m'''
      }
    }

  }
}