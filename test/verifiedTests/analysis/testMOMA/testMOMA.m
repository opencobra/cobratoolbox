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
% Authors:
%     - Adapted by MBG - 02/10/2017
%     - CI integration: Laurent Heirendt February 2017
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
solverPkgs = prepareTest('needsLP', true, 'needsQP', true, 'excludeSolvers', {'qpng','pdco', 'mosek'});
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

    assert(abs(0.8463 - sol.f) < QPtol)

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

    % output a success message
    fprintf('Done.\n');
end

%return to original directory
cd(currentDir)
