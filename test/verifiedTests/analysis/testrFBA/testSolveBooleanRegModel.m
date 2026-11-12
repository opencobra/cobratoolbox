% The COBRAToolbox: testSolveBooleanRegModel.m
%
% Purpose:
%     - testrFBA tests the SolveBooleanRegModel function and its different outputs
%
% Function under test:
%     src/analysis/rFBA/solveBooleanRegModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on the regulatory E. coli core model modelReg, and on a toy regulatory
%     model for the rule words and the state without flux.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A name that is contained in a later name of the same rule stops with an error
%       SEVERITY: error
%       TRIGGER: the rule 'g1 || g11' with the regulatory genes g1 and g11
%       OBSERVED: the names are replaced with strrep in the whole rule, so g11 becomes
%         initialState(1)1 before it is replaced itself, and eval stops with a syntax error
%       EXPECTED: the value of the rule
%       LINES: 115
%
% Author:
%     - Marouen BEN GUEBILA - 31/01/2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSolveBooleanRegModel'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true);

% solver packages
solverPkgs = solvers.LP;

% load model and test data
modelReg = getDistributedModel('modelReg.mat');
load('refData_solveBooleanRegModel.mat');

 for k = 1:length(solverPkgs)

    solverLPOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverLPOK
         %Assert
        [rFBAsol2test,finalInputs1Statestest,finalInputs2Statestest] = solveBooleanRegModel(modelReg,rFBAsol1,inputs1state,inputs2state);
        assert(isequal(rFBAsol2test,rFBAsol2))
        assert(isequal(finalInputs1Statestest,finalInputs1States))
        assert(isequal(finalInputs2Statestest,finalInputs2States))

        %% toy regulatory model: every kind of input and every kind of word in a rule

        % nutrient a[e] is available, nutrient b[e] is not; g1 and g2 control the reactions R1 and R2
        toyRxns = {'EX_a'; 'EX_b'; 'R1'; 'R2'; 'EX_c'};
        toyFormulas = {'a[e] <=> '; 'b[e] -> '; 'a[e] -> c[e]'; 'b[e] -> c[e]'; 'c[e] -> '};
        toyModel = createModel(toyRxns, toyRxns, toyFormulas, 'grRuleList', {''; ''; 'g1'; 'g2'; ''});
        toyModel = changeRxnBounds(toyModel, 'EX_a', -10, 'l');
        toyModel = changeObjective(toyModel, 'EX_c');
        toyModel.regulatoryGenes = {'g1'; 'g2'; 'g3'; 'g4'; 'g5'; 'g6'};
        toyModel.regulatoryInputs1 = {'a[e]'; 'b[e]'};
        toyModel.regulatoryInputs2 = {'R1'; 'R2'};

        % fixed values, a gene, the two kinds of input, and a word without meaning that is dropped
        toyModel.regulatoryRules = {'true'; 'false'; '~g1'; 'a[e] && ~b[e]'; 'R1 || R2'; 'g2 notAName'};

        % g1 is on: flux through R1, which sets the state of the second kind of input
        [finalState, inputs1, inputs2] = solveBooleanRegModel(toyModel, [1; 1; 0; 0; 0; 0], [0; 0], [0; 0]);
        assert(isequal(inputs1, [1; 0]));
        assert(isequal(inputs2, [1; 0]));

        % the rules are evaluated with the given states of the inputs, not with the new ones
        assert(isequal(finalState, [1; 0; 0; 0; 0; 1]));
        finalState = solveBooleanRegModel(toyModel, [0; 0; 0; 0; 0; 0], [1; 0], [0; 1]);
        assert(isequal(finalState, [1; 0; 1; 1; 1; 0]));

        % all genes off: no reaction carries flux, so no reaction input is on
        [~, ~, inputs2] = solveBooleanRegModel(toyModel, [0; 0; 0; 0; 0; 0], [1; 0], [0; 0]);
        assert(isequal(inputs2, [0; 0]));
    end

    fprintf('Done.\n');
 end

 % change the directory
 cd(currentDir)
