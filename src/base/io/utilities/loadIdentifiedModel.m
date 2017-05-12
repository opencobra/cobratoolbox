function model = loadIdentifiedModel(filename,directory)
%load a single cobra toolbox model saved as a filename.mat file, then
%rename the model structure 'model' while retaining the original name of
%the model structure in model.modelID
%
%INPUT
% filename          name of the .mat file containing cobra toolbox model
%                   structure
% directory         directory where the .mat file resides.
%
%OUTPUT
% model cobra toolbox model

%Ronan Fleming

if ~exist('directory','var')
    directory=pwd;
end

matFile=[directory filesep filename '.mat'];

%get the id of the model from the filename
whosFile=whos('-file',matFile);
modelName=whosFile.name;
%load the .mat file
load(matFile);
%rename the variable of the model to the standard, i.e. 'model'
model=eval(modelName);
%model.rev should be depreciated as it duplicates model.lb and model.ub
if isfield(model,'rev')
    model=rmfield(model,'rev');
end
if isfield(model,'osense')
    model.osense=cast(model.osense,'double');
end
%stamp the model with the ID of the file
model.modelID=modelName;

if strmatch(modelName,filename)~=1
    warning('fileName.mat and modelStructureName.mat did not match') 
            
end

end

