% The COBRAToolbox: testTest4HumanFctExt.m
%
% Purpose:
%     - Tests the testATPYieldFromCsources and test4HumanFctExt functions
%     - The branches of test4HumanFctExt depend on which reactions of its fixed vocabulary a model
%       holds: Recon1 reaches one side of each branch, and two crafted models reach the other. Both
%       crafted models are built here from the reaction and metabolite names in the function. Their
%       named reactions have no stoichiometry, so an objective value is fixed by the bounds alone.
%
% Function under test:
%     src/reconstruction/modelGeneration/test4HumanFctExt.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation: Recon1 (the reference data was generated with it) and crafted models.
%
% Coverage exemptions:
%     The objective of the tests below is a reaction that the function has just added or set with
%     changeObjective, so that model.c is never zero and the NaN branch is dead code.
%     Lines 544, 559, 573, 587, 601, 615, 629, 643, 657, 671, 685, 699, 713, 727: dead NaN branch.
%     Lines 741, 755, 769, 783, 798, 860, 875, 905, 920, 935, 950, 965, 980, 995: dead NaN branch.
%     Lines 1010, 1025, 1040, 1057, 1074, 1091, 1108, 1123, 1138, 1153, 1168, 1183, 1197, 1214: dead NaN branch.
%     Lines 1230, 1263, 1278, 1293, 1308, 1322, 1338, 1352, 1366, 1382, 1396, 1410, 1424, 1438: dead NaN branch.
%     Lines 1452, 1467, 1481, 1495, 1509, 1523, 1541, 1557, 1573, 1589, 1605, 1621, 1638, 1653: dead NaN branch.
%     Lines 1667, 1683, 1699, 1715, 1729, 1747, 1765, 1779, 1793, 1807, 1825, 1839, 1853, 1869: dead NaN branch.
%     Lines 1885, 1899, 1915, 1929, 1943, 1961, 1977, 1995, 2013, 2030, 2044, 2062, 2076, 2090: dead NaN branch.
%     Lines 2104, 2120, 2134, 2149, 2163, 2177, 2191, 2205, 2219, 2233, 2247, 2261, 2275, 2289: dead NaN branch.
%     Lines 2303, 2317, 2331, 2347, 2361, 2375, 2389, 2403, 2417, 2432, 2446, 2460, 2474, 2488: dead NaN branch.
%     Lines 2502, 2516, 2530, 2544, 2558, 2573, 2586, 2600, 2614, 2630, 2644, 2658, 2687, 2701: dead NaN branch.
%     Lines 2715, 2731, 2748, 2762, 2776, 2790, 2804, 2818, 2842, 2856, 2870, 2884, 2898, 2916: dead NaN branch.
%     Lines 2931, 2946, 2961, 2975, 2991, 3005, 3020, 3038, 3056, 3071, 3085, 3099, 3117, 3135: dead NaN branch.
%     Lines 3153, 3169, 3183, 3212, 3226, 3240, 3255, 3269, 3283, 3298, 3313, 3328, 3343, 3367: dead NaN branch.
%     Lines 3383, 3398, 3412, 3426, 3444, 3459, 3473, 3487, 3501, 3515, 3535, 3551, 3567, 3583: dead NaN branch.
%     Lines 3601, 3615, 3630, 3645, 3659, 3676, 3690, 3704, 3719, 3733, 3748, 3766, 3781, 3796: dead NaN branch.
%     Lines 3812, 3828, 3844, 3893, 3915, 3931, 3947, 3963, 3979, 3995, 4011, 4030, 4046, 4065: dead NaN branch.
%     Lines 4082, 4099, 4115, 4148, 4164, 4180, 4196, 4225, 4244, 4264, 4280, 4296, 4312, 4328: dead NaN branch.
%     Lines 4344, 4360, 4379, 4396, 4412, 4445, 4461, 4477, 4493, 4509, 4525, 4545, 4561, 4594: dead NaN branch.
%     Lines 4608, 4622, 4638, 4657, 4671, 4685, 6852, 6868, 6885, 6903, 6920, 6938, 6956, 6974: dead NaN branch.
%     Lines 6992, 7010, 7028, 7046, 7064, 7082, 7100, 7118, 7136, 7154, 7172, 7190, 7208, 7225: dead NaN branch.
%     Lines 7243, 7260, 7278, 7295, 7312, 7329, 7377, 7393, 7409, 7425, 7441, 7458, 7475, 7496: dead NaN branch.
%     Lines 7517, 7538, 7555, 7572, 7621, 7638, 7655, 7672, 7689, 7703, 7717, 7731, 7749, 7763: dead NaN branch.
%     Lines 7777, 7793, 7808, 7826, 7841, 7855, 7869, 7883, 7913, 7927, 7942, 7956, 7970, 7984: dead NaN branch.
%     Lines 7998, 8012, 8026, 8040, 8058, 8072: dead NaN branch.
%     addSinkReactions calls addReaction without the duplicate check, so that rxnsInModel is always -1.
%     Lines 1738, 1756, 1816, 2053, 3029, 3047, 3435, 3884, 4056, 4255, 4536: dead branch of an existing reaction.
%     Lines 483-486: 'if 0' block.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: the option 'IECOri' stops with an error for every model
%       SEVERITY: unusable-option
%       TRIGGER: test4HumanFctExt(model, 'IECOri')
%       OBSERVED: the second test of the block has no call of optimizeCbModel, so that line 4715 reads
%         FBA after 'clear FBA': 'Reference to a cleared variable FBA'. Nothing after it can run.
%       EXPECTED: each test of the block is solved and reported
%       LINES: 4694-5581
%     - DEFECT: the documented option 'IECori' is not recognised
%       SEVERITY: unusable-option
%       TRIGGER: test4HumanFctExt(model, 'IECori'), or any other value that no block compares with
%       OBSERVED: the help text says IECori and the code compares with 'IECOri', so that no block runs
%         and the assignment to TestSolutionName stops with an error
%       EXPECTED: the documented option works, and an unknown option gets a clear message
%       LINES: 8385
%     - DEFECT: three tests stop with an error when their objective reaction is missing
%       SEVERITY: error
%       TRIGGER: a model without ABTArm or METAT, or without DPCOAK when the LP of that test is
%         feasible, with test 'all' or 'Harvey'
%       OBSERVED: model.c stays zero, optimizeCbModel returns an empty f, and the assignment to
%         TestSolution fails: these three tests lack the check for an objective that the others have
%       EXPECTED: NaN for that test, as in the other tests
%       LINES: 8230, 8281, 8292
%     - DEFECT: an error when no test carried flux
%       SEVERITY: error
%       TRIGGER: test4HumanFctExt(model, 'IEC') on a model with no objective reaction of that block
%       OBSERVED: TestedRxns stays [], and intersect stops because a cell is compared with a double
%       EXPECTED: an empty list of tested reactions and a percentage of 0
%       LINES: 8387
%     - DEFECT: the diary is opened in the current folder and never closed
%       SEVERITY: cosmetic
%       TRIGGER: every call
%       OBSERVED: Test4Functions_diary.txt is written to the current folder, and the diary stays on
%         after the function returns; this test works in a temporary folder and closes the diary
%       EXPECTED: no file is left behind and the diary is closed
%       LINES: 64
%
% Authors:
%     - Original test, COBRA Toolbox contributors.
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

