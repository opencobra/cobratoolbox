#!/bin/bash
usage="$(basename $0) -p=pdfPath -c=cobraToolBoxPath [-f=folderNameOfATutorial] [-n] [-h] -- script to create tutorial documentation for the COBRA Toolbox.

where:
    -c  path of the COBRA Toolbox
    -p  path of the PDFs
    -f  name of a folder of a tutorial
    -h  show this help text
    -m  mode (rst,md,pdf,png,all)"

echo_time() {
            echo `date +\%Y-\%m-\%d\ \%H:\%M:\%S` " $*"
        }

# default value
mode="all"

for i in "$@"
do
    case $i in
        -c=*)
        cobraToolBoxPath="${i#*=}"
        ;;
        -p=*)
        pdfPath="${i#*=}"
        ;;
        -m)
        mode="${i#*=}"
        ;;
        -f=*)
        tutorialToConvert="${i#*=}"
        ;;
        *)
        echo_time "$usage" # unknown argument
        exit
        ;;
    esac
done

if [[ -z "$pdfPath" ]]; then
    echo_time "> pdfPath is empty"; echo_time; echo_time "$usage"; exit 1;
fi

if [[ -z "$cobraToolBoxPath" ]]; then
    echo_time "> cobraToolBoxPath is empty"; echo_time; echo_time "$usage"; exit 1;
fi

pdfPath="${pdfPath/#\~/$HOME}"
cobraToolBoxPath="${cobraToolBoxPath/#\~/$HOME}"

echo_time "Path to the COBRAToolBox: " $cobraToolBoxPath
echo_time "Path of the PDFs: " $pdfPath

