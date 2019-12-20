#!/bin/sh

# Finding the right way to make bold characters depending on OS
bold=$(tput bold)
normal=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)

currentBranch="${GIT_BRANCH##origin/}"

echo "Checking if the test suite should be run..."
if [[ ! -z $GIT_PREVIOUS_SUCCESSFUL_COMMIT ]]; then
   commitHashs=($(git cherry $GIT_PREVIOUS_SUCCESSFUL_COMMIT HEAD 2>&1))
else
   echo " -- environment variable GIT_PREVIOUS_SUCCESSFUL_COMMIT is not set (or empty)."
   commitHashs=($(git log develop..$currentBranch -q --pretty=%H 2>&1))
fi

# check if all commit messages contains only [documentation]
allDocumentationLabel=true
artenolisForce=false
for s in "${commitHashs[@]}"
do
    if  [[ $s != "+" ]]; then
        commitHash=$s
        commitMsg=$(git show $commitHash -q --pretty=%B 2>&1)

        # for artenolis run if commitHash = fatal
        if [[ $commitHash == *"fatal"* ]]; then
            artenolisForce=true;
            echo " -- fatal detected - CI run is forced."
            break;
        fi

        # Exit if commit message contains the string: [documentation]
        if [[ ! $commitMsg == *"[documentation]"* ]]; then
            allDocumentationLabel=false;
            echo " -- at least one commit message ($commitHash) does not contain the label [documentation]."
            break;
        fi

        # force to run the test suite if labelled
        if [[ $commitMsg == *"[artenolis]"* ]]; then
            artenolisForce=true;
            echo " -- label [artenolis] detected - CI run is forced."
            break;
        fi
    fi
done

if [[ "$artenolisForce" = false ]]; then
    if [[ ! -z $GIT_PREVIOUS_SUCCESSFUL_COMMIT ]]; then
    modifiedFiles=($(git diff --name-only $GIT_PREVIOUS_SUCCESSFUL_COMMIT HEAD 2>&1))
    else
    modifiedFiles=($(git log develop..$currentBranch -q --pretty=%H | tail -1 2>&1))
    fi

    onlyDocFiles=true
    for f in "${modifiedFiles[@]}"
    do
        if  [[ ! $f == *"docs/"* ]]; then
            onlyDocFiles=false
            echo " -- at least one modified file ($f) is not stored under the docs/ folder."
            break;
        fi
    done

    if [[ ${#commitHashs[@]} > 0 ]]; then
        if [ "$allDocumentationLabel" = true ] || [ "$onlyDocFiles" = true ]; then
            echo "> Tests will be ${green}skipped${normal} as modified files are ${green}only${normal} documentation files."
            exit;
        fi
    fi

    echo "> Tests will be ${green}run${normal} as modified files are ${green}not only${normal} documentation files."
else
    echo "> Tests will be ${green}run${normal} label [artenolis] set."
fi

if [ "$ARCH" == "Linux" ]; then
    $ARTENOLIS_SOFT_PATH/MATLAB/$MATLAB_VER/bin/./matlab -nodesktop -nosplash < test/testAll.m

elif [ "$ARCH" == "macOS" ]; then
    caffeinate -u &
    /Applications/MATLAB_$MATLAB_VER.app/bin/matlab -nodisplay -nosplash < test/testAll.m

elif [ "$ARCH" == "windows" ]; then
    # change to the build directory
    echo " -- changing to the build directory --"
    cd "$ARTENOLIS_DATA_PATH\jenkins\\workspace\\$CI_PROJECT_NAME\\MATLAB_VER\\$MATLAB_VER\\label\\$NODE_LABELS"

    echo " -- launching MATLAB --"
    unset Path
    nohup "$ARTENOLIS_SOFT_PATH\MATLAB\\$MATLAB_VER\\\bin\\matlab.exe" -nojvm -nodesktop -nosplash -useStartupFolderPref -logfile output.log -wait -r "restoredefaultpath; cd $ARTENOLIS_DATA_PATH\jenkins\\workspace\\$CI_PROJECT_NAME\\MATLAB_VER\\$MATLAB_VER\\label\\$NODE_LABELS; cd test; testAll;" & PID=$!

    # follow the log file
    tail -n0 -F --pid=$! output.log 2>/dev/null

    # wait until the background process is done
    wait $PID
fi

CODE=$?
exit $CODE
