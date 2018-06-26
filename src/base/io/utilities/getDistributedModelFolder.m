function  modelDir = getDistributedModelFolder(modelName) 
% Identifies the folder a distributed model is located in.
% This function only works with models which are part of the models 
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
%    modelDir:          The folder the model should be located in.
% 

global CBTDIR
global ENV_VARS
if isempty(CBTDIR)    
    ENV_VARS.printLevel = false;
    initCobraToolbox(false); %Don't update the toolbox automatically
    ENV_VARS.printLevel = true;    
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