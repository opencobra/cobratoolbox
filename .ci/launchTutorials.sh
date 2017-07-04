#!/bin/bash
declare -a tutorials=("tutorial_COBRAconcepts"
                      "tutorial_FBA"
                      "tutorial_FVA"
                      "tutorial_IO"
                      "tutorial_SOP"
                      "tutorial_atomicallyResolveReconstruction"
                      "tutorial_cellDesigner"
                      "tutorial_constrainingModels"
                      "tutorial_extraction_transcriptomic"
                      "tutorial_minSpan"
                      "tutorial_minimalCutSets"
                      "tutorial_modelATPYield"
                      "tutorial_modelCreation"
                      "tutorial_modelManipulation"
                      "tutorial_modelProperties"
                      "tutorial_remoteVisualisation"
                      "tutorial_numCharact"
                      "tutorial_optForce"
                      "tutorial_optForceGAMS"
                      "tutorial_optGene"
                      "tutorial_optKnock"
                      "tutorial_pFBA"
                      "tutorial_pathVectors"
                      "tutorial_rBioNet"
                      "tutorial_relaxFBA"
                      "tutorial_remoteVisualisation"
                      "tutorial_robustness_PhPP"
                      "tutorial_sparseFBA"
                      "tutorial_uFBA"
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
