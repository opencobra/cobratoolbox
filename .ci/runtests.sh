#!/bin/sh
echo "$ARCH"
if [ "$ARCH" == "Linux" ]; then
    /mnt/data/MATLAB/$MATLAB_VER/bin/./matlab -nodesktop -nosplash < test/testAll.m
elif [ "$ARCH" == "macOS" ]; then
    /Applications/MATLAB_$MATLAB_VER.app/bin/matlab -nodesktop -nosplash < test/testAll.m
elif [ "$ARCH" == "Windows" ]; then
    # change to the build directory
    echo " -- Changing to the build directory --"
    cd "D:\jenkins\workspace\COBRAToolbox-windows\MATLAB_VER\R2016b\label\windows-biocore"
    echo " -- Launching MATLAB --"
    # launch the test suite as a background process
    nohup "C:\Program Files\Matlab\R2016b\bin\matlab.exe" -nodesktop -nosplash -useStartupFolderPref -logfile output.log -wait -r "cd test; testAll;" & PID=$!
    # follow the log file
    tail -n0 -F --pid=$! output.log 2>/dev/null
    # wait until the background process is done
    wait $PID
fi

CODE=$?
exit $CODE
