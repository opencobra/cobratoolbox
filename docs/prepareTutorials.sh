#!/usr/local/bin/bash
usage="$(basename $0) -p=pdfPath -t=COBRATutorialsPath -c=COBRAToolBoxPath [-f=folderNameOfATutorial] [-h] [-l] [-m=mode] -- script to create tutorial documentation for the COBRA Toolbox.

where:
    -p  path of the PDFs
    -c  path of the COBRAToolbox local clone
    -t  path of the COBRA.tutorials local clone
    -f  name of a folder of a tutorial
    -h  show this help text
    -m  mode (all,html,md,pdf,png,rst)
    -e  matlab executable path"

echo_time() {
            echo `date +\%Y-\%m-\%d\ \%H:\%M:\%S` " $*"
        }

declare -A subs
subs[analysis]="Analysis"
subs[base]="Base"
subs[dataIntegration]="Data integration"
subs[design]="Design"
subs[reconstruction]="Reconstruction"
subs[visualization]="Visualization"


buildTutorialList(){
    nTutorial=0
    if [[ -z "$specificTutorial" ]]; then
        for d in $(find $COBRATutorialsPath -maxdepth 7 -type d)
        do
            if [[ "${d}" == *additionalTutorials* ]]; then
                continue  # if not a directory, skip
            fi

            if [[ "${d}" == *template* ]]; then
                continue  # if the directory is the template directory, skip
            fi

            # check for MLX files.
            for tutorial in ${d}/*.mlx
            do
                if ! [[ -f "$tutorial" ]]; then
                    break
                fi
                let "nTutorial+=1"
                tutorials[$nTutorial]="$tutorial"
                echo_time " - ${tutorials[$nTutorial]}"
            done
        done
    else
        for d in $(find $COBRATutorialsPath -maxdepth 7 -type d)
        do
            if [[ "${d}" == *"$(basename $specificTutorial)"* ]]; then
                singleTutorial="$d/tutorial_$(basename $specificTutorial).mlx"

                if [[ -f "$singleTutorial" ]]; then
                    let "nTutorial+=1"
                    tutorials[$nTutorial]="$singleTutorial"
                    echo_time " - ${tutorials[$nTutorial]}"
                else
                    echo_time "> the supplied tutorial does not exist: ""$singleTutorial";
                fi
            fi
        done
    fi

    if [[ nTutorial == 0 ]]; then
        echo_time;
        echo_time "List of tutorial is empty."
        echo_time "$usage"; exit 1;
    fi

    # sort tutorial by ascending alphabetical order
    IFS=$'\n'
    tutorials=($(sort <<<"${tutorials[*]}"))
    unset IFS
}

createLocalVariables(){
    tutorial=$1
    tutorialDir=${tutorial%/*}
    tutorialName=${tutorial##*/}
    tutorialName="${tutorialName%.*}"
    tutorialFolder=${tutorialDir#$COBRATutorialsPath/}
    if [[ -f "$pdfPath/tutorials/$tutorialFolder/$tutorialName.html" ]]; then
        tutorialTitle=`awk '/<title>/ { show=1 } show; /<\/title>/ { show=0 }' $pdfPath/tutorials/$tutorialFolder/$tutorialName.html | sed -e 's#.*<title>\(.*\)</title>.*#\1#'`
    else
        tutorialTitle="tutorialNoName"
    fi

    foo="${tutorialName:9}"
    tutorialLongTitle="${tutorialName:0:8}${foo^}"
    readmePath="$COBRATutorialsPath/$tutorialFolder"
    htmlPath="$COBRAToolboxPath/docs/source/_static/tutorials"
    rstPath="$COBRAToolboxPath/docs/source/tutorials" # should be changed later to mimic structure of the src folder.
    pngPath="$pdfPath/tutorials/$tutorialFolder"

    pdfHyperlink="https://prince.lcsb.uni.lu/cobratoolbox/tutorials/$tutorialFolder/$tutorialName.pdf"
    pngHyperlink="https://prince.lcsb.uni.lu/cobratoolbox/tutorials/$tutorialFolder/$tutorialName.png"
    htmlHyperlink="https://prince.lcsb.uni.lu/cobratoolbox/tutorials/$tutorialFolder/iframe_$tutorialName.html"
    mlxHyperlink="https://github.com/opencobra/COBRA.tutorials/raw/master/$tutorialFolder/$tutorialName.mlx"
    mHyperlink="https://github.com/opencobra/COBRA.tutorials/raw/master/$tutorialFolder/$tutorialName.m"
    dirHyperlink="https://github.com/opencobra/COBRA.tutorials/tree/master/$tutorialFolder"

    previousSection=""
    if [[ -n $section ]]; then
        previousSection=$section
    fi

    section=${tutorialFolder%%/*}

    echo_time "  - $tutorialTitle ($tutorialName) $tutorialFolder - $section ($previousSection)"
}

buildHTMLTutorials(){
    $matlab -nodesktop -nosplash -r "restoredefaultpath;initCobraToolbox;addpath('.artenolis');generateTutorials('$pdfPath');restoredefaultpath;savepath;exit;"
    for tutorial in "${tutorials[@]}" #"${tutorials[@]}"
    do
        createLocalVariables $tutorial
        # create PDF file
        /usr/local/bin/wkhtmltopdf --page-size A8 --margin-right 2 --margin-bottom 3 --margin-top 3 --margin-left 2 $pdfPath/tutorials/$tutorialFolder/$tutorialName.html $pdfPath/tutorials/$tutorialFolder/$tutorialName.pdf
        sed 's#<html><head>#&<script type="text/javascript" src="https://cdn.jsdelivr.net/gh/opencobra/cobratoolbox@ffa0229fc0c01c9236bb7e961f65712443277719/latest/_static/js/iframeResizer.contentWindow.min.js"></script>#g' "$pdfPath/tutorials/$tutorialFolder/$tutorialName.html" > "$pdfPath/tutorials/$tutorialFolder/iframe_$tutorialName.html"
        sed -i.bak 's/white-space:\ pre-wrap/white-space:\ normal/g' "$pdfPath/tutorials/$tutorialFolder/iframe_$tutorialName.html"
        sed -i.bak 's/white-space:\ pre/white-space:\ normal/g' "$pdfPath/tutorials/$tutorialFolder/iframe_$tutorialName.html"
        rm "$pdfPath/tutorials/$tutorialFolder/iframe_$tutorialName.html.bak"
    done
}

buildHTMLSpecificTutorial(){
    specificTutorial=$1
    $matlab -nodesktop -nosplash -r "restoredefaultpath;initCobraToolbox;addpath('.artenolis');generateTutorials('$pdfPath', '$specificTutorial');restoredefaultpath;savepath;exit;"
    createLocalVariables $specificTutorial
    # create PDF file
    /usr/local/bin/wkhtmltopdf --page-size A8 --margin-right 2 --margin-bottom 3 --margin-top 3 --margin-left 2 $pdfPath/tutorials/$tutorialFolder/$tutorialName.html $pdfPath/tutorials/$tutorialFolder/$tutorialName.pdf
    sed 's#<html><head>#&<script type="text/javascript" src="https://cdn.jsdelivr.net/gh/opencobra/cobratoolbox@ffa0229fc0c01c9236bb7e961f65712443277719/latest/_static/js/iframeResizer.contentWindow.min.js"></script>#g' "$pdfPath/tutorials/$tutorialFolder/$tutorialName.html" > "$pdfPath/tutorials/$tutorialFolder/iframe_$tutorialName.html"
    sed -i.bak 's/white-space:\ pre-wrap/white-space:\ normal/g' "$pdfPath/tutorials/$tutorialFolder/iframe_$tutorialName.html"
    sed -i.bak 's/white-space:\ pre/white-space:\ normal/g' "$pdfPath/tutorials/$tutorialFolder/iframe_$tutorialName.html"
    rm "$pdfPath/tutorials/$tutorialFolder/iframe_$tutorialName.html.bak"

}

# default vallues
mode="all"
buildHTML=false
buildPDF=false
buildRST=false
buildMD=false
buildPNG=false
matlab=/Applications/MATLAB_R2016b.app/bin/matlab

for i in "$@"
do
    case $i in
        -c=*)
        COBRAToolboxPath="${i#*=}"
        ;;
        -p=*)
        pdfPath="${i#*=}"
        ;;
        -m=*)
        mode="${i#*=}"
        ;;
        -f=*)
        specificTutorial="${i#*=}"
        ;;
        -t=*)
        COBRATutorialsPath="${i#*=}"
        ;;
        -e=*)
        matlab="${i#*=}"
        ;;
        *)
        echo_time "$usage" # unknown argument
        exit
        ;;
    esac
done

mode=${mode,,} # lowercase the mode

# input checking
if [[ -z "$COBRAToolboxPath" ]]; then
    echo_time "> COBRAToolboxPath is empty"; echo_time; echo_time "$usage"; exit 1;
fi

if [[ -z "$COBRATutorialsPath" ]]; then
    echo_time "> COBRATutorialsPath is empty"; echo_time; echo_time "$usage"; exit 1;
fi

if [[ -z "$pdfPath" ]]; then
    echo_time "> pdfPath is empty"; echo_time; echo_time "$usage"; exit 1;
fi

if [[ $mode = *"all"* ]]; then
    buildPDF=true
    buildHTML=true
    buildRST=true
    buildMD=true
    buildPNG=true
fi
if [[ $mode = *"pdf"* ]] || [[ $mode = *"html"* ]]; then
    buildPDF=true
    buildHTML=true
fi
if [[ $mode = *"rst"* ]]; then
    buildRST=true
fi
if [[ $mode = *"md"* ]]; then
    buildMD=true
fi
if [[ $mode = *"png"* ]]; then
    buildPNG=true
fi

pdfPath="${pdfPath/#\~/$HOME}"
COBRATutorialsPath="${COBRATutorialsPath/#\~/$HOME}"
COBRAToolboxPath="${COBRAToolboxPath/#\~/$HOME}"

echo_time "Path to the COBRAToolBox: " $COBRAToolboxPath
echo_time "Path to the COBRA.Tutorials: " $COBRATutorialsPath
echo_time "Path of the generated files: " $pdfPath
echo_time
echo_time "Building: PDF:$buildPDF, HTML:$buildHTML, RST:$buildRST, MD:$buildMD, PNG:$buildPNG"

# check if the triggering file is present
if ! [[ -z "$triggeringFile" ]]; then
    if ! [[ -f "$triggeringFile" ]]; then
        echo_time
        echo_time " > triggering file ($triggeringFile) is not present: build aborted";
        exit;
    else
        rm "$triggeringFile"
    fi
fi

# build list of tutorial if parameter '-f' is not set.
buildTutorialList

# gather tutorial long names.
nTutorial=0
for tutorial in "${tutorials[@]}" #"${tutorials[@]}"
do
    createLocalVariables $tutorial
    let "nTutorial+=1"
    tutorialLongNames[$nTutorial]="$tutorial $section $tutorialTitle"
done
# printf '%s\n' "${tutorialLongNames[@]}"

# sort tutorial by ascending alphabetical order of section and then name.
IFS=$'\n'
tutorials=($(sort -f -k2 -k3 <<<"${tutorialLongNames[*]}" | awk  '{print $1}'))
unset IFS
# printf '%s\n' "${tutorialLongNames[@]}"

# gather section names
IFS=$'\n'
sections=($(sort -f -k2 <<<"${tutorialLongNames[*]}" | awk  '{print $2}' | sort -u))
unset IFS
# printf '%s\n' "${sections[@]}"

tutorialPath="../tutorials"
rstPath="$COBRAToolboxPath/docs/source/tutorials"
mkdir -p "$tutorialDestination"

if [[ $buildHTML = true ]]; then
    cd $COBRAToolboxPath
    if [[ -z "$specificTutorial" ]]; then
        buildHTMLTutorials;
    else
        buildHTMLSpecificTutorial "$specificTutorial";
    fi
fi

# now loop through the above array
if [ $buildPNG = true ] || [ $buildMD = true ] || [ $buildRST = true ]; then

    # clean destination folder for the RST and HTML tutorial files
    if [ $buildRST = true ]; then
        echo_time "Creating $rstPath/index.rst"
        echo >> $rstPath/index.rst
        echo >> $rstPath/index.rst
        echo ".. raw:: html" >> $rstPath/index.rst
        echo >> $rstPath/index.rst
        echo "   <style>h2 {font-size:0px;}</style>" >> $rstPath/index.rst
        echo >> $rstPath/index.rst

        echo_time "Cleaning destination folders for rst files"
        find "$rstPath" -name "tutorial*.rst" -exec rm -f {} \;
    fi

    echo_time "Creating requested files for tutorial(s):"
    echo  ${tutorials[@]}
    firstSection=true
    for tutorial in "${tutorials[@]}" #"${tutorials[@]}"
    do
        createLocalVariables $tutorial

        if [ $buildPNG = true ]; then
            mkdir -p $pngPath
            if [[ -f $pngPath/${tutorialName}.png ]]; then
                rm $pngPath/${tutorialName}.png
            fi

            echo $pdfPath/tutorials/$tutorialFolder/$tutorialName.pdf
            export PATH=/usr/local/bin:$PATH;

            # change directory for the generation of PNGs
            cd $pngPath

            /usr/local/bin/convert -density 768 "$pdfPath/tutorials/$tutorialFolder/$tutorialName.pdf" ${tutorialName}_%04d.png
            /usr/local/bin/convert -shave 4%x5% -append ${tutorialName}*.png ${tutorialName}.png && rm ${tutorialName}_*.png
            #/usr/local/bin/pngquant ${tutorialName}2.png --ext -2.png && mv ${tutorialName}2-2.png $pngPath/${tutorialName}.png && rm ${tutorialName}2.png
            echo " >> $tutorialName.png generated in $pngPath \n"
        fi

        # create markdown README
        if [ $buildMD = true ]; then
            echo $readmePath
            mkdir -p $readmePath
            echo "<p align=\"center\">" > $readmePath/README.md
            echo "    <a href=\"$pdfHyperlink\" title=\"Download PDF file\" target=\"_blank\"><img src=\"https://prince.lcsb.uni.lu/cobratoolbox/img/icon_pdf.png\" height=\"90px\" alt=\"pdf\"></a>&nbsp;&nbsp;&nbsp;<a href=\"$mlxHyperlink\" title=\"Download Live Script file\" target=\"_blank\"><img src=\"https://prince.lcsb.uni.lu/cobratoolbox/img/icon_mlx.png\" height=\"90px\" alt=\"MLX\"></a>&nbsp;&nbsp;&nbsp;<a href=\"$mHyperlink\" title=\"Download MATLAB file\" target=\"_blank\"><img src=\"https://prince.lcsb.uni.lu/cobratoolbox/img/icon_m.png\" height=\"90px\" alt=\"M file\"></a>&nbsp;&nbsp;&nbsp;<a href=\"$dirHyperlink\" title=\"View on Github\" target=\"_blank\"><img src=\"https://prince.lcsb.uni.lu/cobratoolbox/img/icon_view.png\" height=\"90px\" alt=\"view\"></a><a href=\"https://opencobra.github.io/cobratoolbox/latest/tutorials/index.html\" title=\"Tutorials\"><img src=\"https://prince.lcsb.uni.lu/cobratoolbox/img/icon_tut.png\" height=\"90px\" alt=\"tutorials\"></a>" >> $readmePath/README.md
            echo "<br><br>" >> $readmePath/README.md
            echo "</p>" >> $readmePath/README.md

            echo "<p align=\"center\">" >> $readmePath/README.md
            echo "  <a href=\"https://github.com/opencobra/COBRA.tutorials/blob/master/$tutorialFolder/README.md\"><img src=\"$pngHyperlink\" width=\"100%\"/></a>" >> $readmePath/README.md
            echo "</p>" >> $readmePath/README.md
        fi

        # create rst file
        if [ $buildRST = true ]; then
            mkdir -p $rstPath
            chrlen=${#tutorialTitle}
            underline=`printf '=%.0s' $(seq 1 $chrlen);`
            sed "s/#tutorialLongTitle#/$tutorialLongTitle/g" "$rstPath/template.rst" > "$rstPath/$tutorialLongTitle.rst"
            sed -i.bak "s/#tutorialTitle#/$tutorialTitle/g"  "$rstPath/$tutorialLongTitle.rst"
            sed -i.bak "s/#underline#/$underline/g"          "$rstPath/$tutorialLongTitle.rst"
            sed -i.bak "s~#PDFtutorialPath#~$pdfHyperlink~g" "$rstPath/$tutorialLongTitle.rst"
            sed -i.bak "s~#MLXtutorialPath#~$mlxHyperlink~g" "$rstPath/$tutorialLongTitle.rst"
            sed -i.bak "s~#MtutorialPath#~$mHyperlink~g"     "$rstPath/$tutorialLongTitle.rst"
            sed -i.bak "s~#DIRtutorialPath#~$dirHyperlink~g"   "$rstPath/$tutorialLongTitle.rst"
            sed -i.bak "s~#IFRAMEtutorialPath#~$htmlHyperlink~g" "$rstPath/$tutorialLongTitle.rst"

            rm "$rstPath/$tutorialLongTitle.rst.bak"
            # Create sections for tutorials
            if ! [[ $previousSection = $section ]]; then
                if [ $firstSection = false ]; then
                    echo >> $rstPath/index.rst
                    echo ".. raw:: html" >> $rstPath/index.rst
                    echo >> $rstPath/index.rst
                    echo "   <br>" >> $rstPath/index.rst
                    echo "   </div>" >> $rstPath/index.rst
                    echo "   </div>" >> $rstPath/index.rst
                    echo "" >> $rstPath/index.rst
                    echo "" >> $rstPath/index.rst
                fi

                chrlen=${#section}
                underline=`printf -- '-%.0s' $(seq 1 $chrlen);`

                echo "${subs[$section]}" >> $rstPath/index.rst
                echo "$underline" >> $rstPath/index.rst
                echo "" >> $rstPath/index.rst
                echo "" >> $rstPath/index.rst

                echo ".. raw:: html" >> $rstPath/index.rst
                echo "" >> $rstPath/index.rst
                echo "   <div class=\"tutorialSectionBox $section\">" >> $rstPath/index.rst
                echo "     <div class=\"sectionLogo\"><img class=\"avatar\" src=\"https://prince.lcsb.uni.lu/cobratoolbox/img/icon_${section}_wb.png\" alt=\"$section\"></div>" >> $rstPath/index.rst
                echo "     <div class=\"sectionTitle\"><h3>${subs[$section]}<a class=\"headerlink\" href=\"#$section\" title=\"Permalink to this headline\">¶</a></h3></div>" >> $rstPath/index.rst
                echo "     <div class=\"sectionContent\">" >> $rstPath/index.rst
                echo >> $rstPath/index.rst

                firstSection=false
            fi
            echo "* :doc:\`$tutorialLongTitle\`" >> $rstPath/index.rst
        fi
    done
    echo >> $rstPath/index.rst
    echo ".. raw:: html" >> $rstPath/index.rst
    echo >> $rstPath/index.rst
    echo "     </div>" >> $rstPath/index.rst
    echo "   </div>" >> $rstPath/index.rst
    echo "   <br>" >> $rstPath/index.rst
    echo >> $rstPath/index.rst

fi


