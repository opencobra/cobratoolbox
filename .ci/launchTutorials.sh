#!/bin/bash
declare -a tutorials=("tutorial_IO"
                      "tutorial_modelManipulation"
                      "tutorial_modelCreation"
                      "tutorial_numCharact"
                      "tutorial_metabotoolsI"
                      "tutorial_metabotoolsII"
                      "tutorial_uniformSampling")


for tutorial in "${tutorials[@]}"
do

    msg="| Starting $tutorial |"
    chrlen=${#msg}
    underline=`printf '=%.0s' $(seq 1 $chrlen);`
    echo "$underline"
    echo "$msg"
    echo "$underline"

    #/mnt/data/MATLAB/$MATLAB_VER/bin/./
    matlab -nodesktop -nosplash -r "runTutorial('$tutorial')"

    msg="| Done executing $tutorial! |"
    chrlen=${#msg}
    underline=`printf '=%.0s' $(seq 1 $chrlen);`
    echo "$underline"
    echo "$msg"
    echo "$underline"
    echo
    echo
done
