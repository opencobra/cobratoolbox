#!/bin/sh
if [ "$ARCH" == "Linux" ]; then
    /mnt/data/MATLAB/$MATLAB_VER/bin/./matlab -nodesktop -nosplash < test/testAll.m

elif [ "$ARCH" == "macOS" ]; then
    /Applications/MATLAB_$MATLAB_VER.app/bin/matlab -nodesktop -nosplash < test/testAll.m

elif [ "$ARCH" == "Windows" ]; then
    # change to the build directory
    echo " -- killing the sh process --"
    nohup "C:\\Windows\\System32\\cmd.exe" /c taskkill /im ssh-agent.exe /f /fi "memusage gt 40" 2>NUL | findstr SUCCESS >NUL && if errorlevel 1 ( echo ssh-agent was not killed ) else ( echo ssh-agent was killed )
    nohup "C:\\Windows\\System32\\cmd.exe" /c taskkill /im sh.exe /f /fi "memusage gt 40" 2>NUL | findstr SUCCESS >NUL && if errorlevel 1 ( echo sh was not killed ) else ( echo sh was killed )

    echo " -- changing to the build directory --"
    cd "D:\\jenkins\\workspace\\COBRAToolbox-windows\\MATLAB_VER\\$MATLAB_VER\\label\\windows-biocore"
    echo " -- launching MATLAB --"

    # launch the test suite as a background process
    nohup "C:\\Program Files\\Matlab\\$MATLAB_VER\\\bin\\matlab.exe" -nojvm -nodesktop -nosplash -useStartupFolderPref -logfile output.log -wait -r "cd test; testAll;" & PID=$!

    # follow the log file
    tail -n0 -F --pid=$! output.log 2>/dev/null

    # wait until the background process is done
    wait $PID

fi

CODE=$?
exit $CODE
