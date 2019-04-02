% The COBRAToolbox: testBiomassPrecursorCheck.m
%
% Purpose:
%    - This script aims to test testBiomassPrecursorCheck.m
%
% Authors:
%    - Siu Hung Joshua Chan June 2018

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBiomassPrecursorCheck'));
cd(fileDir);

% test coupling
model = createToyModelForBiomassPrecursorCheck();
% this model cannot carry flux through the objective, but each precursor can
% be produced if exchangers exist for all precursors.
[missingMets, presentMets] = biomassPrecursorCheck(model);
assert(isempty(setxor(missingMets,{'G'})))
assert(isempty(setxor(presentMets,{'E','F'})));

% check for coupled Mets
[missingMets, presentMets, coupledMets] = biomassPrecursorCheck(model,true);

assert(isempty(setxor(missingMets,{'G'})))
assert(isempty(setxor(presentMets,{'F'}))); % F can be produced, as surplus E can be removed by the biomass function.
assert(isempty(setxor(coupledMets,{'E'}))); % all E has to go to the biomass as long as there is no sink for F.

% check for cofactor pairs but not coupled mets
[missingMets, presentMets, coupledMets, missingCofs, presentCofs] = biomassPrecursorCheck(model, [], true);
assert(isempty(missingMets))  % G, previously in missingMets now belongs to presentCofs 
assert(isempty(setxor(presentMets,{'E','F'})));
assert(isempty(coupledMets))
assert(isempty(missingCofs))
presentCofsStr = cellfun(@(x) strjoin(x, '|'), presentCofs, 'UniformOutput', false);
assert(isempty(setxor(presentCofsStr, {'G|H'})))

% check for both coupled mets and cofactor pairs
[missingMets, presentMets, coupledMets, missingCofs, presentCofs] = biomassPrecursorCheck(model, true, true);
assert(isempty(missingMets))
assert(isempty(setxor(presentMets,{'F'}))); % F can be produced, as surplus E can be removed by the biomass function.
assert(isempty(setxor(coupledMets,{'E'}))); % all E has to go to the biomass as long as there is no sink for F.
% cofactor G can be produced from H. No missing cofactor pair.
assert(isempty(missingCofs))
presentCofsStr = cellfun(@(x) strjoin(x, '|'), presentCofs, 'UniformOutput', false);
assert(isempty(setxor(presentCofsStr, {'G|H'})))

% check for the case with missing cofactor pairs
model = changeRxnBounds(model, 'R1', 0, 'b');  % shut down the reaction generating the cofactor G from H
[missingMets, presentMets, coupledMets, missingCofs, presentCofs] = biomassPrecursorCheck(model, true, true);
assert(isempty(missingMets))
% both E and F become coupled now because the biomass reaction cannot have flux to remove the surplus due to missingCofs G -> H 
assert(isempty(presentMets))
assert(isempty(setxor(coupledMets,{'E', 'F'})));
% cofactor G cannot be produced from H after R1 is shut down.
missingCofsStr = cellfun(@(x) strjoin(x, '|'), missingCofs, 'UniformOutput', false);
assert(isempty(setxor(missingCofsStr, {'G|H'})))
assert(isempty(presentCofs))

% check for the case with missing mets and no conserved cofactor pairs at all
model = addReaction(model, 'Ex_G', 'reactionFormula', 'G <=>');
model = addReaction(model, 'Ex_H', 'reactionFormula', 'H <=>');
model = changeRxnBounds(model, 'Ex_A', 0, 'b');
[missingMets, presentMets, coupledMets, missingCofs, presentCofs] = biomassPrecursorCheck(model, true, true);

% test error
assert(verifyCobraFunctionError('biomassPrecursorCheck','input',{model},'outputArgCount',3,'testMessage', ...
    sprintf('coupledMets are not being calculated if checkCoupling is not set to true!\n%s', ...
    'missingCofs and presentCofs are not being calculated if checkConservedQuantities is not set to true!')))
assert(verifyCobraFunctionError('biomassPrecursorCheck','input',{model, true},'outputArgCount',4,'testMessage', ...
    'missingCofs and presentCofs are not being calculated if checkConservedQuantities is not set to true!'))


% test the E. coli core model
model = readCbModel('ecoli_core_model.mat');
% add a hypothetical non-producible cofactor pair
model = addReaction(model, 'COF', 'reactionFormula', 'metTest1[c] -> metTest2[c]');
model = addReaction(model, 'BIOMASS2', 'reactionFormula', 'metTest1[c] + atp[c] -> metTest2[c] + adp[c]');
% test the function's capability to handle >1 objective reactions 
model = changeObjective(model, {'Biomass_Ecoli_core_N(w/GAM)-Nmet2'; 'BIOMASS2'}, 1);
% additional functionalities not turned on
[missingMets0, presentMets0] = biomassPrecursorCheck(model);
% additional functionalities turned on
if exist([pwd filesep 'testBiomassPrecursorCheck.txt'], 'file')
    delete([pwd filesep 'testBiomassPrecursorCheck.txt'])
end
diary('testBiomassPrecursorCheck.txt');
[missingMets, presentMets, coupledMets, missingCofs, presentCofs] = biomassPrecursorCheck(model, true, true);
diary off

% empty coupledMets
assert(isempty(coupledMets))

