function retrieveModels(printLevel)
% Retrieve models required for testing the CI that are published, but released as part of the COBRA Toolbox
%
% USAGE:
%     retrieveModels(printLevel)
%
% INPUT:
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
    'AntCore.mat', 'https://raw.github.com/snmendoz/Models/master/AntCore.mat';
    'iIT341.xml', 'http://bigg.ucsd.edu/static/models/iIT341.xml';
    'Abiotrophia_defectiva_ATCC_49176.xml', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/sbml/Abiotrophia_defectiva_ATCC_49176.xml';
    'Sc_iND750_flux1.xml', 'http://gcrg.ucsd.edu/sites/default/files/Attachments/Images/InSilicoOrganisms/yeast/Sc_iND750_flux1.xml';
    'ecoli_core_model.mat', 'http://gcrg.ucsd.edu/sites/default/files/Attachments/Images/downloads/Ecoli_core/ecoli_core_model.mat';
    'modelReg.mat','http://gcrg.ucsd.edu/sites/default/files/Attachments/Images/downloads/Ecoli_core/modelReg.mat';
    'iAF1260.mat', 'http://bigg.ucsd.edu/static/models/iAF1260.mat';
    'iJO1366.mat', 'http://bigg.ucsd.edu/static/models/iJO1366.mat';
    'Abiotrophia_defectiva_ATCC_49176.mat', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/mat/Abiotrophia_defectiva_ATCC_49176.mat';
    'Acidaminococcus_fermentans_DSM_20731.mat', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/mat/Acidaminococcus_fermentans_DSM_20731.mat';
    'Acidaminococcus_intestini_RyC_MR95.mat', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/mat/Acidaminococcus_intestini_RyC_MR95.mat';
    'Acidaminococcus_sp_D21.mat', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/mat/Acidaminococcus_sp_D21.mat';
    'Acinetobacter_calcoaceticus_PHEA_2.mat', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/mat/Acinetobacter_calcoaceticus_PHEA_2.mat';
    'Recon1.0model.mat', 'https://raw.github.com/cobrabot/COBRA.models/master/Recon1.0model.mat';
    'Recon2.0model.mat', 'https://raw.github.com/cobrabot/COBRA.models/master/Recon2.0model.mat';
    };

% define silence level of curl
if printLevel == 0
    curlSilence = '-s';
else
    curlSilence = '';
end

% download all models
for i = 1:length(modelArr)
    if exist([MODELDIR, filesep, modelArr{i,1}], 'file') ~= 2
        % check if the remote URL can be reached
        [status_curl, result_curl] = system(['curl --max-time 15 -s -k -L --head ', modelArr{i, 2}]);

        % check if the URL exists
        if status_curl == 0 && ~isempty(strfind(result_curl, ' 200'))
            status_curlDownload = system(['curl ', curlSilence, ' --max-time 60 -O -L ', modelArr{i, 2}]);

            if printLevel > 0 && status_curlDownload == 0
                fprintf(' + Downloaded:      %s\n', modelArr{i, 2});
            end
        else
            fprintf(' > The URL %s cannot be reached.\n', modelArr{i, 2});
        end
    else
        if printLevel > 0
            fprintf(' > Already exists:  %s\n', modelArr{i, 1});
        end
    end
end

% download Ec_iAF1260_flux1.xml
downloadModelZipFile('Ec_iAF1260_flux1.xml', 'http://systemsbiology.ucsd.edu/sites/default/files/Attachments/Images/InSilicoOrganisms/Ecoli/Ecoli_SBML/msb4100155-s6.zip', ...
                     'fileToBeRenamed', 'Ec_iAF1260_flux1.txt', ...
                     'deleteExtraFiles', {'Ec_iAF1260_flux2.txt', 'read_me.txt'}, ...
                     'printLevel', printLevel)

% download STM_v1.0.xml
downloadModelZipFile('STM_v1.0.xml', 'https://static-content.springer.com/esm/art%3A10.1186%2F1752-0509-5-8/MediaObjects/12918_2010_598_MOESM2_ESM.ZIP', ...
                     'printLevel', printLevel)

% download GlcAer_WT.mat
downloadModelZipFile('ME_matrix_GlcAer_WT.mat', 'https://wwwen.uni.lu/content/download/72953/917521/file/download.zip', ...
                     'printLevel', printLevel)

% download Recon2.v04.mat
downloadModelZipFile('Recon2.v04.mat', 'https://vmh.uni.lu/files/Recon2.v04.mat_.zip', ...
                     'printLevel', printLevel)

% download Human cardiac myocyte mitochondrial metabolic reconstruction
downloadModelZipFile('cardiac_mit_glcuptake_atpmax.mat', 'https://wwwen.uni.lu/content/download/72949/917505/file/Human%20cardiac%20myocyte%20mitochondrial%20metabolic%20reconstruction_cardiac_mit_glcuptake_atpmax.mat.zip', ...
                     'printLevel', printLevel)

% print sucess message
if printLevel > 0
    fprintf(['   Done downloading models.\n']);
end

% change back to the root directory
cd(currentDir)

end


function downloadModelZipFile(filename, url, varargin)
% Downloads model file stored inside a .zip file
%
% USAGE:
%     downloadModelZipFile(filename, url)
%
% INPUTS:
%     filename:          name of the .mat file contained in the .zip file.
%     url:               url where to download the .zip file.
%
% OPTIONAL INPUTS:
%     fileToBeRenamed:   name of the file in the .zip file to be renamed as `filename`.
%     deleteExtraFiles:  filenames from the .zip file that need to be deleted after extraction.
%     printLevel:        print level

    fileToBeRenamed = [];
    deleteExtraFiles = [];
    printLevel = 0;

    %% varargin checking
    if numel(varargin) > 1
        for i = 1:2:numel(varargin)
            key = varargin{i};
            value = varargin{i + 1};
            switch key
                case 'fileToBeRenamed'
                    fileToBeRenamed = value;
                case 'deleteExtraFiles'
                    deleteExtraFiles = value;
                case 'printLevel'
                    printLevel = value;
                otherwise
                    msg = sprintf('Unexpected key %s', key)
                    error(msg);
            end
        end
    end

    if exist([pwd filesep filename], 'file') ~= 2
        % define silence level of curl
        if printLevel == 0
            curlSilence = '-s';
        else
            curlSilence = '';
        end
        % check if the remote URL can be reached
        [status_curl, result_curl] = system(['curl --max-time 15 -s -k --head ', url]);

        % check if the URL exists
        if status_curl == 0 && ~isempty(strfind(result_curl, ' 200'))
            status_curlDownload = system(['curl ', curlSilence, ' --max-time 60 -O ', url]);
            [~, zipName, ext] = fileparts(url);
            zipName = [zipName, ext];
            unzip(zipName);
            % delete extra files
            for i = 1:length(deleteExtraFiles)
                delete(deleteExtraFiles{i});
            end

            % rename unzipped file if necessary
            if ~isempty(fileToBeRenamed)
                movefile(fileToBeRenamed, filename);
            end
            delete(zipName);

            if exist('__MACOSX', 'dir') == 7
                rmdir('__MACOSX', 's');
            end

            if printLevel > 0 && status_curlDownload == 0
                fprintf(' + Downloaded:      %s\n', filename);
            end
        else
            fprintf(' > The URL %s cannot be reached.\n', url);
        end
    else
        if printLevel > 0
            fprintf(' > Already exists:  %s\n', filename);
        end
    end
end