global CBTDIR

% save current directory
currentDir = pwd;

fileDir = fileparts(which('testTest4HumanFctExt'));
cd(fileDir)


solverPkgs = prepareTest('requireOneSolverOf', {'ibm_cplex','gurobi'});

% the functions under test write a diary and solver logs to the current folder
outputDir = tempname;
mkdir(outputDir);
cd(outputDir);

% set a tolerance
tol = 1e-4;

%Configure model for test
fileName= 'Recon1.0model.mat'; % if using Recon 3 model, amend filename.
model = getDistributedModel(fileName);
model.csense(1:size(model.S,1),1) = 'E';

% Set the lower bounds on all biomass reactions and sink/demand reactions to zero.
model.lb(find(ismember(model.rxns, 'biomass_reaction'))) = 0;
model.lb(find(ismember(model.rxns, 'biomass_maintenance_noTrTr'))) = 0;
model.lb(find(ismember(model.rxns, 'biomass_maintenance'))) = 0;
DMs = strmatch('DM_', model.rxns);
model.lb(DMs) = 0;
Sinks = strmatch('sink_', model.rxns);
model.lb(Sinks) = 0;
model.ub(Sinks) = 1000;

for k = 1:numel(solverPkgs.LP)
    fprintf('Testing HumanFctExt with solver %s\n',solverPkgs.LP{k});
    changeCobraSolver(solverPkgs.LP{k});
    
    % run testATPYieldFromCsources
    [Table_csourcesOri, TestedRxnsC, Perc] = testATPYieldFromCsources(model, 'Recon3');

    % load reference data
    load(fullfile(fileDir, 'refData_testATPYieldFromCsources.mat'));

    % tests
    for i = 1:size(Table_csourcesOri, 1)
        for j = 1:size(Table_csourcesOri, 2)
            if ~isempty(Table_csourcesOri{i, j}) && ~isempty(ref_Table_csourcesOri{i, j})
                if ~isempty(Table_csourcesOri{i, j}) && ~isempty(ref_Table_csourcesOri{i, j}) && ~isnumeric(Table_csourcesOri{i, j}) && ~isnumeric(ref_Table_csourcesOri{i, j})
                    fprintf('%i - %i: %s : %s\n', i, j, Table_csourcesOri{i, j}, ref_Table_csourcesOri{i, j});
                    assert(isequal(Table_csourcesOri{i, j}, ref_Table_csourcesOri{i, j}));
                else
                    fprintf('%i - %i: %1.2f : %1.2f\n', i, j, Table_csourcesOri{i, j}, ref_Table_csourcesOri{i, j});
                    if i ~= 8 && j ~= 3
                        if isnan(Table_csourcesOri{i, j})
                            %for backward compatibility now that optimal
                            %objective for an infeasible problem is Nan
                            %rather than zero.
                            Table_csourcesOri{i, j}=0;
                        end
                        bool = abs(Table_csourcesOri{i, j} - ref_Table_csourcesOri{i, j}) < tol;
                        if bool==0
                            pause(0.1)
                        end
                        assert(bool);
                    end
                end
            end
        end
    end

    % Note: the reactions cannot be tested, as they depend on the tolerance of the machine and the solver;
    %       the tested reacions are selected based on the solution vector itself
    % assert(isequal(sort(TestedRxnsC), sort(ref_TestedRxnsC)))
    % assert(isequal(Perc, ref_Perc))

    % run test4HumanFctExt
    [TestSolutionOri, TestSolutionNameClosedSinks, TestedRxnsClosedSinks, PercClosedSinks] = test4HumanFctExt(model, 'all', 0);
    diary off

    % load reference data
    load(fullfile(fileDir, 'refData_testTest4HumanFctExt.mat'));

    % test all solutions
    for i = 1:length(TestSolutionOri)
        if ~isnan(TestSolutionOri(i)) && ~isnan(ref_TestSolutionOri(i))
            assert(abs(TestSolutionOri(i) - ref_TestSolutionOri(i)) < tol)
        end
    end

    % test the reaction names
    for i = 1:length(TestSolutionNameClosedSinks)
        assert(isequal(TestSolutionNameClosedSinks{i, 1}, ref_TestSolutionNameClosedSinks{i, 1}))
    end

    % Note: the reactions cannot be tested, as they depend on the tolerance of the machine and the solver;
    %       the tested reacions are selected based on the solution vector itself
    % TestedRxns = unique([TestedRxnsC; TestedRxnsClosedSinks]);
    % TestedRxnsX = intersect(model.rxns,TestedRxns);
    % assert(isequal(TestedRxnsClosedSinks, ref_TestedRxnsClosedSinks))
    % assert(isequal(PercClosedSinks, ref_PercClosedSinks))
    % assert(isequal(TestedRxns, ref_TestedRxns))
    % assert(isequal(TestedRxnsX, ref_TestedRxnsX))
