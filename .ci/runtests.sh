#!/bin/sh
if [ $ARCH = "Linux" ]; then
    /mnt/data/MATLAB/$MATLAB_VER/bin/./matlab -nodesktop -nosplash < test/testAll.m
elif [ $ARCH = "macOS" ]; then
    /Applications/MATLAB_$MATLAB_VER.app/bin/matlab -nodesktop -nosplash < test/testAll.m
elif [ $ARCH = "Windows" ]; then
    c:/Program\ Files/MATLAB/$MATLAB_VER/bin/matlab -nodesktop -nosplash < test/testAll.m
fi
CODE=$?
exit $CODE
