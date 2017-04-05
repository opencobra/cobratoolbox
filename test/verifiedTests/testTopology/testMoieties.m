% The COBRAToolbox: testMoieties.m
%
% Purpose:
%     - testMoieties tests the functionality of conserved moities tools
%       and compares it to expected data.
%     - testMoieties identifies conserved moieties in metabolic networks by graph
%       theoretical analysis of atom transition networks.
%
% Authors:
%     - Sylvain Arreckx March 2017
%

% define global paths
global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMoieties'));
cd(fileDir);

% Load reference data
load('refData_moieties.mat')

% Load the dopamine synthesis network
load('DAS.mat')

% Predicted atom mappings from DREAM (http://selene.princeton.edu/dream/)
rxnfileDir = [CBTDIR filesep 'tutorials' filesep 'moieties' filesep 'Data' filesep 'AlternativeAtomMappingFiles'];

% Generate atom transition network
ATN = buildAtomTransitionNetwork(model, rxnfileDir);
assert(all(all(ATN.A == ATN0.A)), 'Atom transition network does not match reference.')

% Identify conserved moieties
[L, Lambda, moietyFormulas, moieties2mets, moieties2vectors, atoms2moieties] = identifyConservedMoieties(model, ATN);
assert(all(all(L == L0)), 'Moiety matrix does not match reference.')
assert(all(all(Lambda == Lambda0)), 'Moiety graph does not match reference.')

% Classify moieties
types = classifyMoieties(L, model.S);
assert(all(strcmp(types, types0)), 'Moiety classifications do not match reference.')

% Decompose moiety vectors
rbool = ismember(model.rxns, ATN.rxns);  % True for reactions included in ATN
mbool = any(model.S(:, rbool), 2);  % True for metabolites in ATN reactions
N = model.S(mbool, rbool);

solverOK = changeCobraSolver('gurobi6', 'MILP', 0);
if solverOK
    fprintf(' -- Running testMoieties using the solver interface: gurobi6 ... ');

    D = decomposeMoietyVectors(L, N);
    assert(all(all(D == D0)), 'Decomposed moiety matrix does not match reference.')

    % Build elemental matrix for the dopamine network
    [E, elements] = constructElementalMatrix(model.metFormulas, model.metCharges);

    % Estimate chemical formulas of decomposed moieties
    [decomposedMoietyFormulas, M] = estimateMoietyFormulas(D, E, elements);
    assert(all(strcmp(decomposedMoietyFormulas, decomposedMoietyFormulas0)), 'Estimated formulas of decomposed moieties do not match reference.')

    fprintf('Done\n');
end

cd(currentDir)
