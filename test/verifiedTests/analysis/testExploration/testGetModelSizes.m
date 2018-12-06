% The COBRAToolbox: testGetModelSizes.m
%
% Purpose:
%     - tests the getModelSizes function. 
%
% Authors:
%     - Thomas Pfau - 2018
%


% initialize the test
fileDir = fileparts(which('testSearchModel'));
% save the current path
currentDir = cd(fileDir);

% load model
model = getDistributedModel('ecoli_core_model.xml'); % need xml here, to be sure about comps.

% get basic info 
[nMets, nRxns, nCtrs, nVars, nGenes, nComps] = getModelSizes(model);
assert(nRxns == 95 && nMets == 72 && nCtrs == 0 && nVars == 0 && nGenes == 137 && nComps == 2);

% check that vars are determined correctly
model = addCOBRAVariables(model,'TestVariable');
[nMets, nRxns, nCtrs, nVars, nGenes, nComps] = getModelSizes(model);
assert(nRxns == 95 && nMets == 72 && nCtrs == 0 && nVars == 1 && nGenes == 137 && nComps == 2);

model = addCOBRAConstraints(model,model.rxns(1),3);
[nMets, nRxns, nCtrs, nVars, nGenes, nComps] = getModelSizes(model);
assert(nRxns == 95 && nMets == 72 && nCtrs == 1 && nVars == 1 && nGenes == 137 && nComps == 2);

%Return to original directory
cd(currentDir);