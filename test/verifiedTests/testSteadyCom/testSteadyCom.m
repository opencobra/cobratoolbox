% The COBRAToolbox: testSteadyCom.m
%
% Purpose:
%    - This script aims to test the SteadyCom module and compare the results 
%      with the expected data. All functions involved will be called explicitly or implicitly. 
%
% Authors:
%    - Siu Hung Joshua Chan July 2017

% choose tolerance according to the solver used
global CBT_LP_SOLVER

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSteadyCom'));
cd(fileDir);

% create a toy model
rxns = {'EX_a(e)'; 'EX_b(e)'; 'EX_c(e)'; 'TransA'; 'TransB'; 'TransC'; 'A2B'; 'A2C'; 'BIOMASS'};
rxnNames = {'Exchange of a'; 'Exchange of b'; 'Exchange of c'; ...
    'Transport of a'; 'Transport of b'; 'Transport of c'; ...
    'Convert A to B'; 'Convert A to C'; 'Biomass reaction'};
rxnEqs = {'a[e] <=>'; 'b[e] <=>'; 'c[e] <=>'; ...
    'a[e] <=> a[c]'; 'b[e] <=> b[c]'; 'c[e] <=> c[c]'; ...
    'a[c] -> b[c]'; 'a[c] -> 0.5 c[c]'; '30 b[c] + 20 c[c] ->'};
model = createModel(rxns, rxnNames, rxnEqs, 'lowerBoundList', [-1; 0; 0; -1000; -1000; -1000; 0; 0; 0]);
% two copies of the model, each with one intracellular reaction KO
org1 = changeRxnBounds(model, 'A2B', 0);
org2 = changeRxnBounds(model, 'A2C', 0);
% construct a community model
modelJoint = createMultipleSpeciesModel({org1; org2}, {'Org1'; 'Org2'});

% TEST getMultiSpeciesModelId to retreive reaction/metabolite IDs
[modelJoint.infoCom, modelJoint.indCom] = getMultiSpeciesModelId(modelJoint, {'Org1'; 'Org2'});
data = load('refData_getMultiSpeciesModelId', 'infoCom', 'indCom');
assert(isequal(data.infoCom, modelJoint.infoCom))
assert(isequal(data.indCom, modelJoint.indCom))

% No community uptake for b and c but only for a
aCom = strcmp(modelJoint.infoCom.Mcom, 'a[u]');
bCom = strcmp(modelJoint.infoCom.Mcom, 'b[u]');
cCom = strcmp(modelJoint.infoCom.Mcom, 'c[u]');
modelJoint = changeRxnBounds(modelJoint, modelJoint.infoCom.EXcom(aCom), -10, 'l');
modelJoint = changeRxnBounds(modelJoint, modelJoint.infoCom.EXcom(bCom | cCom), 0, 'l');
% organism-specific uptake rate for b and c set at a finite value
modelJoint = changeRxnBounds(modelJoint, modelJoint.infoCom.EXsp(bCom | cCom, :), -5, 'l');
modelJoint = changeRxnBounds(modelJoint, modelJoint.infoCom.EXsp(bCom | cCom, :), 5, 'u');

% TEST printUptakeBoundCom to look at the uptake bound for community model
diary('printUptakeBoundCom.txt');
printUptakeBoundCom(modelJoint, 1);
diary off;

text1 = importdata('printUptakeBoundCom.txt');
text2 = importdata('refData_printUptakeBoundCom.txt');
assert(isequal(text1, text2));
delete('printUptakeBoundCom.txt');  % remove the generated file

% TEST printUptakeBoundCom with a model with host organism
% build a model with host
modelWtHost = createMultipleSpeciesModel({org1; org2}, {'Org1'; 'Org2'}, org1, 'Org3');
% get IDs
[modelWtHost.infoCom, modelWtHost.indCom] = getMultiSpeciesModelId(modelWtHost, {'Org1'; 'Org2'}, 'Org3');
% change some uptake bounds
modelWtHost = changeRxnBounds(modelWtHost, modelWtHost.infoCom.EXcom(aCom), -10, 'l');
modelWtHost = changeRxnBounds(modelWtHost, modelWtHost.infoCom.EXcom(bCom | cCom), 0, 'l');
modelWtHost = changeRxnBounds(modelWtHost, modelWtHost.infoCom.EXsp(bCom | cCom, :), -5, 'l');
modelWtHost = changeRxnBounds(modelWtHost, modelWtHost.infoCom.EXhost(bCom | cCom, :), -5, 'l');
modelWtHost = changeRxnBounds(modelWtHost, modelWtHost.infoCom.EXhost(aCom, :), 0, 'l');

