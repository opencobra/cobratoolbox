function  model = getDistributedModel(modelName) 
% Loads the indicated model from the models submodule.
%
% USAGE:
%
%    model = getDistributedModel(modelName) 
%
% INPUT:
%    modelName:         The name of the model including the file extension
%
% OUTPUTS:
%    model:             The loaded model from the models submodule (i.e.
%                       those distributed for the test suite)
% 

global CBTDIR
global ENV_VARS

if isempty(CBTDIR)
    ENV_VARS.printLevel = false;
    initCobraToolbox;
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
    model = readCbModel([modelDir filesep modelName]);
else    
    error('Requested Model not present in the Model directory.\n This is either due to the model not being downloaded, or not being part of the distributed models.')
end