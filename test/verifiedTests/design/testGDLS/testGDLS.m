% The COBRAToolbox: testGDLS.m
%
% Purpose:
%     - testGDLS tests the functionality of GDLS.
%
% Function under test:
%     src/design/GDLS.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on ecoli_core_model and on a hand-built toy model.
%
% Coverage exemptions:
%     None besides the lines of the defects below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Options in a structure, or no options at all, stop with an error
%       SEVERITY: error
%       TRIGGER: GDLS(model, options, options) or GDLS(model, targetRxns), once an iteration has
%         been solved
%       OBSERVED: i is only assigned by the loop over the option pairs (or the gene-set loop), so
%         the field name of gdlsSolutionStructs stops with "Unrecognized function or variable 'i'"
%       EXPECTED: the options of the structure are used, and the defaults without options
%       LINES: 298
%     - DEFECT: A single knockout cost in the model stops with an error
%       SEVERITY: error
%       TRIGGER: model.koCost with one value and no koCost option
%       OBSERVED: length(possibleKOList,1) has one input too many, which is an error
%       EXPECTED: the same cost for every candidate
%       LINES: 131
%     - DEFECT: The koCost option cannot be used
%       SEVERITY: unusable-option
%       TRIGGER: the option koCost
%       OBSERVED: without model.koCost the check on model.koCost stops with an error, a single
%         value in model.koCost fails as in the defect above, and a vector in model.koCost
%         replaces the option
%       EXPECTED: the costs of the option are used
%       LINES: 138-139, 141
%     - DEFECT: The solution values of all the designs are those of the last knockout set
%       SEVERITY: wrong-result
%       TRIGGER: more than one final design (option M = 2 on the toy model of this test), or a
%         last MILP solution that was rejected as inconsistent
%       OBSERVED: the final loop does not set model.rxnsPresent for each design, so biomass,
%         minTargetProd and maxTargetProd are those of the last knockout set that was tried: the
%         toy model reports a biomass of 10 and 10 for the designs without knockouts and with R1
%       EXPECTED: the values of each design (a biomass of 20 and 10 on the toy model)
%       LINES: 315-318
%     - DEFECT: The per-solution field name has no number
%       SEVERITY: limitation
%       TRIGGER: more than one design in an iteration (option M = 2)
%       OBSERVED: the format 'solution_%2' has no conversion, so all the designs of an iteration
%         share the field solution_ and only the last one is kept in gdlsSolutionStructs
%       EXPECTED: one field per design
%       LINES: 298-300
%
% Authors:
%     - CI integration: Laurent Heirendt April 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGDLS'));
cd(fileDir);

% require a MILP solver; skip gracefully if none is available
solvers = prepareTest('needsMILP', true);

% load model
model = getDistributedModel('ecoli_core_model.mat');

% Set conditions to anaerobic and glucose uptake of 20
model = changeRxnBounds(model, {'EX_o2(e)', 'EX_glc(e)'}, [0 - 20], 'l');

% Select reactions that can be knocked out
selectedRxns = {model.rxns{1}, model.rxns{3:5}, model.rxns{7:8}, ...
                model.rxns{10}, model.rxns{12}, model.rxns{15:16}, model.rxns{18}, ...
                model.rxns{40:41}, model.rxns{44}, model.rxns{46}, model.rxns{48:49}, ...
                model.rxns{51}, model.rxns{53:55}, model.rxns{57}, model.rxns{59:62}, ...
                model.rxns{64:68}, model.rxns{71:77}, model.rxns{79:83}, ...
                model.rxns{85:86}, model.rxns{89:95}}';

solverPkgs = {'gurobi'};

for k = 1: length(solverPkgs)

    solverOK = changeCobraSolver(solverPkgs{k}, 'MILP', 0);

    if solverOK
        fprintf(['Running testGDLS using ', solverPkgs{k}, ' ... '])
        % run GDLS
        [gdlsSolution] = GDLS(model, 'EX_succ(e)', 'minGrowth', 0.05, 'selectedRxns', selectedRxns, 'maxKO', 5, 'nbhdsz', 3);

        % check solution
        assert(length(gdlsSolution.KOs) == 5)
        assert(all(ismember(gdlsSolution.KOs, {'ACALD'; 'ALCD2x'; 'GLUDy'; 'LDH_D'; 'PFL'; 'THD2'; 'CYTBD'})))

        % print a success message
        fprintf('Done.\n');
    end
end

%% Toy model for the option branches
% The substrate s (uptake at most 10) makes biomass x by R1 (2 x), R2 (x + p) or R3 (x). The wild
% type uses R1 and needs no p. Without R1 the growth is 10, with p between 0 and 10: knocking
% out R1 is the design with the largest maximal production. Each of R1, R2 and R3 has its own gene.
changeCobraSolver(solvers.MILP{1}, 'MILP', 0);
tolToy = 1e-6; % LP feasibility tolerance
toyModel = struct();
toyModel.mets = {'s[c]'; 'x[c]'; 'p[c]'};
toyModel.rxns = {'EX_s'; 'R1'; 'R2'; 'R3'; 'BIO'; 'EX_p'};
toyModel.S = sparse([-1 -1 -1 -1 0 0; 0 2 1 1 -1 0; 0 0 1 0 0 -1]);
toyModel.lb = [-10; 0; 0; 0; 0; 0];
toyModel.ub = 1000 * ones(6, 1);
toyModel.c = [0; 0; 0; 0; 1; 0];
toyModel.b = zeros(3, 1);
toyModel.csense = 'EEE';
toyModel.osenseStr = 'max';
toyModel.genes = {'g1'; 'g2'; 'g3'};
toyModel.rules = {''; 'x(1)'; 'x(2)'; 'x(3)'; ''; ''};
toyModel.grRules = {''; 'g1'; 'g2'; 'g3'; ''; ''};
toyModel.rxnGeneMat = sparse([0 0 0; 1 0 0; 0 1 0; 0 0 1; 0 0 0; 0 0 0]);

