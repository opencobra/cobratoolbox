function sbmlTestModelToMat(originFolder, destFolder)
% Function to translate a batch of sbml files in .xml format within an `originFolder`,
% into COBRA toolbox compatible models, saving each as a .mat file in `destFolder`
% containing one 'model' structure derived from the corresponding .xml file
%
% USAGE:
%
%    sbmlTestModelToMat(originFolder, destFolder)
%
% INPUT:
%    originFolder:    full path to the folder with the input SBML XML files
%    destFolder:      full path to the folder with the COBRA 2.0 toolbox compatible models,
%                     one each in a name.mat file where name is derived from the
%                     filename of the corresponding input name.xml file
%
% .. Author:
%       - Ronan Fleming, 25/11/14 first version, 06/11/14 origin and destination folders different

if nargin < 1  % choose the folder within the folder 'testModels' where the .xml files are located
    originFolder = 'm_model_collection';
end
if nargin < 2
    destFolder = 'm_model_collection';
end

% choose the printLevel
printLevel = 1;  % only print out names of models that don't parse

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global CBTDIR
if isempty(CBTDIR)
    CBTDIR = fileparts(which('initCobraToolbox'));
end

% modelDir=[CBTDIR filesep 'testing' filesep 'testModels' filesep originFolder];
% allow to read xml files from a folder that should not be written into
files = dir(originFolder);

for k = 3:length(files)
    if strcmp(files(k).name(end - 2:end), 'xml')
        % read in the xml file
        fileName = files(k).name;
        if ~exist([destFolder filesep fileName(1:end - 3) 'mat'], 'file')
            filePathName = [originFolder filesep fileName];
            % save as mat file in the same directory
            % savedMatFile=[CBTDIR filesep 'testing' filesep 'testModels' filesep destFolder filesep fileName(1:end-4) '.mat'];
            savedMatFile = [destFolder filesep fileName(1:end - 4) '.mat'];
            try
                if printLevel > 0
                    fprintf('%s%s\n', fileName, [' :compatible with readCbModel'])
                end
                model = readCbModel(filePathName);
                % disp(savedMatFile)
                save(savedMatFile, 'model');
            catch
                if printLevel > 0
                    fprintf('%s%s\n', fileName, [' :incompatible with readCbModel'])
                end
                % should not leave half finished files around if there are
                % any
                if exist(savedMatFile, 'file')
                    delete(savedMatFile)
                end
            end
        else
            if printLevel > 0
                fprintf('%s%s\n', fileName, [' :already parsed and compatible with readCbModel'])
            end
        end
    end
end
