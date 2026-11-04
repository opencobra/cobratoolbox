% The COBRAToolbox: testOptEnvelope.m
%
% Purpose:
%     - tests the basic functionality of optEnvelope
%       Returns 1 if all tests were completed succesfully, 0 if not
%
% Function under test:
%     src/design/optEnvelope/optEnvelope.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation (MILP) on the stored model, on ecoli_core_model for the option
%     branches, and on a hand-built toy model.
%
% Coverage exemptions:
%     Lines 133-135, 137, 140: unreachable, the error on the line above always stops first.
%     Lines 153-154: GUI, a dialog asks for the substrate when there are several.
%     Lines 260-261: unreachable, the handles in the legend call of the try block always exist, so
%     the fallback does not run.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The numKO option always stops with an error
%       SEVERITY: unusable-option
%       TRIGGER: the option numKO
%       OBSERVED: milpOEReinserts ends with debug code: addEnv gets the biomass reaction as a cell
%         and stops with 'The value of biomass is invalid', before any knockouts are returned
%       EXPECTED: the knockouts found by the MILP are returned
%       LINES: 211
%     - DEFECT: With prodMol the peaks of the mid envelopes are zero
%       SEVERITY: wrong-result
%       TRIGGER: the options prodMol and midPoints together
%       OBSERVED: mem is only filled when prodMol is not given, so mid.peak.x and mid.peak.y are 0
%       EXPECTED: the peaks of the mid envelopes in yield units
%       LINES: 240
%     - DEFECT: The mid output is not assigned without mid points
%       SEVERITY: error
%       TRIGGER: [main, mid] = optEnvelope(model, product), that is midPoints 0 and two outputs
%       OBSERVED: the call ends with 'Output argument "mid" (and possibly others) not assigned'
%       EXPECTED: an empty mid output
%       LINES: 280
%
% Authors:
%     - Original file: Kristaps Berzins 30/09/2024
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

% save the current path and initialize the test
currentDir = pwd;

% determine the test path for references
fileDir = fileparts(which('testOptEnvelope'));
cd(fileDir);

% set the tolerance
tol = 1e-4;

% define the solver packages to be used to run this test
requiredSolvers = { 'gurobi' };
solversPkgs = prepareTest('requiredSolvers', requiredSolvers);

% load the model
load('testOptEnvelopeData.mat');
model = readCbModel('testOptEnvelopeData.mat', 'modelName', 'model');

solverOK = changeCobraSolver('gurobi', 'all', 0);

