function  model = getDistributedModel(modelName, description) 
% Loads the indicated model from the models submodule.
%
% USAGE:
%
%    model = getDistributedModel(modelName) 
%
% INPUT:
%    modelName:         The name of the model including the file extension
%    
% OPTIONAL INPUTS:
%    description:       If the model description should be set to a
%                       specific value
%
% OUTPUTS:
%    model:             The loaded model from the models submodule (i.e.
%                       those distributed for the test suite)
% 

global CBTDIR
global ENV_VARS

if isempty(CBTDIR)
    ENV_VARS.printLevel = false;
    initCobraToolbox(false); %Don't update the toolbox automatically
    ENV_VARS.printLevel = true;
end

if ~exist('description','var')
    description = modelName;
end

modelDir = getDistributedModelFolder(modelName);

if exist([modelDir filesep modelName], 'file')
    model = readCbModel([modelDir filesep modelName],'modelDescription',description);
else    
    error('Requested Model not present in the Model directory.\n This is either due to the model not being downloaded, or not being part of the distributed models.')
end