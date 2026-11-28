% The COBRAToolbox: testPerformPPP.m
%
% Purpose:
%     - performPPP performs a phase plane analysis: for every sample and every pair of
%       exchange reactions (one pair per row of mets) it fixes the two exchanges at
%       0, d*s, 2*d*s, ... (step size s, direction d = -1 uptake or +1 secretion, step_num
%       steps each), maximises the objective at every grid point and stores the growth rates
%       and the bounds in ResultsAllCellLines.<sample>.phasePlane_<ex1>_<ex2>. The test uses
%       a hand-built network whose growth rate at every grid point is derived by hand
%       (BIO = min(glucose uptake, oxygen uptake / oxygen coefficient) for the uptake pair,
%       BIO = CO2 secretion for the secretion pair), two samples, both directions and both
%       naming styles of exchanges ('(e)' and '[e]').
%
% Function under test:
%     src/dataIntegration/metabotools/performPPP.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - one LP per grid point on a hand-built network; every available LP solver
%     among gurobi and glpk.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call writes the undocumented file PPP120.mat into the current folder
%       SEVERITY: cosmetic
%       TRIGGER: any call, for example performPPP(R, {'EX_glc(e)', 'EX_o2(e)'}, [2 3],
%         {'S1'}, [3 4], [-1 -1]) with R.S1.modelPruned a model with these exchanges
%       OBSERVED: (R2025a, 2026-11-25, gurobi) after each sample, save('PPP120', '-v7.3')
%         (line 69) writes the whole workspace of the function to PPP120.mat in the current
%         folder, overwriting a file of that name; the test runs the function in a temporary
%         folder and removes it
%       EXPECTED: the results only in the returned ResultsAllCellLines, as the help documents
%       LINES: 69
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPerformPPP'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});

% the solver selection is saved and restored; any global created while reading it or by the
% solver interfaces is removed at the end
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();

% the function writes PPP120.mat into the current folder (see the defect above): run it in a
% temporary folder that is removed at the end
workDir = tempname;
mkdir(workDir);
cd(workDir);

% LP optimality tolerance for growth rates that are derived by hand
tol = 1e-6;

% hand-built network: glucose and oxygen exchanges ('(e)' names), a CO2 exchange and an
% oxygen sink ('[e]' names), a glucose sink, and the biomass reaction
% BIO: glc + o2 -> co2 (sample S1) or glc + 2 o2 -> co2 (sample S2)
rxnIDs = {'EX_glc(e)'; 'EX_o2(e)'; 'EX_co2[e]'; 'DM_o2[e]'; 'DM_glc(e)'; 'BIO'};
formulasS1 = {'glc[e] <=> '; 'o2[e] <=> '; 'co2[e] <=> '; 'o2[e] -> '; 'glc[e] -> '; ...
    'glc[e] + o2[e] -> co2[e]'};
formulasS2 = formulasS1;
formulasS2{6} = 'glc[e] + 2 o2[e] -> co2[e]';
modelS1 = createModel(rxnIDs, rxnIDs, formulasS1);
modelS2 = createModel(rxnIDs, rxnIDs, formulasS2);
modelS1.lb = [-10; -20; -10; 0; 0; 0];
modelS1.ub = [10; 20; 10; 1000; 1000; 1000];
modelS1.c = [0; 0; 0; 0; 0; 1];
modelS2.lb = modelS1.lb;
modelS2.ub = modelS1.ub;
modelS2.c = modelS1.c;
results = struct();
results.S1.modelPruned = modelS1;
results.S2.modelPruned = modelS2;
samples = {'S1'; 'S2'};

% pair 1 (row 1): glucose and oxygen uptake (direction -1), steps of 2 and 3, 3 x 4 grid
% pair 2 (row 2): CO2 secretion and oxygen sink (direction +1), steps of 2 and 3, 3 x 2 grid
mets = {'EX_glc(e)', 'EX_o2(e)'; 'EX_co2[e]', 'DM_o2[e]'};
stepSize = [2, 3; 2, 3];
stepNum = [3, 4; 3, 2];
direct = [-1, -1; 1, 1];

% expected bounds: column 1 holds the steps of the first exchange, column 2 those of the
% second; both start at 0 and have max(max(stepNum)) = 4 rows, unused rows stay 0
glcUptake = [0; 2; 4];
o2Uptake = [0; 3; 6; 9];
co2Secretion = [0; 2; 4];
o2Sink = [0; 3];
expectedBoundsPair1 = [-[glcUptake; 0], -o2Uptake];
expectedBoundsPair2 = [[co2Secretion; 0], [o2Sink; 0; 0]];

for k = 1:length(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverOK
        fprintf('   Testing performPPP using %s ... \n', solvers.LP{k});

        %% two samples, both directions and both naming styles
        resultsPPP = performPPP(results, mets, stepSize, samples, stepNum, direct);

        % the models are kept and one field per pair is added; the field name is cut at '('
        % for '(e)' names (line 59) and at '[' for '[e]' names (line 57)
        assert(isequal(resultsPPP.S1.modelPruned, modelS1));
        assert(isfield(resultsPPP.S1, 'phasePlane_EX_glc_EX_o2'));
        assert(isfield(resultsPPP.S1, 'phasePlane_EX_co2_DM_o2'));
        assert(isfield(resultsPPP.S2, 'phasePlane_EX_glc_EX_o2'));
        assert(isfield(resultsPPP.S2, 'phasePlane_EX_co2_DM_o2'));

        % the bounds start at 0 and step by direction * step size (exact arithmetic)
        assert(isequal(resultsPPP.S1.phasePlane_EX_glc_EX_o2.bounds, expectedBoundsPair1));
        assert(isequal(resultsPPP.S1.phasePlane_EX_co2_DM_o2.bounds, expectedBoundsPair2));
        assert(isequal(resultsPPP.S2.phasePlane_EX_glc_EX_o2.bounds, expectedBoundsPair1));

        % uptake pair: BIO = min(glucose uptake, oxygen uptake / oxygen coefficient), the
        % surplus leaves by the sinks; the grid has stepNum(1, :) points
        expectedS1 = min(repmat(glcUptake, 1, 4), repmat(o2Uptake', 3, 1));
        expectedS2 = min(repmat(glcUptake, 1, 4), repmat(o2Uptake' / 2, 3, 1));
        growthS1 = resultsPPP.S1.phasePlane_EX_glc_EX_o2.growthRates;
        growthS2 = resultsPPP.S2.phasePlane_EX_glc_EX_o2.growthRates;
        assert(isequal(size(growthS1), [3 4]));
        assert(max(abs(growthS1(:) - expectedS1(:))) < tol);
        assert(max(abs(growthS2(:) - expectedS2(:))) < tol);

        % secretion pair: BIO = CO2 secretion, whatever goes to the oxygen sink (oxygen
        % uptake 2 * 4 + 3 = 11 stays within its bound of 20)
        expectedSecretion = repmat(co2Secretion, 1, 2);
        growthPair2S1 = resultsPPP.S1.phasePlane_EX_co2_DM_o2.growthRates;
        growthPair2S2 = resultsPPP.S2.phasePlane_EX_co2_DM_o2.growthRates;
        assert(isequal(size(growthPair2S1), [3 2]));
        assert(max(abs(growthPair2S1(:) - expectedSecretion(:))) < tol);
        assert(max(abs(growthPair2S2(:) - expectedSecretion(:))) < tol);
    end
end

% leave the solver selection as it was found and remove the temporary folder
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clear('global', newGlobals{:});
end
cd(currentDir);
rmdir(workDir, 's');
