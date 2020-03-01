% The COBRAToolbox: testConstraints.m
%
% Purpose:
%     - testConstraints tests multiple functions concerning the Variables
%     and Constraints fields in the model. 
%
% Authors:
%     - Thomas Pfau 2018

solverPkgs = prepareTest('needsLP',true);

model = getDistributedModel('ecoli_core_model.mat');

model_orig = model;

% some settings
aconACit = 6.13;
aconAAcon = 14.5;
aconBCit = 23.8;
aconBAcon = 39.1;
aconAAmount = 0.02;
aconBAmount = 0.01;
aconVars = {'aconA','aconB'};
linkedReactions = {'ACONTa','ACONTb'};

% Adding Variables
model = addCOBRAVariables(model,aconVars,'lb',[0;0],'ub',[aconAAmount;aconBAmount]);
for enzyme = 1:numel(aconVars)
    for linkedReaction = 1:numel(linkedReactions)
        model = addCOBRAVariables(model,{strcat(aconVars{enzyme},'to',linkedReactions{linkedReaction})},'lb',0);
    end
end

% Adding Constraints
model = addCOBRAConstraints(model,{'aconAtoACONTa','aconAtoACONTb','aconA'},0, 'c',[-1,-1,1],...
    'dsense','E', 'ConstraintID', 'aconAAmount');
model = addCOBRAConstraints(model,{'aconBtoACONTa','aconBtoACONTb','aconB'},0, 'c',[-1,-1,1],...
    'dsense','E', 'ConstraintID', 'aconBAmount');
nCtrs = numel(model.ctrs);
%Add multiple constraints at once.
model = addCOBRAConstraints(model,{'aconAtoACONTa','aconBtoACONTa','ACONTa','aconAtoACONTb','aconBtoACONTb','ACONTb'},...
                           [0;0], 'c',[aconACit,aconBCit,-1,0,0,0; 0,0,0,aconAAcon,aconBAcon,-1],...
                           'dsense',('EE')', 'ConstraintID', {'ACONTaFlux';'ACONTbFlux'});
assert(numel(model.ctrs) - nCtrs == 2);
constraintModel = model;
%Now, test the constraints 
for k = 1:numel(solverPkgs.LP)
    changeCobraSolver(solverPkgs.LP{k},'LP');
    orig_sol = optimizeCbModel(model_orig);
    restricted_sol = optimizeCbModel(constraintModel);  
    assert(orig_sol.f > restricted_sol.f);
    % test modifications
    modelModVar = changeCOBRAVariable(model,'aconA','ub',0.06);
    less_restricted_sol = optimizeCbModel(modelModVar);
    % this should have more flux
    assert(less_restricted_sol.f > restricted_sol.f);
    modelModVar = changeCOBRAConstraints(modelModVar,'ACONTaFlux','idList',{'aconAtoACONTa','aconBtoACONTa','ACONTa'},...
    'c',[aconACit*0.5,aconBCit,-1]);
    less_efficient_aconA = optimizeCbModel(modelModVar);
    % This should again have less flux.
    assert(less_restricted_sol.f > less_efficient_aconA.f);
end

