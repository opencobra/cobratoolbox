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

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testComputeFluxSplits'));
cd(fileDir);

% define the solver packages to be used to run this test
solverPkgs = {'gurobi6', 'tomlab_cplex', 'glpk'};

% load the model
load('testComputeFluxSplitsData.mat');

% metabolites of interest
mets = {'atp[c]','atp[m]'};

% flux vector
V = rand([2062,1],'double');

for k = 1:length(solverPkgs)
    
    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);
    
    if solverOK == 1
        fprintf('   Testing compute flux splits using %s ... ', solverPkgs{k});
        
        % check the function without optional input
        fprintf('\n>> without optional input\n');
        %[P,C,vP,vC] = computeFluxSplits(model,mets,V,[]);        
        assert(isequal(sum([model.S(ismember(model.mets,mets),:);...
            sparse(1,size(model.S,2))],1)',s1));
        
        % check the optional input of coeffSign = 0
        fprintf('\n>> with coeffSign = false (stoichiometric coefficient)\n');
        %[P,C,vP,vC] = computeFluxSplits(model,mets,V,0);
        assert(isequal(sum([model.S(ismember(model.mets,mets),:);...
            sparse(1,size(model.S,2))],1)',s2));
        
        % check the optional input of coeffSign = 1
        fprintf('\n>> with coeffSign = true (sign of stoichiometric coefficient)\n');
        %[P,C,vP,vC] = computeFluxSplits(model,mets,V,1);
        sInd = find(s3);
        for i = length(sInd);
            j = sInd(i);
            assert(s3(j) == 1 || s3(j) == -1);
        end
        
        % output a success message
        fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)
