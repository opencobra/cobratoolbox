# runtests.sh
matlab$MATLAB_VER -nodesktop -nosplash < test/launchTests.m
CODE=$?
exit $CODE
