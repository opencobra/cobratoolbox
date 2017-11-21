#!/bin/sh

# script called at the end of a build on a -branches platform,
# generates a .zip file of the working directory,
# and puts it to the webserver.

ARCH="Linux"
MATLAB_VER="R2016b"

if [ "$ARCH" = "Linux" ] && [ "$MATLAB_VER" = "R2016b" ]; then

    # make a local temporary release directory
    mkdir /tmp/releaseCT

    # copy to /tmp directory and remove .git directory
    cp -r /mnt/prince-data/jenkins/workspace/COBRAToolbox-branches-auto-linux/MATLAB_VER/$MATLAB_VER/label/linux/* /tmp/releaseCT/.

    # change to the local temporary release directory
    cd /tmp/releaseCT

    # clean all files that are omitted by gitignore
    git clean -fdX

    # clean all files that are not tracked
    git clean -fd

    # retrieve the SHA1 of the detached head
    lastCommit=$(git rev-parse --short HEAD)

    # remove the .git directory inside of the local temporary release directory
    rm -rf /tmp/releaseCT/.git

    # change to the local temporary release directory
    cd /tmp/releaseCT

    # zip the entire directory
    zip -r /mnt/prince-data/releases/the_COBRA_Toolbox-$lastCommit.zip .

    # move the zip file to /mnt/isilon-dat/releases
    scp -P 8022 /mnt/prince-data/releases/the_COBRA_Toolbox-$lastCommit.zip jenkins@prince-server.lcsb.uni.lux:/mnt/isilon-dat/releases

    # remove temporary directory
    rm -rf /tmp/releaseCT

    # remove the local zip file
    rm /mnt/prince-data/releases/the_COBRA_Toolbox-$lastCommit.zip

fi