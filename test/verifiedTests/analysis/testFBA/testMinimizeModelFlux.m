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
solverPkgs = prepareTest('needsLP',true, 'requiredSolvers',{'glpk'});

% load the model
model = createToyModelForMinimizeFlux();

for k = 1:length(solverPkgs.LP)
    currentmodel = model;
    changeCobraSolver(solverPkgs.LP{k},'LP');
    % qpng does not support this model size, so we don't use quadratic
    % minimzation.
    sol = minimizeModelFlux(currentmodel,'min','one');
    assert(abs(sol.x(end)) < tol);
    sol = minimizeModelFlux(currentmodel);
    assert(abs(sol.x(end) - 12000) <= tol); %Since its reversible, exchangers cycle and all rev reactions cycle.
    sol = minimizeModelFlux(currentmodel,'max','one'); %same as before.
    assert(abs(sol.x(end) - 12000 ) <= tol); %Since its reversible, exchangers cycle and all rev reactions cycle.
    currentmodel.osenseStr = 'min';
    modelChanged = changeRxnBounds(currentmodel,'R3',5,'l');
    sol = minimizeModelFlux(modelChanged);
    assert(abs(sol.x(end) - 20)  <= tol); %Can only come from the cycle
    sol = minimizeModelFlux(modelChanged,'max');
    assert(abs(sol.x(end) - 11000)  <= tol); %MAx flux through C-> E and Exchangers, + 3 reactions from the cycle.
    modelChanged = changeRxnBounds(currentmodel,'EX_E',5,'l'); %Force production of E
    sol = minimizeModelFlux(modelChanged);
    modelChanged = rmfield(modelChanged,'osenseStr');
    assert(abs(sol.x(end) - 25)  <= tol); %Flux -> A -> B -> C -> E -> 
end

% change the directory
cd(currentDir)
