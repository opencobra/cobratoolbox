% The COBRAToolbox: testGeometricFBA.m
%
% Purpose:
%     - Tests whether geometricFBA works as intended.
%
% Authors:
%     - Thomas Pfau, Oct 2018


% save the current path
currentDir = pwd;

% The testmodel used is structured as follows:
%
%   <-> A -> B ---> C --> E <->
%        \               ^
%         \             /
%           -> F -->  G
%
% Thus the flux can be split between A -> B -> C -> E and A -> F -> G -> E

% load the test models
model = createToyModelForGeoFBA();
% model with Constraints
modelWConst = addCOBRAConstraints(model,{'R1'},400); % R1 restricted to a maximum flux of 400

%When detectDeadEnds is changed according to Ronans suggestion, we need to test
%multiple solvers.
solverPkgs = prepareTest('needsLP', true, 'minimalMatlabSolverVersion',8.0);
tol = 1e-4;
for k = 1:length(solverPkgs.LP)
    % set the solver
    changeCobraSolver(solverPkgs.LP{k}, 'LP', 0);
    fprintf('Testing geometricFBA with solver %s ...\n',solverPkgs.LP{k});    
    sol = geometricFBA(model);
    assert(all(abs(sol(1:6) - 500) < tol))
    sol = geometricFBA(modelWConst);
    % flux is now centered between 0 and 400 for R11.. R3 and between 600
    % and 1000 for R4..6
    assert(all(abs(sol(1:3) - 200) < tol))
    assert(all(abs(sol(4:6) - 800) < tol))    
end

fprintf('Done...\n');
cd(currentDir)
