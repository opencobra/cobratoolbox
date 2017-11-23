#!/bin/sh

# script called at the end of a build on a -branches platform,
# generates a .zip file of the working directory,
# and puts it to the webserver.

echo "-- Generation of zip of workspace directory -- "
echo " > Architecture:   $ARCH"
echo " > MATLAB version: $MATLAB_VER"
echo " > Branch:         $GIT_BRANCH"

if [ "$ARCH" = "Linux" ] && [ "$MATLAB_VER" = "R2016b" ] && [ "$GIT_BRANCH" = "master"]; then

    # make a clean local temporary release directory
    rm -rf /tmp/releaseCT && mkdir /tmp/releaseCT
    echo " > Temporary folder created: /tmp/releaseCT"

    # clone from local repository
    git clone file:///mnt/prince-data/jenkins/workspace/COBRAToolbox-branches-auto-linux/MATLAB_VER/$MATLAB_VER/label/linux /tmp/releaseCT --depth 1
    echo " > Workspace cloned"

    # change to the local temporary release directory
    cd /tmp/releaseCT

    # clean all files that are omitted by gitignore
    git clean -fdX

    # clean all files that are not tracked
    git clean -fd
    echo " > git repo cleaned"

    # retrieve the SHA1 of the detached head
    lastCommit=$(git rev-parse --short HEAD)
    echo " > Last commit determined as $lastCommit"

    # remove the .git directory inside of the local temporary release directory
    rm -rf /tmp/releaseCT/.git
    echo " > .git folder removed"

    # change to the local temporary release directory
    cd /tmp/releaseCT

    # zip the entire directory
    zip -qr /mnt/prince-data/releases/the_COBRA_Toolbox-$lastCommit.zip .
    echo " > Workspace zipped"

    # move the zip file to /mnt/isilon-dat/releases
    scp -P 8022 /mnt/prince-data/releases/the_COBRA_Toolbox-$lastCommit.zip jenkins@prince-server.lcsb.uni.lux:/mnt/isilon-dat/releases
    echo " > .zip file sent to prince-server"

    # remove temporary directory
    rm -rf /tmp/releaseCT
    echo " > Temporary folder removed"

    # remove the local zip file
    rm /mnt/prince-data/releases/the_COBRA_Toolbox-$lastCommit.zip

    # provide an output message
    echo " > Local .zip file removed"
    echo "-- Done. The zip file can be downloaded from https://prince.lcsb.uni.lu/releases/the_COBRA_Toolbox-$lastCommit.zip --"

fi