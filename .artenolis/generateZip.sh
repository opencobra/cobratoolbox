#!/bin/sh

# script called at the end of a build on a -branches platform,
# generates a .zip file of the working directory,
# and puts it to the webserver.

echo "-- Generation of zip of workspace directory -- "
echo " > Architecture:   $ARCH"
echo " > MATLAB version: $MATLAB_VER"
echo " > Branch:         $GIT_BRANCH"

if [ "$ARCH" = "Linux" ] && [ "$MATLAB_VER" = "R2016b" ] && [ "$GIT_BRANCH" = "origin/master" ]; then

    # make a clean local temporary release directory
    rm -rf /tmp/releaseCT && mkdir /tmp/releaseCT
    echo " > New temporary folder created: /tmp/releaseCT"

    # clone from local repository
    git clone file:///mnt/prince-data/jenkins/workspace/COBRAToolbox-branches-auto-linux/MATLAB_VER/$MATLAB_VER/label/linux /tmp/releaseCT --depth 1
    echo " > Workspace cloned"

    # change to the local temporary release directory
    cd /tmp/releaseCT

    # set the remote URL
    git remote set-url origin https://github.com/opencobra/cobratoolbox.git
    echo " > Remote set"

    # clone submodules
    git submodule update --init --remote --depth 1
    echo " > Submodules cloned"

    # retrieve the SHA1 of the detached head
    lastCommit=$(git rev-parse --short HEAD)
    echo " > Last commit determined as $lastCommit"

    # zip the entire directory
    zip -qr /mnt/prince-data/releases/theCOBRAToolbox-$lastCommit.zip .
    echo " > Workspace zipped"

    # move the zip file to /mnt/isilon-dat/releases
    scp -P 8022 /mnt/prince-data/releases/theCOBRAToolbox-$lastCommit.zip jenkins@prince-server.lcsb.uni.lux:/mnt/isilon-dat/releases
    echo " > .zip file sent to prince-server"

    # update the symbolic link
    ssh -p8022 jenkins@prince-server.lcsb.uni.lux -o TCPKeepAlive=no "cd /mnt/isilon-dat/releases && rm theCOBRAToolbox.zip && ln -s theCOBRAToolbox-$lastCommit.zip theCOBRAToolbox.zip"
    echo " > .zip alias set on prince-server"

    # remove the local zip file
    rm /mnt/prince-data/releases/theCOBRAToolbox-$lastCommit.zip

    # provide an output message
    echo " > Local .zip file removed"
    echo "-- Done. The zip file can be downloaded from https://king.nuigalway.ie/cobratoolbox/releases/theCOBRAToolbox-$lastCommit.zip --"

fi
