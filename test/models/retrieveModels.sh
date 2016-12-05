# retrieve models required for testing the CI that are published, but released as part of the COBRA Toolbox
# eventual enhancement with rsync possible

echo "\n >> Downloading and updating models.\n"

# Abiotrophia_defectiva_ATCC_49176
if [ ! -f "Abiotrophia_defectiva_ATCC_49176.xml" ]
then
        wget https://webdav-r3lab.uni.lu/public/msp/AGORA/sbml/Abiotrophia_defectiva_ATCC_49176.xml
else
        echo "Abiotrophia_defectiva_ATCC_49176.xml already exists"
fi

# Ec_iAF1260_flux1
if [ ! -f "Ec_iAF1260_flux1.xml" ]
then
        wget http://systemsbiology.ucsd.edu/sites/default/files/Attachments/Images/InSilicoOrganisms/Ecoli/Ecoli_SBML/msb4100155-s6.zip
        unzip msb4100155-s6.zip
        rm msb4100155-s6.zip
        rm Ec_iAF1260_flux2.txt
        rm read_me.txt
        mv Ec_iAF1260_flux1.txt Ec_iAF1260_flux1.xml
else
        echo "Ec_iAF1260_flux1.xml already exists"
fi

# iIT341
if [ ! -f "iIT341.xml" ]
then
        wget http://bigg.ucsd.edu/static/models/iIT341.xml
else
        echo "iIT341.xml already exists"
fi

# STM_v1.0
if [ ! -f "STM_v1.0.xml" ]
then
        wget https://static-content.springer.com/esm/art%3A10.1186%2F1752-0509-5-8/MediaObjects/12918_2010_598_MOESM2_ESM.ZIP
        unzip 12918_2010_598_MOESM2_ESM.ZIP
        rm 12918_2010_598_MOESM2_ESM.ZIP
else
        echo "STM_v1.0.xml already exists"
fi

echo "\n >> Done downloading and updating models.\n"
