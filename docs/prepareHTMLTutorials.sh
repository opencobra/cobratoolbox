#!/bin/bash
declare -a tutorials=("modelCreation/tutorial_modelCreation.html"
                      "modelManipulation/tutorial_modelManipulation.html"
		      "atomicallyResolveMetabolicReconstruction/tutorial_atomicallyResolveReconstruction.html"
                      "numCharact/tutorial_numCharact.html"
                      "sampling/tutorial_uniformSampling.html"
                      "pathVectorsAndMinimalCutSets/tutorial_pathVectors_minimalCutSets.html"
		      "minSpan/tutorial_minSpan.html"
		      "metabotools/tutorial_I/tutorial_metabotoolsI.html"
		      "metabotools/tutorial_II/tutorial_metabotoolsII.html"
		      "uFBA/tutorial_uFBA.html")

tutorialPath="../tutorials"
tutorialDestination="source/_static/tutorials"
rstDestination="source/tutorials"
mkdir -p "$tutorialDestination"

## now loop through the above array
echo "Preparing tutorial"
echo >> $rstDestination/index.rst
echo >> $rstDestination/index.rst
echo ".. toctree::" >> $rstDestination/index.rst
echo >> $rstDestination/index.rst

for tutorial in "${tutorials[@]}"
do
    tutorialDir=${tutorial%/*}
    tutorialName=${tutorial##*/}
    tutorialName="${tutorialName%.*}"
    tutorialTitle=`awk '/<title>/ { show=1 } show; /<\/title>/ { show=0 }'  $tutorialPath/$tutorialDir/$tutorialName.html | sed -e 's#.*<title>\(.*\)</title>.*#\1#'`

    echo "  - $tutorialTitle"

    foo="${tutorialName:9}"

    tutorialLongTitle="${tutorialName:0:8}${foo^}"
    chrlen=${#tutorialTitle}
    underline=`printf '=%.0s' $(seq 1 $chrlen);`

    sed 's#<html><head>#&<script type="text/javascript" src="../js/iframeResizer.contentWindow.min.js"></script>#' "$tutorialPath/$tutorialDir/$tutorialName.html" > "$tutorialDestination/$tutorialName.html"
    sed "s/#tutorialLongTitle#/$tutorialLongTitle/" "$rstDestination/template.rst" > "$rstDestination/$tutorialLongTitle.rst"
    sed -i.bak "s/#tutorialTitle#/$tutorialTitle/" "$rstDestination/$tutorialLongTitle.rst"
    sed -i.bak "s/#underline#/$underline/" "$rstDestination/$tutorialLongTitle.rst"
    sed -i.bak "s/#tutorialName#/$tutorialName.html/" "$rstDestination/$tutorialLongTitle.rst"
    rm "$rstDestination/$tutorialLongTitle.rst.bak"

    echo "   $tutorialLongTitle" >> $rstDestination/index.rst
done
