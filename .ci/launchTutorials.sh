#!/bin/bash
declare -a tutorials=("tutorial_IO"
                      "tutorial_modelManipulation"
                      "tutorial_modelCreation"
                      "tutorial_numCharact"
                      "tutorial_metabotoolsI"
                      "tutorial_metabotoolsII"
                      "tutorial_uniformSampling")

report="Tutorial report\n\n"
report+="Name                               passed    failed    time(s)\n"
report+="--------------------------------------------------------------\n"
failure=0

# Set time format to seconds
TIMEFORMAT=%R

for tutorial in "${tutorials[@]}"
do

    msg="| Starting $tutorial |"
    chrlen=${#msg}
    underline=`printf '=%.0s' $(seq 1 $chrlen);`
    echo "$underline"
    echo "$msg"
    echo "$underline"

    #/mnt/data/MATLAB/$MATLAB_VER/bin/./
    # Time a process
    SECONDS=0;
    /mnt/data/MATLAB/$MATLAB_VER/bin/./matlab -nodesktop -nosplash -r "addpath([pwd filesep '.ci']);runTutorial('$tutorial')"
    CODE=$?
    procTime=$SECONDS

    msg="| Done executing $tutorial! |"
    chrlen=${#msg}
    underline=`printf '=%.0s' $(seq 1 $chrlen);`
    echo "$underline"
    echo "$msg"
    echo "$underline"
    echo
    echo

    if [ $CODE -ne 0 ]; then
        report+=`printf "%-32s                x      %7.1f"  "$tutorial" "$procTime"`
        let "failure+=1"
    else
        report+=`printf "%-32s     x                 %7.1f"  "$tutorial" "$procTime"`
    fi
    report+="\n"
done

report+="\n\n"
printf "$report"

if [ $failure -ne 0 ]; then
    exit 1
fi
