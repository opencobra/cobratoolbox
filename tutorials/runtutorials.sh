#!/bin/bash
if [ "$CI_PROJECT_NAME" = "COBRAToolbox-branches-auto" ] || [ "$CI_PROJECT_NAME" = "COBRAToolbox-branches-manual" ];
then
    /mnt/data/MATLAB/$MATLAB_VER/bin/./matlab -nodesktop -nosplash < tutorials/launchTutorials.m
    CODE=$?
    exit $CODE
fi