% producible cofactors identified as missingMets when checkConservedQuantities not turned on
assert(isempty(setxor(missingMets0, {'accoa[c]';'atp[c]';'nad[c]';'nadph[c]';'metTest1[c]'})))
assert(isempty(setxor(presentMets0, {'3pg[c]';'e4p[c]';'f6p[c]';'g3p[c]';'g6p[c]';...
    'gln-L[c]';'glu-L[c]';'h2o[c]';'oaa[c]';'pep[c]';'pyr[c]';'r5p[c]'})))

% no missingMets when checkConservedQuantities turned on
assert(isempty(missingMets))
% same set of presentMets
assert(isempty(setxor(presentMets, presentMets0)))

% missingCofs and presentCofs are identified
missingCofsStr = cellfun(@(x) strjoin(x, '|'), missingCofs, 'UniformOutput', false);
assert(isempty(setxor(missingCofsStr, {'metTest1[c]|metTest2[c]'})))
presentCofsStr = cellfun(@(x) strjoin(x, '|'), presentCofs, 'UniformOutput', false);
assert(isempty(setxor(presentCofsStr, {'nadp[c]|nadph[c]'; 'adp[c]|atp[c]'; ...
    'accoa[c]|coa[c]'; 'nad[c]|nadh[c]'})))

% check the correct printing of the results
f = fopen('testBiomassPrecursorCheck.txt', 'r');
l = fgetl(f);
text = {};
while ~isequal(l, -1)
    text{end + 1} = l;
    l = fgetl(f);
end
fclose(f);

lineCan = find(~cellfun(@isempty, strfind(text, 'Cofactors in the biomass reaction that CAN be synthesized:')));
assert(isscalar(lineCan))
lineCannot = find(~cellfun(@isempty, strfind(text, 'Cofactors in the biomass reaction that CANNOT be synthesized:')));
assert(isscalar(lineCannot))
cofactorCan = {'nadph[c]  -> nadp[c]', 'atp[c]  -> adp[c]', 'accoa[c]  -> coa[c]', 'nad[c]  -> nadh[c]'};
cofactorCannot = {'metTest1[c]  -> metTest2[c]'};
% correct order of printing
for j = 1:numel(cofactorCan)
    lineJ = find(~cellfun(@isempty, strfind(text, cofactorCan{j})));
    assert(~isempty(lineJ) && lineJ > lineCan && lineJ < lineCannot)
end
for j = 1:numel(cofactorCannot)
    lineJ = find(~cellfun(@isempty, strfind(text, cofactorCannot{j})));
    assert(~isempty(lineJ) && lineJ > lineCannot)
end
delete([pwd filesep 'testBiomassPrecursorCheck.txt'])

% test identifying internally conserved moieties using atom transition network
% load the dopamine synthesis model
modelDir = fileparts(which('subDas.mat'));
model = load('subDas.mat');
model = model.model;
% build the atom transition network using the data
ATN = buildAtomTransitionNetwork(model, [modelDir filesep 'atomMapped']);

% add a hypothetical biomass reaction to the model
model = addReaction(model, 'BIOMASS', 'reactionFormula', '0.1 dopa[c] + 0.1 h2o[c] + 0.2 thbpt[c] -> 0.2 dhbpt[c]', 'objectiveCoef', 1);

% test using left null space to approximate conserved moieties first
[missingMets, presentMets, coupledMets, missingCofs, presentCofs] = biomassPrecursorCheck(model, 1, 1);
assert(isempty(missingMets) & isempty(coupledMets) & isempty(missingCofs))
assert(isempty(setxor(presentMets, {'h2o[c]', 'dopa[c]'})))
assert(numel(presentCofs) == 1 & isempty(setxor(presentCofs{1}, {'thbpt[c]', 'dhbpt[c]'})))

% test using ATN. Results should be the same
[missingMets, presentMets, coupledMets, missingCofs, presentCofs] = biomassPrecursorCheck(model, 1, 1, ATN);
assert(isempty(missingMets) & isempty(coupledMets) & isempty(missingCofs))
assert(isempty(setxor(presentMets, {'h2o[c]', 'dopa[c]'})))
assert(numel(presentCofs) == 1 & isempty(setxor(presentCofs{1}, {'thbpt[c]', 'dhbpt[c]'})))

% now block formate uptake. Nothing can be produced
model = changeRxnBounds(model, 'E6', 0, 'l');

% test using left null space to approximate conserved moieties first
[missingMets, presentMets, coupledMets, missingCofs, presentCofs] = biomassPrecursorCheck(model, 1, 1);
assert(isempty(presentMets) & isempty(coupledMets) & isempty(presentCofs))
assert(isempty(setxor(missingMets, {'h2o[c]', 'dopa[c]'})))
assert(numel(missingCofs) == 1 & isempty(setxor(missingCofs{1}, {'thbpt[c]', 'dhbpt[c]'})))

% test using ATN. Results should be the same
[missingMets, presentMets, coupledMets, missingCofs, presentCofs] = biomassPrecursorCheck(model, 1, 1, ATN);
assert(isempty(presentMets) & isempty(coupledMets) & isempty(presentCofs))
assert(isempty(setxor(missingMets, {'h2o[c]', 'dopa[c]'})))
assert(numel(missingCofs) == 1 & isempty(setxor(missingCofs{1}, {'thbpt[c]', 'dhbpt[c]'})))


% change the directory
cd(currentDir)
