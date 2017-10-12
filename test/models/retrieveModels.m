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
'AntCore.mat', 'https://raw.github.com/snmendoz/Models/master/AntCore.mat', 'b855a67f10e0cf123c11adf0ded73ba25ee8c00d';...
'iIT341.xml', 'http://bigg.ucsd.edu/static/models/iIT341.xml', '';...
'Abiotrophia_defectiva_ATCC_49176.xml', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/sbml/Abiotrophia_defectiva_ATCC_49176.xml', '915d77de1c2614b2f591e10c45ca51f2e358576b';...
'Sc_iND750_flux1.xml', 'http://gcrg.ucsd.edu/sites/default/files/Attachments/Images/InSilicoOrganisms/yeast/Sc_iND750_flux1.xml', '8c5e856cb6de55e6787d40961a3e72f2618deb27';...
'ecoli_core_model.mat', 'http://gcrg.ucsd.edu/sites/default/files/Attachments/Images/downloads/Ecoli_core/ecoli_core_model.mat', 'be70902857ee5468733e5ea0132a14b1f44e360a';...
'modelReg.mat', 'http://gcrg.ucsd.edu/sites/default/files/Attachments/Images/downloads/Ecoli_core/modelReg.mat', '2213c71fe1a1fb721bc9c06c943a4f1a76742b4b';...
'iAF1260.mat', 'http://bigg.ucsd.edu/static/models/iAF1260.mat', '';...
'iJO1366.mat', 'http://bigg.ucsd.edu/static/models/iJO1366.mat', '';...
'Abiotrophia_defectiva_ATCC_49176.mat', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/mat/Abiotrophia_defectiva_ATCC_49176.mat', '923859793998c17b1bb665f54b1ebb005e37917e';...
'Acidaminococcus_fermentans_DSM_20731.mat', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/mat/Acidaminococcus_fermentans_DSM_20731.mat', '28027732201e4179908076b4d396b1a91fe8c9ba';...
'Acidaminococcus_intestini_RyC_MR95.mat', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/mat/Acidaminococcus_intestini_RyC_MR95.mat', '70359607d703de512273517e20b238137a5ba9bf';...
'Acidaminococcus_sp_D21.mat', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/mat/Acidaminococcus_sp_D21.mat', 'fe1d088394b942db682593ea121b4154aa268fd1';...
'Acinetobacter_calcoaceticus_PHEA_2.mat', 'https://webdav-r3lab.uni.lu/public/msp/AGORA/mat/Acinetobacter_calcoaceticus_PHEA_2.mat', '945fc0bbeac0242fab6d392a306991aa0d464cba';...
'Recon1.0model.mat', 'https://raw.github.com/cobrabot/COBRA.models/master/Recon1.0model.mat', '348bfa16b111ea93c8005522e0062f3e41f7916a';...
'Recon2.0model.mat', 'https://raw.github.com/cobrabot/COBRA.models/master/Recon2.0model.mat', '235fe6eec8291bde4ea944a849d8ae9995822fa7'};

% define silence level of curl
if printLevel == 0
    curlSilence = '-s';
else
    curlSilence = '-s';
end

onCI = ~isempty(strfind(getenv('HOME'), 'jenkins')) || ~isempty(strfind(getenv('USERPROFILE'), 'jenkins'));

if onCI
    maxtries = 30;
else
    maxtries = 3;
end

% download all models
for i = 1:length(modelArr)
    downloadOk = false;
    currenttry = 0;
    while ~downloadOk && (currenttry < maxtries)
        fileName = modelArr{i,1};
        sha1sum = modelArr{i,3};
        if exist([MODELDIR, filesep, fileName], 'file') ~= 2
            currenttry = currenttry + 1;
            % check if the remote URL can be reached
            [status_curl, result_curl] = system(['curl --max-time 15 -s -k -L --head ', modelArr{i, 2}]);            
            % check if the URL exists
            if status_curl == 0 && ~isempty(strfind(result_curl, ' 200'))
                status_curlDownload = system(['curl ', curlSilence, ' --max-time 60 -O -L ', modelArr{i, 2}]);
                [~,sha1res] = system(['sha1sum ', fileName]);
                checkSumOk = strncmp(sha1sum,sha1res,length(sha1sum)); %Discard surplus output of sha1sum;
                if checkSumOk && status_curlDownload == 0
                    downloadOk = true;
                    if printLevel > 0
                        fprintf(' + Downloaded:      %s\n', modelArr{i, 2});
                    end
                end
                    
            else
                fprintf(' > The URL %s cannot be reached.\n', modelArr{i, 2});
            end
        else
            [~,sha1res] = system(['sha1sum ', fileName]);
            checkSumOk = strncmp(sha1sum,sha1res,length(sha1sum)); %Discard surplus output of sha1sum;
            if ~checkSumOk
                delete(fileName); %retry a download, wrong checkSum.
            else
                downloadOk = true;
                if printLevel > 0
                    fprintf(' > Already exists:  %s\n', modelArr{i, 1});
                end
            end
        end
    end
