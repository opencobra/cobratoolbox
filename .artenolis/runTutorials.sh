#!/bin/bash

COBRATutorialsPath=$(pwd)

buildTutorialList(){
    nTutorial=0
    for d in $(find $COBRATutorialsPath -maxdepth 7 -type d)
    do
        if [[ "${d}" == *additionalTutorials* ]]; then
            continue  # if not a directory, skip
        fi

        # check for MLX files.
        for tutorial in ${d}/*.mlx
        do
            if ! [[ -f "$tutorial" ]]; then
                break
            fi
            let "nTutorial+=1"
            tutorials[$nTutorial]="$tutorial"
            echo " - ${tutorials[$nTutorial]}"
        done
    done
}

buildTutorialList

longest=0
for word in "${tutorials[@]}"
do
    len=${#word}
    if (( len > longest ))
    then
        longest=$len
    fi
done

header=`printf "%-${longest}s    %6s    %6s    %7s\n"  "Name" "passed" "failed" "time(s)"`
report="Tutorial report\n\n"
report+="$header\n"
report+=`printf '=%.0s' $(seq 1 ${#header});`"\n"
failure=0

# Set time format to seconds
TIMEFORMAT=%R

nTutorial=0
nPassed=0
for tutorial in "${tutorials[@]}"
do
    tutorialDir=${tutorial%/*}
    tutorialName=${tutorial##*/}
    tutorialName="${tutorialName%.*}"

    msg="| Starting $tutorialName |"
    chrlen=${#msg}
    underline=`printf '=%.0s' $(seq 1 $chrlen);`
    echo "$underline"
    echo "$msg"
    echo "$underline"

    # Time a process
    SECONDS=0;
    /mnt/prince-data/MATLAB/$MATLAB_VER/bin/./matlab -nodesktop -nosplash -r "addpath([pwd filesep '.ci']);runTutorial('$tutorialName')"
    CODE=$?
    procTime=$SECONDS

    msg="| Done executing $tutorialName! |"
    chrlen=${#msg}
    underline=`printf '=%.0s' $(seq 1 $chrlen);`
    echo "$underline"
    echo "$msg"
    echo "$underline"
    echo
    echo

    if [ $CODE -ne 0 ]; then
        report+=`printf "%-${longest}s                x      %7.1f"  "$tutorial" "$procTime"`
    else
        report+=`printf "%-${longest}s     x                 %7.1f"  "$tutorial" "$procTime"`
        let "nPassed+=1"
    fi
    report+="\n"
    let "nTutorial+=1"
done

report+=`printf "\n  Passed:  %d/%d" "$nPassed" "$nTutorial"`
report+="\n\n"
printf "$report"

if [ $nPassed -ne $nTutorial ]; then
    exit 1
fi