%% Wrong calls are rejected
assert(verifyCobraFunctionError('GDLS', 'inputs', {toyModel}, ...
                                'testMessage', 'Model and target reaction(s) must be specified'));
assert(verifyCobraFunctionError('GDLS', 'inputs', {toyModel, 'EX_p', 'maxKO'}, ...
                                'testMessage', 'Invalid number of entries'));
assert(verifyCobraFunctionError('GDLS', 'inputs', {toyModel, 'notInModel'}, ...
                                'testMessage', 'notInModel not found. Double check spelling.'));
assert(verifyCobraFunctionError('GDLS', 'inputs', {toyModel, struct('maxKO', 1), struct('maxKO', 1)}, ...
                                'testMessage', 'No target reaction specified'));
assert(verifyCobraFunctionError('GDLS', 'inputs', {toyModel, 'EX_p', 'koType', 'notAType'}, ...
                                'testMessage', 'Unrecognized KO type'));

%% All reactions as candidates, and an unknown option that is only reported
unknownOptionOutput = evalc(['[toySolution, ~, toyStructs] = GDLS(toyModel, ''EX_p'', ''notAnOption'', 1, ', ...
                             '''maxKO'', 3, ''nbhdsz'', 3);']);
assert(contains(unknownOptionOutput, 'Unknown option notAnOption'));
assert(isequal(toySolution.KOs, {'R1'}));
assert(abs(toySolution.biomass - 10) < tolToy);
assert(abs(toySolution.maxTargetProd - 10) < tolToy);
assert(abs(toySolution.minTargetProd) < tolToy);

%% Gene sets, with the grRules field built when it is missing
% EX_s has no rule: the empty gene set is not a candidate.
candidates = {'EX_s'; 'R1'; 'R2'; 'R3'};
geneSetSolution = GDLS(rmfield(toyModel, 'grRules'), 'EX_p', 'koType', 'geneSets', 'selectedRxns', candidates, ...
                       'maxKO', 3, 'nbhdsz', 3);
assert(isequal(geneSetSolution.KOs, {'g1'}));
assert(abs(geneSetSolution.maxTargetProd - 10) < tolToy);

%% Genes, with the rxnGeneMat field built when it is missing
geneSolution = GDLS(rmfield(toyModel, 'rxnGeneMat'), 'EX_p', 'koType', 'genes', 'maxKO', 3, 'nbhdsz', 3);
assert(isequal(geneSolution.KOs, {'g1'}));
assert(abs(geneSolution.maxTargetProd - 10) < tolToy);

%% Knockout costs from the model: a knockout that is not needed is removed again
% The negative cost of R3 and the negative maximal cost force the MILP to knock out R3 and
% nothing else. R3 carries no flux in the wild type, so the design shrinks to no knockouts.
toyCostModel = toyModel;
toyCostModel.koCost = [1; 1; 1; -1; 1; 1];
[costSolution, costProblem] = GDLS(toyCostModel, 'EX_p', 'maxKO', -1, 'nbhdsz', 3);
assert(isequal(full(costProblem.A(end, end-5:end)), toyCostModel.koCost'));
assert(isempty(costSolution.KOs));
assert(abs(costSolution.biomass - 20) < tolToy);

%% A growth rate that no design reaches: the search stops without knockouts
noDesignSolution = GDLS(toyModel, 'EX_p', 'minGrowth', 1000);
assert(~any(noDesignSolution.int));
assert(isempty(noDesignSolution.KOs));

%% The iteration limit stops the search
[~, ~, limitedStructs] = GDLS(toyModel, 'EX_p', 'maxKO', 3, 'nbhdsz', 3, 'iterationLimit', 1);
assert(numel(fieldnames(toyStructs)) > 1);
assert(numel(fieldnames(limitedStructs)) == 1);

%% A MILP solution that flux balance does not confirm is not accepted
% A loose integrality tolerance leaves fractional knockouts in the MILP, so its objective is
% above the production that flux balance gives for the rounded knockout set; on the reference
% machine (gurobi 11) the only MILP solution is then rejected. The result is checked for
% validity only, because the MILP path depends on the solver.
intTolDefault = getCobraSolverParams('MILP', 'intTol');
changeCobraSolverParams('MILP', 'intTol', 1e-3);
looseSolution = GDLS(model, 'EX_succ(e)', 'minGrowth', 0.05, 'selectedRxns', selectedRxns, 'maxKO', 5, 'nbhdsz', 3);
changeCobraSolverParams('MILP', 'intTol', intTolDefault);
assert(numel(looseSolution.int) == numel(selectedRxns));
assert(all(ismember(looseSolution.KOs, selectedRxns)));

% change the directory
cd(currentDir)
