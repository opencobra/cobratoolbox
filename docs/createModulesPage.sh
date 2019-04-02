declare -a sections=(analysis base dataIntegration design reconstruction visualization)

declare -A subs
subs[analysis]="Analysis"
subs[base]="Base"
subs[dataIntegration]="Data integration"
subs[design]="Design"
subs[reconstruction]="Reconstruction"
subs[visualization]="Visualization"


rstFunctionPath="source/modules/index.rst"
echo ".. _modules_functions:" > $rstFunctionPath
echo "" >> $rstFunctionPath
echo "Functions" >> $rstFunctionPath
echo "=========" >> $rstFunctionPath
echo "" >> $rstFunctionPath
echo ".. raw:: html" >> $rstFunctionPath
echo "" >> $rstFunctionPath
echo "   <script src=\"../_static/js/json-menu.js\"></script>" >> $rstFunctionPath
echo "   <style>" >> $rstFunctionPath
echo "     h2 {font-size:0px;}" >> $rstFunctionPath
echo "   </style>" >> $rstFunctionPath
echo "" >> $rstFunctionPath
echo "" >> $rstFunctionPath


for section in "${sections[@]}" #"${tutorials[@]}"
do

    echo ".. raw:: html" >> $rstFunctionPath
    echo "" >> $rstFunctionPath
    echo "   <div class=\"tutorialSectionBox $section\">" >> $rstFunctionPath
    echo "     <div class=\"sectionLogo\"><img class=\"avatar\" src=\"https://prince.lcsb.uni.lu/cobratoolbox/img/icon_${section}_wb.png\"></div>" >> $rstFunctionPath
    echo "     <div class=\"sectionTitle\"><h3>${subs[$section]}</h3></div>" >> $rstFunctionPath
    echo "     <div class=\"row\">" >> $rstFunctionPath
    echo "       <div class=\"col-xs-6\">" >> $rstFunctionPath
    echo "         <div class=\"sectionContent\">" >> $rstFunctionPath
    echo "" >> $rstFunctionPath
    echo ".. toctree::" >> $rstFunctionPath
    echo "   :glob:" >> $rstFunctionPath
    echo "   :maxdepth: 2" >> $rstFunctionPath
    echo "" >> $rstFunctionPath
    echo "   $section/*" >> $rstFunctionPath
    echo "" >> $rstFunctionPath
    echo "" >> $rstFunctionPath
    echo ".. raw:: html" >> $rstFunctionPath
    echo "" >> $rstFunctionPath
    echo "         </div>" >> $rstFunctionPath
    echo "       </div>" >> $rstFunctionPath
    echo "       <div class=\"col-xs-6\">" >> $rstFunctionPath
    echo "         <div class=\"dropdown dropdown-cobra\">" >> $rstFunctionPath
    echo "           <a href=\"\" class=\"btn btn-default dropdown-toggle\" data-toggle=\"dropdown\" style=\"width: 100%;\">" >> $rstFunctionPath
    echo "             Function list" >> $rstFunctionPath
    echo "             <b class=\"caret\"></b>" >> $rstFunctionPath
    echo "           </a>" >> $rstFunctionPath
    echo "           <ul class=\"dropdown-menu $section-menu dropdown-scrollable\">" >> $rstFunctionPath
    echo "           </ul>" >> $rstFunctionPath
    echo "         </div>" >> $rstFunctionPath
    echo "         <script> buildList(\"${section}functions.json\", \"$section\") </script>" >> $rstFunctionPath
    echo "       </div>" >> $rstFunctionPath
    echo "     </div>" >> $rstFunctionPath
    echo "   </div>" >> $rstFunctionPath
    echo "   <br>" >> $rstFunctionPath
    echo "" >> $rstFunctionPath
    echo "" >> $rstFunctionPath
done

echo ".. raw:: html" >> $rstFunctionPath
echo "" >> $rstFunctionPath
echo "   <br>" >> $rstFunctionPath

