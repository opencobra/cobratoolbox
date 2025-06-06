function status = testTissueModel()
% tests the createTissueSpecificModel function using Recon1

% Load required variables: Recon1 model and Expression Data
load testTissueModel.mat

% Call function
[tissueModel,rxns] = createTissueSpecificModel(model,expressionData);

% Check if function is working
if exist('tissueModel','var')
    if length(tissueModel.rxns) < length(model.rxns)
        status = 1;
    else
        status = 0;
    end
else
    status = 0;
end
