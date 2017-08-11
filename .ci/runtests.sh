#!/bin/sh
echo "$ARCH"
if [ "$ARCH" == "Linux" ]; then
    /mnt/data/MATLAB/$MATLAB_VER/bin/./matlab -nodesktop -nosplash < test/testAll.m
elif [ "$ARCH" == "macOS" ]; then
    /Applications/MATLAB_$MATLAB_VER.app/bin/matlab -nodesktop -nosplash < test/testAll.m
elif [ "$ARCH" == "Windows" ]; then
    echo "Je suis ici"
    #cd /D D:
    cd "D:\jenkins\workspace\COBRAToolbox-windows\MATLAB_VER\R2016b\label\windows-biocore"
    # echo the current directory
    cd
    whoami
    #cd "D:"
    "C:\Program Files\Matlab\R2016b\bin\matlab.exe" -logfile output.log -wait -r "initCobraToolbox;"
    #"run('D:\jenkins\workspace\COBRAToolbox-windows\MATLAB_VER\R2016b\label\windows-biocore\test\testAll.m')"
    cat output.log
fi
CODE=$?
exit $CODE
