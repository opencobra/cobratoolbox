#!/bin/bash
#usage="$(basename $0) -p=pdfPath -t=COBRATutorialsPath -c=COBRAToolBoxPath [-f=folderNameOfATutorial] [-h] [-l] [-m=mode] -- script to create tutorial documentation #for the COBRA Toolbox.
#
#where:
#    -p  path of the output
#    -c  path of the COBRAToolbox local clone
#    -t  path of the COBRA.tutorials local clone
#    -f  name of a folder of a tutorial
#    -h  show this help text
#    -m  mode (all,html,md,pdf,png,rst)
#    -e  matlab executable path"
MATLAB_ROOT=/usr/local/bin/MATLAB/
MATLAB_VERSION=R2021a
OUTPUT=/home/rfleming/work/sbgCloud/code/doc-COBRA.tutorials
./prepareTutorials.sh  \
	-p=${OUTPUT} \
	-t=~/work/sbgCloud/code/fork-COBRA.tutorials  \
	-c=~/work/sbgCloud/code/fork-cobratoolbox \
	-e=${MATLAB_ROOT}/${MATLAB_VERSION}/bin/matlab \
	-m=pdf