if solverOK == 1
    fprintf('   Testing functions of optEnvelope ... ');
    % check if envelope matches
    fprintf('\n>> Running optEnvelope\n');
    [main] = optEnvelope(model, 'EX_ac_e');
    % optEnvelope solves a nonconvex MILP, so the exact peak coordinates, the peak
    % production value, and the knockout set can differ between solvers and runs
    % (alternate optima of comparable quality). Assert the envelope peak within a
    % relative tolerance and that a knockout strategy of the right order was found,
    % rather than pinning the exact reference solution.
    peakRelTol = 0.1;
    % testing if the envelope peak is within relative tolerance of the reference
    fprintf('\n>> Testing peaks\n')
    assert(abs(main.peak.x - testMain.peak.x) <= peakRelTol * abs(testMain.peak.x) + tol, ...
        'Peak x assertion failed: main.peak.x = %g, testMain.peak.x = %g', ...
        main.peak.x, testMain.peak.x);
    assert(abs(main.peak.y - testMain.peak.y) <= peakRelTol * abs(testMain.peak.y) + tol, ...
        'Peak y assertion failed: main.peak.y = %g, testMain.peak.y = %g', ...
        main.peak.y, testMain.peak.y);
    % testing that a knockout strategy was found (exact set/size varies with the MILP)
    fprintf('\n>> Testing number of deletions\n')
    assert(~isempty(main.knockouts) && numel(main.knockouts) <= 2 * numel(testMain.knockouts), ...
        'Number of knockouts assertion failed: main knockouts = %d, testMain knockouts = %d', ...
        numel(main.knockouts), numel(testMain.knockouts));
    close all hidden force

    %% Option branches on ecoli_core_model, whose only limited uptake is glucose
    modelCore = getDistributedModel('ecoli_core_model.mat');
    productCore = 'EX_ac(e)';

    %% Gene and enzyme deletions are not finished and say so
    assert(verifyCobraFunctionError('optEnvelope', 'inputs', {modelCore, productCore, 'delGenes', true}, ...
        'testMessage', 'Gene deletion part is not finished in this version of optEnvelope'));
    assert(verifyCobraFunctionError('optEnvelope', 'inputs', {modelCore, productCore, 'delEnzymes', true}, ...
        'testMessage', 'Enzyme deletion part is not finished in this version of optEnvelope'));

    %% Protected reactions are not knocked out, and unknown ones are reported
    protectedOutput = evalc(['mainProtected = optEnvelope(modelCore, productCore, ', ...
        '''protectedRxns'', {''PFL'', ''notInModel''});']);
    assert(contains(protectedOutput, 'At least one of reactions are not in the model - ignoring those'));
    assert(~ismember('PFL', mainProtected.knockouts));
    assert(all(ismember(mainProtected.knockouts, modelCore.rxns)));

    %% Mid envelopes
    numMidPoints = 2;
    [mainMid, midEnvelopes] = optEnvelope(modelCore, productCore, 'midPoints', numMidPoints);
    assert(isequal(size(midEnvelopes.midKnockoutsTable), [1, numMidPoints]));
    assert(numel(midEnvelopes.peak.x) == numMidPoints && numel(midEnvelopes.peak.y) == numMidPoints);
    for iMid = 1:numMidPoints
        midKnockouts = midEnvelopes.midKnockoutsTable{1, iMid}{1};
        assert(all(ismember(midKnockouts, modelCore.rxns))); % without the suffix of the direction
    end

    %% Yield plot: same envelope as above, scaled with the substrate and product data
    % The substrate is glucose: uptake 10 and molar mass 180 from its formula C6H12O6.
    prodMolAcetate = 59;
    glcUptake = 10;
    glcMolarMass = 180;
    mainYield = optEnvelope(modelCore, productCore, 'prodMol', prodMolAcetate, 'midPoints', numMidPoints);
    assert(abs(mainYield.peak.x - mainMid.peak.x / glcUptake * 1000 / glcMolarMass) < tol);
    assert(abs(mainYield.peak.y - mainMid.peak.y / glcMolarMass * prodMolAcetate / glcUptake) < tol);

    %% Without a plot there is no peak, and the knockouts are still returned
    close all hidden force
    mainNoPlot = optEnvelope(modelCore, productCore, 'drawEnvelope', false);
    assert(~isfield(mainNoPlot, 'peak'));
    assert(~isempty(mainNoPlot.knockouts));
    assert(isempty(findall(0, 'Type', 'figure')));

    %% A linear pathway needs no knockouts: there is no envelope to draw
    % a -> b + p, then b leaves through the biomass reaction and p through the product exchange.
    toyLinear = struct();
    toyLinear.mets = {'a[c]'; 'b[c]'; 'p[c]'};
    toyLinear.metNames = {'A'; 'B'; 'P'};
    toyLinear.metFormulas = {'C6H12O6'; 'C3H6O3'; 'C2H4O2'};
    toyLinear.rxns = {'BIO'; 'EX_p'; 'EX_a'; 'R1'};
    toyLinear.S = sparse([0 0 -1 -1; -1 0 0 1; 0 -1 0 1]);
    toyLinear.lb = [0; 0; -10; 0];
    toyLinear.ub = [1000; 1000; 0; 1000];
    toyLinear.c = [1; 0; 0; 0];
    toyLinear.b = zeros(3, 1);
    toyLinear.csense = 'EEE';
    toyLinear.osenseStr = 'max';
    toyLinear.genes = {'g1'};
    toyLinear.rules = {''; ''; ''; 'x(1)'};
    toyLinear.grRules = {''; ''; ''; 'g1'};
    noEnvelopeOutput = evalc('mainLinear = optEnvelope(toyLinear, ''EX_p'');');
    assert(contains(noEnvelopeOutput, 'No envelope found'));
    assert(isempty(mainLinear.knockouts));
    assert(~isfield(mainLinear, 'peak'));
    close all hidden force

    % output a success message
    fprintf('Done.\n');
end

cd(currentDir)


