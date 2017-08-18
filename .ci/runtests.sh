#!/bin/sh
if [ "$ARCH" == "Linux" ]; then
    /mnt/data/MATLAB/$MATLAB_VER/bin/./matlab -nodesktop -nosplash < test/testAll.m

elif [ "$ARCH" == "macOS" ]; then
    /Applications/MATLAB_$MATLAB_VER.app/bin/matlab -nodesktop -nosplash < test/testAll.m

elif [ "$ARCH" == "Windows" ]; then
    # change to the build directory
    #echo " -- original path --"
    #nohup "C:\\Windows\\System32\\cmd.exe" /c "SET PATH=%PATH%;"
    #"C:\\Windows\\System32\\cmd.exe" /c "echo %PATH%"
    #echo " -- new path --"
    #whoami
    #nohup "C:\\Windows\\System32\\cmd.exe" /c "whoami"
    #nohup "runas /user:sbg-jenkins@bpf00048 cmd"
    #nohup "C:\\Windows\\System32\\cmd.exe" /c "setx PATH \"%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;C:\Program Files (x86)\Windows Kits\10\Windows Performance Toolkit"

    #nohup "C:\\Windows\\System32\\cmd.exe" /c "SET PATH=%PATH%;C:\Program Files\Git\mingw64\bin; && echo %PATH%"
    #nohup "C:\\Windows\\System32\\cmd.exe" /c "taskkill /im explorer.exe /f && explorer.exe"
    #echo " -- new path --"
    #nohup "C:\\Windows\\System32\\cmd.exe" /c "echo %PATH%"

    #nohup "C:\\Windows\\System32\\cmd.exe" /c "taskkill /im ssh-agent.exe /f /fi \"memusage gt 40\" 2>NUL | findstr SUCCESS >NUL && if errorlevel 1 ( echo ssh-agent was not killed ) else ( echo ssh-agent was killed )"
    #nohup "C:\\Windows\\System32\\cmd.exe" /c "taskkill /im sh.exe /f /fi \"memusage gt 40\" 2>NUL | findstr SUCCESS >NUL && if errorlevel 1 ( echo sh was not killed ) else ( echo sh was killed )"

    echo " -- changing to the build directory --"
    cd "/cygdrive/d/jenkins/workspace/COBRAToolbox-windows/MATLAB_VER/R2016b/label/windows-biocore"
    #cd "D:\\jenkins\\workspace\\COBRAToolbox-windows\\MATLAB_VER\\$MATLAB_VER\\label\\windows-biocore"
    #echo " -- setting the git exec path --"
    #nohup "C:\\Windows\\System32\\cmd.exe" /c "SET GIT_EXEC_PATH=C:\Program Files\Git"

    echo " -- launching MATLAB --"
    unset Path
    # launch the test suite as a background process
    #matlab -logfile output.log -wait -r "system('which sh'); system('which git'); system('git --version'); system('whoami'); system('pwd'); system('git submodule');"
    nohup "/cygdrive/c/Program Files/MATLAB/R2016b/bin/matlab" -nojvm -nodesktop -nosplash -useStartupFolderPref -logfile output.log -wait -r "system('which sh'); system('which git'); system('git --version'); system('whoami'); system('pwd'); system('git submodule'); exit;" & PID=$!
    #nohup "C:\\Program Files\\Matlab\\$MATLAB_VER\\\bin\\matlab.exe"  -useStartupFolderPref -logfile output.log -wait -r "system('which git'); system('git --version'); system('whoami'); system('pwd'); initCobraToolbox" & PID=$! #cd test; testAll;
    #"C:\\Program Files\\Matlab\\R2016b\\\bin\\matlab.exe" -nojvm -nodesktop -nosplash -useStartupFolderPref -logfile output.log -wait -r "initCobraToolbox;" -nojvm -nodesktop -nosplash
    # follow the log file
    #tail -n0 -F --pid=$! output.log 2>/dev/null

    # wait until the background process is done
    wait $PID

fi

CODE=$?
exit $CODE
