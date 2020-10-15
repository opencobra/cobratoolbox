pipeline {
  agent any
  stages {
    stage('test') {
      parallel {
        stage('testAll_matlab_R2020a') {
          steps {
            sh 'CNA_PATH=/home/jenkins /usr/local/MATLAB/R2020a/bin/matlab -nodesktop -nosplash < ./test/testAll.m'
          }
        }

        stage('testAll_matlab_2019b') {
          steps {
            sh 'CNA_PATH=/home/jenkins /usr/local/MATLAB/R2019b/bin/matlab -nodesktop -nosplash < ./test/testAll.m'
          }
        }

      }
    }

  }
}