diary('printUptakeBoundCom_wt_host.txt');
printUptakeBoundCom(modelWtHost, 1);
diary off;

text1 = importdata('printUptakeBoundCom_wt_host.txt');
text2 = importdata('refData_printUptakeBoundCom_wt_host.txt');
assert(isequal(text1, text2));
delete('printUptakeBoundCom_wt_host.txt');  % remove the generated file

% specify biomass reactions
modelJoint.infoCom.spBm = {'Org1BIOMASS'; 'Org2BIOMASS'};
modelJoint.indCom.spBm = findRxnIDs(modelJoint, modelJoint.infoCom.spBm);

% TEST infoCom2indCom.m
indCom = infoCom2indCom(modelJoint);  % get indCom from infoCom
assert(isequal(indCom, modelJoint.indCom))
infoCom = infoCom2indCom(modelJoint, modelJoint.indCom, true, {'Org1'; 'Org2'});  % get infoCom from indCom
assert(isequal(infoCom, modelJoint.infoCom))

switch CBT_LP_SOLVER
    case {'gurobi', 'ibm_cplex', 'glpk', 'dqqMinos', 'quadMinos'}
        feasTol = 1e-8;  % feasibility tolerance
        tol = 1e-3;  % tolerance for comparing results
    case {'mosek', 'matlab'}
        feasTol = 1e-6;  % feasibility tolerance
        tol = 1e-3;  % tolerance for comparing results
    otherwise
        feasTol = 1e-4;  % feasibility tolerance
        tol = 1e-2;  % tolerance for comparing results
end

% TEST SteadyCom
options.algorithm = 2;
options.GRtol = 1e-6;  % tolerance for max. growth rate gap
[~, result] = SteadyCom(modelJoint, options, 'feasTol', feasTol);
data = load('refData_SteadyCom', 'result');
% only the maximum growth rate must be equal. Others may differ.
assert(abs(result.GRmax - data.result.GRmax) < 1e-5)

% TEST SteadyComFVA
options.optGRpercent = [100 90 80];
options.rxnNameList = {'X_Org1'; 'X_Org2'};
[minFlux, maxFlux, ~, ~, GRvector] = SteadyComFVA(modelJoint, options, 'feasTol', feasTol);
data = load('refData_SteadyComFVA', 'minFlux', 'maxFlux', 'GRvector');

% Different solvers may give slightly different results. Give a percentage tolerance
assert(max(max(abs(minFlux - data.minFlux) ./ data.minFlux)) < tol)
assert(max(max(abs(maxFlux - data.maxFlux) ./ data.maxFlux)) < tol)
assert(max(abs(GRvector - data.GRvector) ./ data.GRvector) < tol)

% TEST SteadyComPOA
options.savePOA = ['testSteadyComPOA' filesep 'test'];
% look at the relationship between the abundance of Org1 and its exchange of b and c
options.rxnNameList = [{'X_Org1'}; modelJoint.infoCom.EXsp(bCom | cCom, 1)];
options.Nstep = 25;
[POAtable, fluxRange, Stat, GRvector] = SteadyComPOA(modelJoint, options, 'feasTol', feasTol);
data = load('refData_SteadyComPOA', 'POAtable', 'fluxRange', 'Stat', 'GRvector');
devPOA = 0;  % percentage deviation
devSt = 0;  % absolute deviation of the correlation statistics (since zeros may appear here)
for i = 1:size(POAtable, 1)
    for j = 1:size(POAtable, 2)
        if ~isempty(POAtable{i, j})
            devPOA = max(devPOA, max(max(max(abs(POAtable{i, j} - data.POAtable{i, j}) ./ abs(data.POAtable{i, j})))));
            devSt = max(devSt, max(abs(Stat(i, j).cor - data.Stat(i, j).cor)));
            devSt = max(devSt, max(abs(Stat(i, j).r2 - data.Stat(i, j).r2)));
        end
    end
end
assert(devPOA < tol)
assert(max(max(max(abs(fluxRange - data.fluxRange) ./ abs(data.fluxRange)))) < tol)
assert(devSt < tol)
assert(max(abs(GRvector - data.GRvector) ./ data.GRvector) < tol)
% delete created files
rmdir([pwd filesep 'testSteadyComPOA'], 's')

% change the directory
cd(currentDir)