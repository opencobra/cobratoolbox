#!/bin/sh
if [ "$ARCH" == "Linux" ]; then
    /mnt/prince-data/MATLAB/$MATLAB_VER/bin/./matlab -nodesktop -nosplash < test/testAll.m

elif [ "$ARCH" == "macOS" ]; then
    caffeinate -u &
    /Applications/MATLAB_$MATLAB_VER.app/bin/matlab -nodesktop -nosplash < test/testAll.m

elif [ "$ARCH" == "windows" ]; then
    # change to the build directory
    echo " -- changing to the build directory --"
    cd "D:\\jenkins\\workspace\\$CI_PROJECT_NAME\\MATLAB_VER\\$MATLAB_VER\\label\\$ARCHVERSION"

    echo " -- launching MATLAB --"
    unset Path
    nohup "D:\\MATLAB\\$MATLAB_VER\\\bin\\matlab.exe" -nojvm -nodesktop -nosplash -useStartupFolderPref -logfile output.log -wait -r "cd test; testAll;" & PID=$!

    # follow the log file
    tail -n0 -F --pid=$! output.log 2>/dev/null

    # wait until the background process is done
    wait $PID
fi

CODE=$?
exit $CODE
