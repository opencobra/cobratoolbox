function retrieveModels(printLevel)
% Retrieve models required for testing the CI that are published, but released as part of the COBRA Toolbox
%
% USAGE:
%     retrieveModels(printLevel)
%
% INPUTS:
%     printLevel:   verbose mode (0: mute, 1: default)
%

if nargin < 1
    printLevel = 1;
end

% set the current directory
currentDir = pwd;

% set the model directory and change
MODELDIR = fileparts(which('retrieveModels.m'));
cd(MODELDIR);

if printLevel > 0
    fprintf(['\n   Downloading models to ', strrep(MODELDIR, '\', '\\'), ' ...\n']);
end

% define the array of models to be downloaded (name of the file and URL)
modelArr = {
    'iIT341.xml', 'http://bigg.ucsd.edu/static/models/iIT341.xml';
    'Abiotrophia_defectiva_ATCC_49176.xml', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/sbml/Abiotrophia_defectiva_ATCC_49176.xml';
    'Sc_iND750_flux1.xml', 'http://gcrg.ucsd.edu/sites/default/files/Attachments/Images/InSilicoOrganisms/yeast/Sc_iND750_flux1.xml';
    'ecoli_core_model.mat', 'http://gcrg.ucsd.edu/sites/default/files/Attachments/Images/downloads/Ecoli_core/ecoli_core_model.mat';
    'modelReg.mat','http://gcrg.ucsd.edu/sites/default/files/Attachments/Images/downloads/Ecoli_core/modelReg.mat';
    'iAF1260.mat', 'http://bigg.ucsd.edu/static/models/iAF1260.mat';
    'Abiotrophia_defectiva_ATCC_49176.mat', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/mat/Abiotrophia_defectiva_ATCC_49176.mat';
    'Acidaminococcus_fermentans_DSM_20731.mat', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/mat/Acidaminococcus_fermentans_DSM_20731.mat';
    'Acidaminococcus_intestini_RyC_MR95.mat', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/mat/Acidaminococcus_intestini_RyC_MR95.mat';
    'Acidaminococcus_sp_D21.mat', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/mat/Acidaminococcus_sp_D21.mat';
    'Acinetobacter_calcoaceticus_PHEA_2.mat', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/mat/Acinetobacter_calcoaceticus_PHEA_2.mat';
    };

% download all models
for i = 1:length(modelArr)
    if exist([MODELDIR, filesep, modelArr{i,1}], 'file') ~= 2
        urlwrite(modelArr{i,2}, modelArr{i, 1});
        if printLevel > 0
            fprintf(' + Downloaded:      %s\n', modelArr{i, 1});
        end
    else
        if printLevel > 0
            fprintf(' > Already exists:  %s\n', modelArr{i, 1});
        end
    end
end

% download Ec_iAF1260_flux1.xml
if exist('Ec_iAF1260_flux1.xml', 'file') ~= 2
    urlwrite('http://systemsbiology.ucsd.edu/sites/default/files/Attachments/Images/InSilicoOrganisms/Ecoli/Ecoli_SBML/msb4100155-s6.zip', 'msb4100155-s6.zip');
    system('unzip -qq msb4100155-s6.zip');
    delete('Ec_iAF1260_flux2.txt');
    delete('read_me.txt');
    delete('msb4100155-s6.zip');
    movefile 'Ec_iAF1260_flux1.txt' 'Ec_iAF1260_flux1.xml';
    if printLevel > 0
        fprintf(' + Downloaded:      %s\n', 'Ec_iAF1260_flux1.xml');
    end
else
    if printLevel > 0
        fprintf(' > Already exists:  %s\n', 'Ec_iAF1260_flux1.xml');
    end
end

% download STM_v1.0.xml
if exist('STM_v1.0.xml', 'file') ~= 2
    urlwrite('https://static-content.springer.com/esm/art%3A10.1186%2F1752-0509-5-8/MediaObjects/12918_2010_598_MOESM2_ESM.ZIP', '12918_2010_598_MOESM2_ESM.zip');
    system('unzip -qq 12918_2010_598_MOESM2_ESM.zip');
    delete('12918_2010_598_MOESM2_ESM.zip');
    if printLevel > 0
        fprintf(' + Downloaded:      %s\n', 'STM_v1.0.xml');
    end
else
    if printLevel > 0
        fprintf(' > Already exists:  %s\n', 'STM_v1.0.xml');
    end
end

% print sucess message
fprintf(['   Done downloading models.\n']);

% change back to the root directory
cd(currentDir)

end
