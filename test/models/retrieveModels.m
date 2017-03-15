% retrieve models required for testing the CI that are published, but released as part of the COBRA Toolbox
% eventual enhancement with rsync possible

pth = which('retrieveModels.m');
MODELDIR = pth(1:end-(length('retrieveModels.m')+1));
cd(MODELDIR);

fprintf('\nDownloading models ...\n');

modelArr = {
    'iIT341.xml', 'http://bigg.ucsd.edu/static/models/iIT341.xml';
    'Abiotrophia_defectiva_ATCC_49176.xml', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/sbml/Abiotrophia_defectiva_ATCC_49176.xml';
    'Sc_iND750_flux1.xml', 'http://gcrg.ucsd.edu/sites/default/files/Attachments/Images/InSilicoOrganisms/yeast/Sc_iND750_flux1.xml';
    'ecoli_core_model.mat', 'http://gcrg.ucsd.edu/sites/default/files/Attachments/Images/downloads/Ecoli_core/ecoli_core_model.mat';
    'modelReg.mat','http://gcrg.ucsd.edu/sites/default/files/Attachments/Images/downloads/Ecoli_core/modelReg.mat';
    'iAF1260.mat', 'http://bigg.ucsd.edu/static/models/iAF1260.mat';
    };

for i = 1:length(modelArr)
    if exist([MODELDIR, filesep, modelArr{i,1}], 'file') ~= 2
        urlwrite(modelArr{i,2}, modelArr{i, 1});
        fprintf('Model %s saved.\n', modelArr{i, 1});
    else
        fprintf('%s %s\n', modelArr{i, 1}, ' already exists.');
    end
end

% Ec_iAF1260_flux1.xml
if exist('Ec_iAF1260_flux1.xml', 'file') ~= 2
    urlwrite('http://systemsbiology.ucsd.edu/sites/default/files/Attachments/Images/InSilicoOrganisms/Ecoli/Ecoli_SBML/msb4100155-s6.zip', 'msb4100155-s6.zip');
    system('unzip -qq msb4100155-s6.zip');
    system('rm Ec_iAF1260_flux2.txt');
    system('rm read_me.txt');
    system('rm msb4100155-s6.zip');
    system('mv Ec_iAF1260_flux1.txt Ec_iAF1260_flux1.xml');
else
    fprintf('%s\n', 'Ec_iAF1260_flux1.xml already exists.');
end

% STM_v1.0.xml
if exist('STM_v1.0.xml', 'file') ~= 2
    urlwrite('https://static-content.springer.com/esm/art%3A10.1186%2F1752-0509-5-8/MediaObjects/12918_2010_598_MOESM2_ESM.ZIP', '12918_2010_598_MOESM2_ESM.zip');
    system('unzip -qq 12918_2010_598_MOESM2_ESM.zip');
    system('rm 12918_2010_598_MOESM2_ESM.zip');
else
    fprintf('%s\n', 'STM_v1.0.xml already exists.');
end

% change back to the root directory
cd('../../')
