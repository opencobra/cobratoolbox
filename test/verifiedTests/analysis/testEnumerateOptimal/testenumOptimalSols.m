% The COBRAToolbox: testenumOtimalSols.m
%
% Purpose:
%     - Tests whether all distinct Solutions are found by
%     enumarateOptimalSolutions
%
% Authors:
%     - Thomas Pfau, Sept 2017


% save the current path
currentDir = pwd;

% The testmodel used is structured as follows:
%
%   <-> A -> B ---> C --> E <->
%        \          ^     ^
%         \         |     |
%           -> D -> F --> G  
% 
%Thus there are three distinct routes through the network. 

fileDir = fileparts(which('testDetectDeadEnds'));
cd(fileDir);

% load the test models
load('DeadEndTestModel','model')


%Determine all dead end metabolites
[mets] = detectDeadEnds(model);
assert(all(ismember(model.mets(mets),{'D','L','C'})));

%When detectDeadEnds is changed according to Ronans suggestion, we need to test
%multiple solvers.
solverPkgs = {'gurobi6', 'tomlab_cplex', 'glpk'};

for k = 1:length(solverPkgs)
    
    % set the solver
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);
    
    if solverOK == 1
        
        %Only determine those, which are not involved in an exchange reaction
        [mets] = detectDeadEnds(model,1);
        assert(all(ismember(model.mets(mets),{'D','L'})));
    end
end
%Clean up after test
clear mets
clear model

cd(currentDir)
