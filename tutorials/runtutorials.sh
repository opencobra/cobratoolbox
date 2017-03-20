#!/bin/sh
/mnt/data/MATLAB/$MATLAB_VER/bin/./matlab -nodesktop -nosplash < tutorials/launchTutorials.m
CODE=$?
exit $CODE
