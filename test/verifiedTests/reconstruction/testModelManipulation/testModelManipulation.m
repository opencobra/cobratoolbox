% The COBRAToolbox: testModelManipulation.m
%
% Purpose:
%     - testModelManipulation tests addReaction, removeReaction, removeMetabolite
%       first creates a simple toy network with basic S, lb, ub, rxns, mets
%       tests addReaction, removeReaction, removeMetabolite
%       then creates an empty matrix and does the previous procedures.
%       Then tests convertToReversible, and convertToIrreversible using the
%       iJR904 model. Prints whether each test was successful or not.
%
% Authors:
%     - Joseph Kang 04/16/09
%     - Richard Que (12/16/09) Added testing of convertToIrrevsible/Reversible
%     - CI integration: Laurent Heirendt January 2017

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testModelManipulation'));
cd(fileDir);

% Test with non-empty model
fprintf('>> Starting non-empty model tests:\n');

% addReaction, removeReaction, removeMetabolite
model.S = [-1, 0, 0 ,0 , 0, 0, 0;
            1, -1, 0, 0, 0, 0, 0;
            0, -1, 0,-1, 0, 0, 0;
            0, 1, 0, 1, 0, 0, 0;
            0, 1, 0, 1, 0, 0, 0;
            0, 1,-1, 0, 0, 0, 0;
            0, 0, 1,-1, 1, 0, 0;
            0, 0, 0, 1,-1,-1, 0;
            0, 0, 0, 0, 1, 0, 0;
            0, 0, 0, 0,-1, 0, 0;
            0, 0, 0, 0, 0, 1, 1;
            0, 0, 0, 0, 0, 1, -1];
model.lb = [0, 0, 0, 0, 0, 0, 0]';
model.ub = [20, 20, 20, 20, 20, 20, 20]';
model.rxns = {'GLCt1'; 'HEX1'; 'PGI'; 'PFK'; 'FBP'; 'FBA'; 'TPI'};
model.mets = {'glc-D[e]'; 'glc-D'; 'atp'; 'H'; 'adp'; 'g6p';'f6p'; 'fdp'; 'pi'; 'h2o'; 'g3p'; 'dhap'};
sc =  [-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
mets_length = length(model.mets);
rxns_length = length(model.rxns);

% adding a reaction to the model
model = addReaction(model, 'EX_glc', model.mets, sc, 0, 0, 20);

% adding a reaction to the model (test only)
model = addReaction(model, 'ABC_def', model.mets, 2 * sc, 0, -5, 10);

% check if the number of reactions was incremented by 1
assert(length(model.rxns) == rxns_length + 2);

% adding a reaction to the model (test only)
model = addReaction(model, 'ABC_def', model.mets, 3 * sc);

% remove the reaction from the model
model = removeRxns(model, {'EX_glc'});

% remove the reaction from the model
model = removeRxns(model, {'ABC_def'});

% add exchange reaction
addExchangeRxn(model, {'glc-D[e]'; 'glc-D';})

%check if rxns length was decremented by 1
assert(length(model.rxns) == rxns_length);

% add a new reaction to the model
model = addReaction(model,'newRxn1','A -> B + 2 C');

% check if the number of reactions was incremented by 1
assert(length(model.rxns) == rxns_length + 1);

% check if the number of metabolites was incremented by 3
assert(length(model.mets) == mets_length + 3);

% change the reaction bounds
model = changeRxnBounds(model, model.rxns, 2, 'u');
assert(model.ub(1) == 2);

% remove the reaction
model = removeRxns(model, {'newRxn1'});
assert(length(model.rxns) == rxns_length);

% remove some metabolites
model = removeMetabolites(model, {'A', 'B', 'C'});
assert(length(model.mets) == mets_length);

% Tests with empty model
fprintf('>> Starting empty model tests:\n');

model.S = [];
model.rxns = {};
model.mets = {};
model.lb = [];
model.ub = [];

rxns_length = 0;
mets_length = 0;

% add a reaction
model = addReaction(model,'newRxn1','A -> B + 2 C');

% check if the number of reactions was incremented by 1
assert(length(model.rxns) == rxns_length + 1);

% check if the number of metabolites was incremented by 3
assert(length(model.mets) == mets_length + 3);

% change the reaction bounds
model = changeRxnBounds(model, model.rxns, 2, 'u');
assert(model.ub(1) == 2);

% remove the reaction
model = removeRxns(model, {'newRxn1'});
assert(length(model.rxns) == rxns_length);

% remove some metabolites
model = removeMetabolites(model, {'A', 'B', 'C'});
assert(length(model.mets) == mets_length);

% Convert to irreversible
fprintf('>> Testing convertToIrreversible (1)\n');
load('testModelManipulation.mat','model','modelIrrev');
[testModelIrrev, matchRev, rev2irrev, irrev2rev] = convertToIrreversible(model);

% test if both models are the same
assert(isSameCobraModel(modelIrrev, testModelIrrev));

% Convert to reversible
fprintf('>> Testing convertToReversible\n');
testModelRev = convertToReversible(testModelIrrev);
testModelRev = rmfield(testModelRev,'reversibleModel'); % this should now be the original model!

% test if both models are the same
assert(isSameCobraModel(model,testModelRev));

% test irreversibility of model
fprintf('>> Testing convertToIrreversible (2)\n');
load('testModelManipulation.mat','model','modelIrrev');

% set a lower bound to positive (faulty model)
modelRev.lb(1) = 10;
[testModelIrrev, matchRev, rev2irrev, irrev2rev] = convertToIrreversible(model);

% test if both models are the same
assert(isSameCobraModel(modelIrrev, testModelIrrev));


%test Conversion with special ordering
fprintf('>> Testing convertToIrreversible (3)\n');
load('testModelManipulation.mat','model','modelIrrevOrdered');

[testModelIrrev, matchRev, rev2irrev, irrev2rev] = convertToIrreversible(model, 'orderReactions', true);

% test if both models are the same
assert(isSameCobraModel(modelIrrevOrdered, testModelIrrev));


%Test moveRxn
model2 = moveRxn(model,10,20);
fields = getModelFieldsForType(model,'rxns');
rxnSize = numel(model.rxns);
for i = 1:numel(fields)
    if size(model.(fields{i}),1) == rxnSize
        val1 = model.(fields{i})(10,:);    
        val2 = model2.(fields{i})(20,:);    
    elseif size(model.(fields{i}),2) == rxnSize
        val1 = model.(fields{i})(:,10);    
        val2 = model2.(fields{i})(:,20);    
    end
    assert(isequal(val1,val2));
end

% change the directory
cd(currentDir)
