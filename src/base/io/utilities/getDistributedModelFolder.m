function  modelDir = getDistributedModelFolder(modelName) 
% Identifies the folder a model is to be searched in.
%
% USAGE:
%
%    modelDir = getDistributedModelFolder(modelName) 
%
% INPUT:
%    modelName:         The name of the model including the file extension
%    
%
% OUTPUTS:
%    modelDir:          The folder the model should eb located in.
% 

global CBTDIR
if isempty(CBTDIR)
    error('The Toolbox is not initialized. Cannot identfy the Model folder.\nPlease run initCobraToolbox() and try again');
end

modelDir = [CBTDIR filesep 'test' filesep 'models'];

[~,~,extension] = fileparts(modelName);
if strcmp(extension,'.mat')
    modelDir = [modelDir filesep 'mat'];
elseif strcmp(extension,'.xml')
    modelDir = [modelDir filesep 'xml'];
end
if exist([modelDir filesep modelName], 'file')
    return
else    
    error('Requested Model not present in the model directory.\n This is either due to the model not being downloaded, or not being part of the distributed models.')
end