end

%% crafted models: the vocabulary of the function
% Recon1 reaches one side of each branch that asks whether a named reaction is in the model. The
% models below reach the other side. Their reactions and metabolites are the ones the function names.
changeCobraSolver(solverPkgs.LP{1}, 'LP', 0);
fbaTol = 1e-6; % the objective values are bounds of the LP, so the feasibility tolerance applies

functionLines = strsplit(fileread(which('test4HumanFctExt')), newline);
functionCode = strjoin(functionLines(~startsWith(strtrim(functionLines), '%')), newline);
rxnPatterns = {'ismember\(model(?:Ori)?\.rxns,''([^'']+)''\)', 'changeObjective\(model,''([^'']+)''', ...
               'changeRxnBounds\(model,''([^'']+)''', 'strcmp\(''([^'']+)'',model\.rxns\)'};
namedRxns = {};
for i = 1:numel(rxnPatterns)
    tokens = regexp(functionCode, rxnPatterns{i}, 'tokens');
    namedRxns = [namedRxns, [tokens{:}]];
end
tokens = regexp(functionCode, '(?:RPMI_composition|mediumCompounds|ions)\s*=\s*\{([^}]*)\}', 'tokens');
tokens = regexp(strjoin([tokens{:}], ','), '''([^'']+)''', 'tokens');
namedRxns = [namedRxns, [tokens{:}]];
tokens = regexp(functionCode, 'addSinkReactions\(model,\{([^}]*)\}', 'tokens');
tokens = regexp(strjoin([tokens{:}], ','), '''([^'']+)''', 'tokens');
namedMets = [tokens{:}];
tokens = regexp(functionCode, 'addDemandReaction\(model,''([^'']+)''', 'tokens');
namedMets = unique([namedMets, [tokens{:}]]');
% the sinks of these metabolites are added by the function itself
namedRxns = setdiff(unique(namedRxns'), strcat('sink_', namedMets));

% every metabolite has a free source, so that a sink added by the function can carry flux
% Three tests have no branch for a missing objective reaction (see the known defects), so that their
% reactions are in every crafted model.
requiredRxns = {'ABTArm'; 'DPCOAK'; 'METAT'};
namedRxns = setdiff(namedRxns, requiredRxns);
nNamedMets = numel(namedMets);
modelNoNamedRxn = struct();
modelNoNamedRxn.mets = namedMets;
modelNoNamedRxn.metNames = namedMets;
modelNoNamedRxn.rxns = strcat('free_', cellstr(num2str((1:nNamedMets)', '%d')));
modelNoNamedRxn.rxnNames = modelNoNamedRxn.rxns;
modelNoNamedRxn.S = speye(nNamedMets);
modelNoNamedRxn.lb = -1000 * ones(nNamedMets, 1);
modelNoNamedRxn.ub = 1000 * ones(nNamedMets, 1);
modelNoNamedRxn.c = zeros(nNamedMets, 1);
modelNoNamedRxn.b = zeros(nNamedMets, 1);
modelNoNamedRxn.csense = repmat('E', nNamedMets, 1);
modelNoNamedRxn.osenseStr = 'max';
modelNoNamedRxn = addFreeRxns(modelNoNamedRxn, requiredRxns, -1000, 1000);

% the named reactions have no stoichiometry: each is free within its own bounds
modelAllRxns = addFreeRxns(modelNoNamedRxn, namedRxns, -1000, 1000);

%% a model with every named reaction: the branches that solve an LP
[solutionAll, namesAll, testedAll, percentAll] = test4HumanFctExt(modelAllRxns, 'all', 0);
diary off

% the list of functions does not depend on the model: same names, in the same order, as with Recon1
assert(isequal(size(namesAll), [numel(ref_TestSolutionOri), 2]));
assert(isequal(namesAll(:, 1), ref_TestSolutionNameClosedSinks(:, 1)));
assert(isequaln(cell2mat(namesAll(:, 2)), solutionAll));
% the reactions that carried flux are model reactions, and the percentage counts them
assert(~isempty(testedAll) && all(ismember(testedAll, modelAllRxns.rxns)));
assert(abs(percentAll - numel(testedAll) * 100 / numel(modelAllRxns.rxns)) < 1e-9);

% a free objective reaction reaches its upper bound
valueOf = @(names, solution, name) solution(strcmp(names(:, 1), name));
assert(abs(valueOf(namesAll, solutionAll, 'Human Recon 1 test human biomass') - 1000) < fbaTol);
assert(abs(valueOf(namesAll, solutionAll, 'ATP production via electron transport chain') - 1000) < fbaTol);
assert(abs(valueOf(namesAll, solutionAll, 'gthrd reduces h2o2, GTHP (c) ') - 1000) < fbaTol);
% a sink added with an upper bound of 100 and fed by a free source reaches 100
assert(abs(valueOf(namesAll, solutionAll, 'adrnl(c) -> 34dhoxpeg(c)') - 100) < fbaTol);

% Tier 5 reference, first run 2026-11-04 with gurobi, not derived independently: every objective is
% an upper bound (100 or 1000) or a sum of two of them, and one problem has no solution: the forced
% uptake of a phosphocreatine that nothing in the crafted model consumes
assert(nnz(isnan(solutionAll)) == 1);
assert(nnz(abs(solutionAll - 100) < fbaTol) == 301);
assert(nnz(abs(solutionAll - 1000) < fbaTol) == 130);
assert(nnz(abs(solutionAll - 1100) < fbaTol) == 26);
assert(nnz(abs(solutionAll - 2000) < fbaTol) == 2);

%% a model with no named reaction: the branches that report NaN
[solutionNone, namesNone, testedNone, percentNone] = test4HumanFctExt(modelNoNamedRxn, 'all', 0);
diary off

% one test has a different name when its reaction GALNTg is missing
renamedTest = find(~strcmp(namesNone(:, 1), namesAll(:, 1)));
assert(isscalar(renamedTest) && startsWith(namesNone{renamedTest, 1}, 'Ser/Thr[g] + udpacgal[g] -> sTn_antigen[g]'));
% only the tests whose objective is a sink added by the function, or a required reaction, have a value
hasValue = ~isnan(solutionNone);
assert(any(hasValue) && any(~hasValue));
assert(all(abs(solutionNone(hasValue) - 100) < fbaTol | abs(solutionNone(hasValue) - 1000) < fbaTol));
assert(isnan(valueOf(namesNone, solutionNone, 'Human Recon 1 test human biomass')));
assert(isnan(valueOf(namesNone, solutionNone, 'ATP production via electron transport chain')));
assert(isnan(valueOf(namesNone, solutionNone, 'glucose to lactate conversion')));
assert(abs(valueOf(namesNone, solutionNone, 'adrnl(c) -> 34dhoxpeg(c)') - 100) < fbaTol);
assert(all(ismember(testedNone, modelNoNamedRxn.rxns)));
assert(abs(percentNone - numel(testedNone) * 100 / numel(modelNoNamedRxn.rxns)) < 1e-9);

%% default arguments, and closing the sinks
% fru(c) is fed only by a sink that may run backwards at a rate of 5, so that the flux into the sink
% of fru(c) that the function adds is 5 while the sink is open and 0 once it is closed
modelClosableSink = modelNoNamedRxn;
modelClosableSink.lb(strcmp(modelClosableSink.mets, 'fru(c)')) = 0;
modelClosableSink.ub(strcmp(modelClosableSink.mets, 'fru(c)')) = 0;
modelClosableSink = addReaction(modelClosableSink, 'sink_supply(c)', 'metaboliteList', {'fru(c)'}, ...
    'stoichCoeffList', -1, 'lowerBound', -5, 'upperBound', 0, 'printLevel', 0);
sorbitolTest = 'sbt_D(c) -> fru(c)/sorbitol pathway';

[solutionDefault, namesDefault] = test4HumanFctExt(modelClosableSink);
diary off
solutionOpen = test4HumanFctExt(modelClosableSink, 'all');
diary off
solutionClosed = test4HumanFctExt(modelClosableSink, 'all', 1);
diary off
assert(abs(valueOf(namesDefault, solutionDefault, sorbitolTest) - 5) < fbaTol);
assert(isequaln(solutionOpen, solutionDefault));
assert(abs(valueOf(namesDefault, solutionClosed, sorbitolTest)) < fbaTol);

%% one group of functions at a time
% 'all' is 'Recon1', then 'IEC', then a third group that has no option of its own
[solutionRecon1, namesRecon1] = test4HumanFctExt(modelNoNamedRxn, 'Recon1');
diary off
% (one reaction that carries flux is needed for 'IEC', see the known defects)
modelOneIECRxn = addFreeRxns(modelNoNamedRxn, {'EX_lac-L(e)'}, -1000, 1000);
[solutionIEC, namesIEC] = test4HumanFctExt(modelOneIECRxn, 'IEC');
diary off
nRecon1 = numel(solutionRecon1);
nIEC = numel(solutionIEC);
assert(nRecon1 + nIEC < numel(solutionAll));
assert(isequal(namesRecon1(:, 1), namesNone(1:nRecon1, 1)));
assert(isequal(namesIEC(:, 1), namesNone(nRecon1 + (1:nIEC), 1)));
assert(isequaln(solutionRecon1, solutionNone(1:nRecon1)));

%% the base medium resets exchange bounds, and the electron transport test needs a capacity of 1
% an exchange that is forced to run at a negative rate is opened by the base medium of 'Recon1'
modelBaseMedium = addFreeRxns(modelNoNamedRxn, {'EX_lac-L(e)'; 'CYOR-u10m'; 'NADH2-u10m'; 'DM_atp(c)'}, -2, -1);
modelBaseMedium.lb(end-2:end) = 0;
modelBaseMedium.ub(end-2:end) = 0.5;
[solutionIEC, namesIEC] = test4HumanFctExt(modelBaseMedium, 'IEC');
diary off
lactateTest = 'glucose to lactate conversion';
assert(abs(valueOf(namesIEC, solutionIEC, lactateTest) + 1) < fbaTol);
[solutionMedium, namesMedium] = test4HumanFctExt(modelBaseMedium, 'all');
diary off
assert(abs(valueOf(namesMedium, solutionMedium, lactateTest) - 1) < fbaTol);
% the capacity of 0.5 is below the rate of 1 that the test imposes, so that it has no value
assert(isnan(valueOf(namesMedium, solutionMedium, 'ATP production via electron transport chain')));

%% Harvey: blood compartment exchanges count as extracellular, and there is no base medium
modelHarvey = addFreeRxns(modelNoNamedRxn, {'EX_lac-L[bc]'}, -1000, 1000);
[solutionHarvey, namesHarvey] = test4HumanFctExt(modelHarvey, 'Harvey');
diary off
assert(isequal(namesHarvey(:, 1), namesNone(:, 1)));
assert(abs(valueOf(namesHarvey, solutionHarvey, lactateTest) - 1000) < fbaTol);
% without that option the name is not recognised
[solutionNotHarvey, namesNotHarvey] = test4HumanFctExt(modelHarvey, 'all');
diary off
assert(isnan(valueOf(namesNotHarvey, solutionNotHarvey, lactateTest)));

% remove all log files
delete '*.log'
delete '*.txt'

% change back to original directory and remove the output folder
cd(currentDir)
rmdir(outputDir, 's');

function model = addFreeRxns(model, rxnNames, lowerBound, upperBound)
% Appends reactions without stoichiometry to a crafted model.
nNew = numel(rxnNames);
model.rxns = [model.rxns; rxnNames(:)];
model.rxnNames = [model.rxnNames; rxnNames(:)];
model.S = [model.S, sparse(size(model.S, 1), nNew)];
model.lb = [model.lb; lowerBound * ones(nNew, 1)];
model.ub = [model.ub; upperBound * ones(nNew, 1)];
model.c = [model.c; zeros(nNew, 1)];
end
