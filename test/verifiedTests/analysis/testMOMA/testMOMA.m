% The COBRAToolbox: testMOMA.m
%
% Purpose:
%     - tests the functions of MOMA and linearMOMA based on the paper
%       "Analysis of optimality in natural and perturbed metabolic networks"
%       (http://www.pnas.org/content/99/23/15112.full)
%       MOMA employs quadratic programming to identify a point in flux space,
%       which is closest to the wild-type point, compatibly with the gene deletion constraint.
%       In other words, through MOMA, we test the hypothesis that the real
%       knockout steady state is better approximated by the flux minimal
%       response to the perturbation than by the optimal one
%
% Function under test:
%     src/analysis/MOMA/MOMA.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation (QP and LP) on ecoli_core_model.
%
% Coverage exemptions:
%     Line 120: unreachable, the statement `global CBT_LP_PARAMS` above it always creates the variable, so the exist check is always true.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Models with different reaction sets stop with an error
%       SEVERITY: error
%       TRIGGER: MOMA(model, removeRxns(model, 'ACt2r'), 'max', false, 0), a deletion model that
%         lacks a reaction of the wild type model
%       OBSERVED: the solution vectors of both models are subtracted without matching their
%         reactions, which stops with "Arrays have incompatible sizes for this operation"
%       EXPECTED: a solution, since the help says that the two reaction sets do not have to be
%         equal as long as there is at least one reaction in common
%       LINES: 243
%
% Authors:
%     - Adapted by MBG - 02/10/2017
%     - CI integration: Laurent Heirendt February 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
% Note:
%     - A valid QP solver must be available

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMOMA'));
cd(fileDir);

% load model
model = getDistributedModel('ecoli_core_model.mat');

% test solver packages
%useIfAvailable = {'tomlab_cplex','ibm_cplex','pdco'}; %TODO get PDCO
%working for MOMA
useIfAvailable = {'tomlab_cplex','ibm_cplex'};
% test solver packages
solverPkgs = prepareTest('needsLP', true, 'needsQP', true, 'useSolversIfAvailable', useIfAvailable, 'excludeSolvers', {'qpng', 'mosek','dqqMinos','pdco'});
% Note: On Linux, version > 8.0.+ has issues

% define solver tolerances
QPtol = 0.02;
LPtol = 0.0001;

for k = 1:length(solverPkgs.QP)
    % select the same solver for QP and LP (if available)
    if ~any(ismember(solverPkgs.QP{k},solverPkgs.LP))
        lpSolver = solverPkgs.LP{1};
    else
        lpSolver = solverPkgs.QP{k};
    end
    fprintf(' -- Running testMOMA using the solver %s for QP and %s for LP ... ', solverPkgs.QP{k}, lpSolver);

    solverQPOK = changeCobraSolver(solverPkgs.QP{k}, 'QP', 0);
    solverLPOK = changeCobraSolver(lpSolver, 'LP', 0);


    % test deleteModelGenes
    [modelOut, hasEffect, constrRxnNames, deletedGenes] = deleteModelGenes(model, 'b3956'); % gene for reaction PPC

    % run MOMA
    sol = MOMA(model, modelOut);

    if strcmp(lpSolver,'pdco')
        disp(0.8392 - sol.f)
    end
    assert(abs(0.8392- sol.f) < QPtol)

    % run MOMA with minNormFlag
    sol = MOMA(model, modelOut, 'max', 0, true);

    assert(abs(sol.f - 0.8392) < QPtol)

    % run linearMOMA
    sol = linearMOMA(model, modelOut);

    assert(abs(0.8608 - sol.f) < LPtol)


    %run linear moma with minimal fluxes
    solMin = linearMOMA(model, modelOut,'max',1);
    assert(abs(0.8608 - solMin.f) < LPtol)

    %We know that at least in this case, the flux sum is actually
    %smaller.
    assert(sum(abs(sol.x)) > sum(abs(solMin.x)))

    % the wild type optimum, for the sections below
    solFBA = optimizeCbModel(model, 'max');
    ppcIndex = findRxnIDs(model, 'PPC');

    %% the original formulation, minNorm = 0: both flux vectors are chosen by the QP

    [solDel, solWT, totalFluxDiff, solStatus] = MOMA(model, modelOut, 'max', false, 0);
    assert(solStatus == 1 && solDel.stat == 1);

    % the same growth as with the two-step formulation, and the deleted reaction carries no flux
    assert(abs(solDel.f - 0.8392) < QPtol);
    assert(abs(solDel.x(ppcIndex)) < LPtol);

    % both vectors are feasible; the wild type one keeps the optimal objective
    assert(norm(modelOut.S * solDel.x) < LPtol && norm(model.S * solWT.x) < LPtol);
    assert(all(solDel.x >= modelOut.lb - LPtol) && all(solDel.x <= modelOut.ub + LPtol));
    assert(abs(model.c' * solWT.x - solFBA.f) < LPtol);
    assert(abs(totalFluxDiff - sum((solWT.x - solDel.x).^2)) < LPtol);

    % the QP picks the wild type optimum closest to the deletion strain, so its distance is at most
    % that from the one wild type optimum of the two-step formulation
    [~, ~, totalFluxDiffNorm] = MOMA(model, modelOut, 'max', false);
    assert(totalFluxDiff <= totalFluxDiffNorm + QPtol);

    %% minimising the objective: the constraint on the wild type objective is reversed

    [~, solWTMin, ~, solStatus] = MOMA(model, modelOut, 'min', false, 0);
    assert(solStatus == 1);
    assert(abs(model.c' * solWTMin.x) < LPtol);

    %% the objective tolerance of the LP parameters rounds the wild type objective

    % with objTol = 1e-3 the objective is 0.873, and the wild type flux moves to that lower value
    % because it is closer to the deletion strain
    global CBT_LP_PARAMS
    savedLPParams = CBT_LP_PARAMS;
    CBT_LP_PARAMS.objTol = 1e-3;
    [~, solWTRounded] = MOMA(model, modelOut, 'max', false, 0);
    CBT_LP_PARAMS = savedLPParams;
    assert(abs(model.c' * solWTRounded.x - floor(solFBA.f / 1e-3) * 1e-3) < LPtol);

    %% verbose output

    printed = evalc('MOMA(model, modelOut, ''max'', true, 0);');
    assert(contains(printed, 'Solving wild type FBA: 72 constraints 95 variables'));
    assert(contains(printed, 'Solving MOMA: 240 constraints 285 variables'));

    %% an infeasible wild type problem gives a warning and no deletion solution

    lastwarn('');
    [solDel, solWT] = MOMA(changeRxnBounds(model, 'ATPM', 1000, 'l'), modelOut);
    assert(contains(lastwarn, 'Wild type FBA problem is infeasible or unconstrained'));
    assert(solWT.stat ~= 1);
    assert(solDel.stat == -1 && isempty(solDel.x) && isempty(solDel.f));

    %% two models without a common reaction are refused

    noCommonModel = struct('S', 1, 'rxns', {{'notInTheModel'}});
    assert(verifyCobraFunctionError('MOMA', 'inputs', {model, noCommonModel}, ...
                                    'testMessage', 'No common rxns in the models'));

    % output a success message
    fprintf('Done.\n');
end

%return to original directory
cd(currentDir)
