% The COBRAToolbox: testcomputeFluxSplits.m
%
% Purpose:
%     - tests the basic functionality of computeFluxSplits
%       Tests 1 optional input with 3 possibilities: coeffSign=[] or 0 or 1
%       returns 1 if all tests were completed succesfully, 0 if not
%
% Function under test:
%     src/dataIntegration/metabotools/computeFluxSplits.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - the flux vector comes from FBA on Recon2.0; the default input is checked on a toy matrix.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Original file: Diana El Assal 03/08/2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% % save the current path
currentDir = pwd;

% % initialize the test
fileDir = fileparts(which('testComputeFluxSplits'));
cd(fileDir);
global CBTDIR

% require an LP solver; skip gracefully if none is available
prepareTest('needsLP', true);

% define the solver packages to be used to run this test
solverPkgs = {'gurobi', 'tomlab_cplex', 'glpk'};

% load the model
model = getDistributedModel('Recon2.0model.mat');

% define the metabolites of interest
mets = {'atp[c]','atp[m]', 'atp[e]'};

% obtain a flux vector using e.g. FBA or uniform sampling
model = changeObjective(model, 'DM_atp_c_');
FBAsolution = optimizeCbModel(model, 'max');
V = FBAsolution.x;

for k = 1:length(solverPkgs);

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK == 1
        fprintf('   Testing compute flux splits using %s ... ', solverPkgs{k});

        % check the function without optional input
        fprintf('\n>> without optional input\n');
        [P,C,vP,vC,s] = computeFluxSplits(model,mets,V,[]);
        assert(isequal(sum([model.S(ismember(model.mets,mets),:);...
            sparse(1,size(model.S,2))],1)',s));

        % check the optional input of coeffSign = 0
        fprintf('\n>> with coeffSign = false (stoichiometric coefficient)\n');
        [P,C,vP,vC,s] = computeFluxSplits(model,mets,V,0);
        assert(isequal(sum([model.S(ismember(model.mets,mets),:);...
            sparse(1,size(model.S,2))],1)',s));

        % check the optional input of coeffSign = 1
        fprintf('\n>> with coeffSign = true (sign of stoichiometric coefficient)\n');
        [P,C,vP,vC,s] = computeFluxSplits(model,mets,V,1);
        sInd = find(s);
        for i = 1:length(sInd)
            j = sInd(i);
            assert(s(j) == 1 || s(j) == -1);
        end

        % output a success message
        fprintf('Done.\n');
    end
end

clear i j

%% without the fourth input the full stoichiometric coefficient is used
% steady state: two reactions produce a, one turns 2 a into b, and one takes b away
toyModel = struct();
toyModel.mets = {'a'; 'b'};
toyModel.S = sparse([1 2 -2 0; 0 0 1 -1]);
toyV = [2 3; 2 1; 3 2.5; 3 2.5];

[toyP, toyC, toyVP, toyVC, toyS] = computeFluxSplits(toyModel, {'a'}, toyV);

% tol: the values are exact sums and quotients of small numbers
tol = 1e-12;
assert(isequal(full(toyS), [1; 2; -2; 0]));
assert(norm(full(toyVP - [2 3; 4 2; 0 0; 0 0])) < tol);
assert(norm(full(toyVC - [0 0; 0 0; 6 5; 0 0])) < tol);
% each column of P and C is a set of relative contributions, so it sums to one
assert(norm(full(toyP - [1/3 3/5; 2/3 2/5; 0 0; 0 0])) < tol);
assert(norm(full(toyC - [0 0; 0 0; 1 1; 0 0])) < tol);

% omitting the input equals coeffSign = false, and differs from the sign-only variant
[~, ~, ~, ~, toySFalse] = computeFluxSplits(toyModel, {'a'}, toyV, false);
[~, ~, ~, ~, toySTrue] = computeFluxSplits(toyModel, {'a'}, toyV, true);
assert(isequal(full(toyS), full(toySFalse)));
assert(isequal(full(toySTrue), [1; 1; -1; 0]));

% change the directory
cd(currentDir)
