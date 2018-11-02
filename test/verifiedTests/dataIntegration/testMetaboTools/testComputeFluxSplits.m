% The COBRAToolbox: testcomputeFluxSplits.m
%
% Purpose:
%     - tests the basic functionality of computeFluxSplits
%       Tests 1 optional input with 3 possibilities: coeffSign=[] or 0 or 1
%       returns 1 if all tests were completed succesfully, 0 if not
%
% Authors:
%     - Original file: Diana El Assal 03/08/2017
%

% % save the current path
currentDir = pwd;

% % initialize the test
fileDir = fileparts(which('testComputeFluxSplits'));
cd(fileDir);
global CBTDIR

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
        for i = length(sInd);
            j = sInd(i);
            assert(s(j) == 1 || s(j) == -1);
        end

        % output a success message
        fprintf('Done.\n');
    end
end

clear i j

% change the directory
cd(currentDir)
