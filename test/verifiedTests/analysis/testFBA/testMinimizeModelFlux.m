% The COBRAToolbox: testMinimizeModelFlux.m
%
% Purpose:
%     - Tests the minimizeModelFlux function
%
% Authors:
%     - Thomas Pfau
%     - Farid Zare 2024/10/02 -update test function with function updates
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptimizeCbModel'));
cd(fileDir);

% set the tolerance
tol = 1e-6;

% define the solver packages to be used to run this test
%solverPkgs = prepareTest('needsLP',true, 'requiredSolvers',{'glpk'});%why
%only glpk?
solverPkgs = prepareTest('needsLP',true, 'excludeSolvers',{'matlab','pdco','ddqMinos','quadMinos'});


% load the model
model = createToyModelForMinimizeFlux();

for k = 1:length(solverPkgs.LP)

    currentmodel = model;
    changeCobraSolver(solverPkgs.LP{k},'LP');

    fprintf('   Testing minimizeModelFlux using %s ... ', solverPkgs.LP{k});
    % qpng does not support this model size, so we don't use quadratic
    % minimzation.
    % Test 1: Minimize flux with the 'min' objective and 'one' norm
    sol = minimizeModelFlux(currentmodel,'min','one');
    assert(abs(sol.x(end)) < tol);

    % Test 2: Minimize flux without specific norm
    sol = minimizeModelFlux(currentmodel, 'min');
    % Since its reversible, exchangers cycle and all rev reactions cycle.
    assert(abs(sol.x(end) - 0) <= tol); 

    % Test 3: Maximize flux with 'one' norm
    sol = minimizeModelFlux(currentmodel,'max','one'); %same as before.
    assert(abs(sol.x(end) - 12000 ) <= tol); %Since its reversible, exchangers cycle and all rev reactions cycle.

    % Test 4: Set model osenseStr to 'min' and test
    currentmodel.osenseStr = 'min';
    modelChanged = changeRxnBounds(currentmodel,'R3',5,'l');
    sol = minimizeModelFlux(modelChanged);
    assert(abs(sol.x(end) - 20)  <= tol); %Can only come from the cycle

    % Test 5: Maximize flux after bounds change
    sol = minimizeModelFlux(modelChanged,'max');
    assert(abs(sol.x(end) - 11000)  <= tol); %MAx flux through C-> E and Exchangers, + 3 reactions from the cycle.

% Test 6: Force production of E and remove osenseStr from Model
    modelChanged = changeRxnBounds(currentmodel,'EX_E',5,'l'); 
    modelChanged = rmfield(modelChanged,'osenseStr');
    sol = minimizeModelFlux(modelChanged);
    assert(abs(sol.x(end) - 25)  <= tol); %Flux -> A -> B -> C -> E -> 
end

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)