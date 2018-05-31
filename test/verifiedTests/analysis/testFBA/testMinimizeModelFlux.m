% The COBRAToolbox: testMinimizeModelFlux.m
%
% Purpose:
%     - Tests the minimizeModelFlux function
%
% Authors:
%     - Thomas Pfau
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptimizeCbModel'));
cd(fileDir);

% set the tolerance
tol = 1e-6;

% define the solver packages to be used to run this test
solverPkgs = prepareTest('needsLP',true);

% load the model
model = createToyModelForMinimizeFlux();

for k = 1:length(solverPkgs.LP)
    changeCobraSolver(solverPkgs.LP{k},'LP');
    sol = minimizeModelFlux(model,'min',1);
    assert(sol.x(end) == 0);
    sol = minimizeModelFlux(model);
    assert(sol.x(end) == 12000); %Since its reversible, exchangers cycle and all rev reactions cycle.
    sol = minimizeModelFlux(model,'max',2); %same as before.
    assert(sol.x(end) == 12000); %Since its reversible, exchangers cycle and all rev reactions cycle.
    model.osenseStr = 'min';
    modelChanged = changeRxnBounds(model,'R3',5,'l');
    sol = minimizeModelFlux(modelChanged);
    assert(sol.x(end) == 20); %Can only come from the cycle
    sol = minimizeModelFlux(modelChanged,'max');
    assert(sol.x(end) == 11000); %MAx flux through C-> E and Exchangers, + 3 reactions from the cycle.
    modelChanged = changeRxnBounds(model,'EX_E',5,'l'); %Force production of E
    sol = minimizeModelFlux(modelChanged);
    modelChanged = rmfield(modelChanged,'osenseStr');
    assert(sol.x(end) == 25); %Flux -> A -> B -> C -> E -> 
end

% change the directory
cd(currentDir)