end


           
zipModelArr = {'Ec_iAF1260_flux1.xml','http://systemsbiology.ucsd.edu/sites/default/files/Attachments/Images/InSilicoOrganisms/Ecoli/Ecoli_SBML/msb4100155-s6.zip','Ec_iAF1260_flux1.txt',{'Ec_iAF1260_flux2.txt', 'read_me.txt'},'7725f5e16cb9c2ec5baf81ed525e489a390a2610';...
            'STM_v1.0.xml','https://static-content.springer.com/esm/art%3A10.1186%2F1752-0509-5-8/MediaObjects/12918_2010_598_MOESM2_ESM.ZIP','',{},'055a616306ff4b285a733c94e4e41ca1d546f5c5';...
            'ME_matrix_GlcAer_WT.mat','https://wwwen.uni.lu/content/download/72953/917521/file/download.zip','',{},'70eef53b4ce826b3ece581e6d99145779f185752';...
            'Recon2.v04.mat','https://vmh.uni.lu/files/Recon2.v04.mat_.zip','',{},'af27f2505e884c2b62d2a37c51d2b19b47cdb35c';...
            'cardiac_mit_glcuptake_atpmax.mat','https://wwwen.uni.lu/content/download/72949/917505/file/Human%20cardiac%20myocyte%20mitochondrial%20metabolic%20reconstruction_cardiac_mit_glcuptake_atpmax.mat.zip','',{},'b567deb6b34c7cf24415ed4741a7ab507d15726e';...
            'Recon-2.mat','https://webdav-r3lab.uni.lu/public/msp/Recon-2.zip','',{},'bc29eb76546541b56272fb02d391278643de46b7'};
        
for i = 1:size(zipModelArr,1)
    downloadOk = downloadModelZipFile(zipModelArr{i,1}, zipModelArr{i,2}, 'fileToBeRenamed', zipModelArr{i,3},'deleteExtraFiles', zipModelArr{i,4},'checkSum', zipModelArr{i,5}, 'printLevel', printLevel);
    currenttries = 1;
    while ~downloadOk && currenttries < maxtries
        downloadOk = downloadModelZipFile(zipModelArr{i,1}, zipModelArr{i,2}, 'fileToBeRenamed', zipModelArr{i,3},'deleteExtraFiles', zipModelArr{i,4},'checkSum', zipModelArr{i,5}, 'printLevel', printLevel);
        currenttries = currenttries + 1;
    end
    if ~downloadOk
        if onCI
            error('Could not retrieve all Models. Aborting!')
        else
            warning('Could not retrieve Model %s. Some tests might not work properly')
        end
        %delete the file if it exists, its not correct.
        delete(zipModelArr{i,1});
    end
end
% print sucess message
if printLevel > 0
    fprintf(['   Done downloading models.\n']);
end

% change back to the root directory
cd(currentDir)

end


function downloadOk = downloadModelZipFile(filename, url, varargin)
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
    downloadOk = false;

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
                case 'checkSum'
                    checkSum = value;                
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
            [~,sha1res] = system(['sha1sum ', filename]);
            checkSumOk = strncmp(checkSum,sha1res,length(checkSum)); %Discard surplus output of sha1sum;
            if status_curlDownload == 0 && checkSumOk
                downloadOk = true;
                if printLevel > 0 
                    fprintf(' + Downloaded:      %s\n', filename);
                end
            else
                downloadOk = false;
            end
        else
            fprintf(' > The URL %s cannot be reached.\n', url);
        end
    else
       [~,sha1res] = system(['sha1sum ', filename]);
       checkSumOk = strncmp(checkSum,sha1res,length(checkSum));    
       if ~checkSumOk
           delete(filename);
           downloadOk = false;
       else
           downloadOk = true;
           if printLevel > 0
               fprintf(' > Already exists:  %s\n', filename);
           end
       end
    end
end
