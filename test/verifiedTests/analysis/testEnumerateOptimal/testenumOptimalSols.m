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
%Thus there are three distinct (i.e. linearily independent) routes through the network.

fileDir = fileparts(which('testenumOptimalSols'));
cd(fileDir);

% load the test models
model = createToyModelForAltOpts();

%When detectDeadEnds is changed according to Ronans suggestion, we need to test
%multiple solvers.
solverPkgs = {'gurobi', 'tomlab_cplex', 'glpk','ibm_cplex'};
tol = getCobraSolverParams('LP','feasTol');
for k = 1:length(solverPkgs)

    % set the solver
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0)  && changeCobraSolver(solverPkgs{k},'MILP',0);
    if solverOK == 1
        fprintf('Testing enumerateOptimalSolutions with solver %s ...\n',solverPkgs{k});

        sol = enumerateOptimalSolutions(model);
        %This can be ANY combination, and we will just check some properties.
        assert(size(sol.fluxes,2) == 3); %There should be three distinct routes.
        assert(all(sum(sol.nonzero,2) > 0)); %All reactions should be present at least once.
        assert(all(sol.fluxes(find(model.c),:) == 1000)); %All objectives are 1000
        constraintsMatched = model.S * sol.fluxes;
        assert(all(abs(constraintsMatched(:))) < tol); % All solutions are valid.
    end
end

%Remove the output, to keep the toolbox updateable.
delete([fileDir filesep 'MILPProblem.mat']);

fprintf('Done...\n');
cd(currentDir)