nTutorial=0
declare -a tutorials
if [[ -z "$tutorialToConvert" ]]; then
    for d in $(find $pdfPath -maxdepth 7 -type d)
    do
        if [[ "${d}" == *additionalTutorials* ]]; then
            continue  # if not a directory, skip
        fi

        # we convert PDF to PNG, so check for PDF files.
        for tutorial in ${d}/*.pdf; do
            if ! [[ -f "$tutorial" ]]; then
                break
            fi
            let "nTutorial+=1"
            tutorials[$nTutorial]="$tutorial"
            echo_time " - ${tutorials[$nTutorial]}"
        done
    done
else
    singleTutorial="$pdfPath/$tutorialToConvert/tutorial_$(basename $tutorialToConvert).pdf"
    if [[ -f "$singleTutorial" ]]; then
        let "nTutorial+=1"
        tutorials[$nTutorial]="$singleTutorial"
        echo_time " - ${tutorials[$nTutorial]}"
    else
        echo_time "> the supplied tutorial does not exist: ""$singleTutorial"; echo_time; echo_time "$usage"; exit 1;
    fi

fi


tutorialPath="../tutorials"
tutorialDestination="source/_static/tutorials"
rstPath="source/tutorials"
mkdir -p "$tutorialDestination"

# clean destination folder for the RST and HTML tutorial files
echo_time "Cleaning destination folders for html and rst files"
find "$tutorialDestination" -name "tutorial*.html" -exec rm -f {} \;
find "$rstPath" -name "tutorial*.rst" -exec rm -f {} \;

## now loop through the above array
echo_time "Creating index.rst"
echo >> $rstPath/index.rst
echo >> $rstPath/index.rst
echo ".. toctree::" >> $rstPath/index.rst
echo >> $rstPath/index.rst


# now loop through the above array
echo_time "Creating RST and MD files for tutorial(s):"
for tutorial in "${tutorials[@]}" #"${tutorials[@]}"
do
    tutorialDir=${tutorial%/*}
    tutorialName=${tutorial##*/}
    tutorialName="${tutorialName%.*}"
    if [[ -f "$tutorialDir/$tutorialName.html" ]]; then
        tutorialTitle=`awk '/<title>/ { show=1 } show; /<\/title>/ { show=0 }'  $tutorialDir/$tutorialName.html | sed -e 's#.*<title>\(.*\)</title>.*#\1#'`
    else
        tutorialTitle="tutorialNoName"
    fi
    tutorialFolder=${tutorialDir#$pdfPath/}

    echo_time "  - $tutorialTitle ($tutorialName) $tutorialFolder"

    foo="${tutorialName:9}"
    tutorialLongTitle="${tutorialName:0:8}${foo^}"
    readmePath="$cobraToolBoxPath/tutorials/$tutorialFolder"
    htmlPath="$pdfPath/$tutorialFolder"
    rstPath="$cobraToolBoxPath/docs/source/tutorials" # should be changed later to mimic structure of the src folder.
    pngPath="$pdfPath/$tutorialFolder"

    pdfHyperlink="https://prince.lcsb.uni.lu/jenkins/userContent/tutorials/$tutorialFolder/$tutorialName.pdf"
    pngHyperlink="https://prince.lcsb.uni.lu/jenkins/userContent/tutorials/$tutorialFolder/$tutorialName.png"
    mlxHyperlink="https://github.com/opencobra/cobratoolbox/raw/master/tutorials/$tutorialFolder/$tutorialName.mlx"
    mHyperlink="https://github.com/opencobra/cobratoolbox/raw/master/tutorials/$tutorialFolder/$tutorialName.m"

    if [ $noPng = false ]; then
        if [[ -f $pngPath/${tutorialName}.png ]]; then
            rm $pngPath/${tutorialName}.png
        fi

        /usr/local/bin/convert -density 125 "$tutorial" ${tutorialName}_%04d.png
        /usr/local/bin/convert -shave 4%x5% -append ${tutorialName}*.png ${tutorialName}2.png && rm ${tutorialName}_*.png
        /usr/local/bin/pngquant ${tutorialName}2.png --ext -2.png && mv ${tutorialName}2-2.png $pngPath/${tutorialName}.png && rm ${tutorialName}2.png
    fi


    # create markdowm README
    echo "<p align=\"center\">" > $readmePath/README.md
    echo "    <a href=\"$pdfHyperlink\" title=\"Download PDF file\"><img src=\"https://cdn.rawgit.com/opencobra/cobratoolbox/master/docs/source/_static/images/icon_pdf.png\" height=\"90px\"></a>&nbsp;&nbsp;&nbsp;<a href=\"$mlxHyperlink\" title=\"Download Live Script file\"><img src=\"https://cdn.rawgit.com/opencobra/cobratoolbox/master/docs/source/_static/images/icon_mlx.png\" height=\"90px\"></a>&nbsp;&nbsp;&nbsp;<a href=\"$mHyperlink\" title=\"Download MATLAB file\"><img src=\"https://cdn.rawgit.com/opencobra/cobratoolbox/master/docs/source/_static/images/icon_m.png\" height=\"90px\"></a>&nbsp;&nbsp;&nbsp;<a href=\"https://opencobra.github.io/cobratoolbox/latest/tutorials/index.html\" title=\"Tutorials\"><img src=\"https://cdn.rawgit.com/opencobra/cobratoolbox/master/docs/source/_static/images/icon_tut.png\" height=\"90px\"></a>" >> $readmePath/README.md
    echo "<br><br>" >> $readmePath/README.md
    echo "</p>" >> $readmePath/README.md

    echo "<p align=\"center\">" >> $readmePath/README.md
    echo "  <a href=\"https://github.com/opencobra/cobratoolbox/blob/master/tutorials/$tutorialFolder/README.md\"><img src=\"$pngHyperlink\" width=\"100%\"/></a>" >> $readmePath/README.md
    echo_time "</p>" >> $readmePath/README.md


    # create rst file
    chrlen=${#tutorialTitle}
    underline=`printf '=%.0s' $(seq 1 $chrlen);`
    sed "s/#tutorialLongTitle#/$tutorialLongTitle/g" "$rstPath/template.rst" > "$rstPath/$tutorialLongTitle.rst"
    sed -i.bak "s/#tutorialTitle#/$tutorialTitle/g"  "$rstPath/$tutorialLongTitle.rst"
    sed -i.bak "s/#underline#/$underline/g"          "$rstPath/$tutorialLongTitle.rst"



    sed -i.bak "s~#PDFtutorialPath#~$pdfHyperlink~g" "$rstPath/$tutorialLongTitle.rst"
    sed -i.bak "s~#MLXtutorialPath#~$mlxHyperlink~g" "$rstPath/$tutorialLongTitle.rst"
    sed -i.bak "s~#MtutorialPath#~$mHyperlink~g"     "$rstPath/$tutorialLongTitle.rst"
    sed -i.bak "s~#IFRAMEtutorialPath#~https://github.com/opencobra/cobratoolbox/raw/master/tutorials/$tutorialFolder/$tutorialName.mlx~g" "$rstPath/$tutorialLongTitle.rst"

    rm "$rstPath/$tutorialLongTitle.rst.bak"
    echo "   $tutorialLongTitle" >> $rstPath/index.rst

    # create html file
    sed -i.bak 's#<html><head>#&<script type="text/javascript" src="../js/iframeResizer.contentWindow.min.js"></script>#g' "$htmlPath/$tutorialName.html"
    rm "$htmlPath/$tutorialName.html.bak"
done
