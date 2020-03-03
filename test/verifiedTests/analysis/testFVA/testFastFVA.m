% The COBRAToolbox: testFastFVA.m
%
% Purpose:
%     - testFastFVA tests the functionality of fastFVA
%
% Author:
%     - Laurent Heirendt June 2016 & June 2017
%     - Vmin, Vmax test: Marouen Ben Guebila 24/02/17
%

global ILOG_CPLEX_PATH

%Test requirements
requiredToolboxes = {'distrib_computing_toolbox'};
requiredSolvers = {'ibm_cplex'};
prepareTest('requiredSolvers',requiredSolvers,'toolboxes',requiredToolboxes);

% save the userpath
originalUserPath = path;

% FVA settings
optPercentage = 90;
objective = 'max';

% set the tolerance
tol = 1e-6;

% Define the solverName
solverName = 'ibm_cplex';

% load the E.coli model
model = getDistributedModel('ecoli_core_model.mat');

% Define the number of workers to be used
nworkers = 2;

if changeCobraSolver(solverName, 'LP', 0)

    if isempty(strfind(ILOG_CPLEX_PATH, '1271')) || isempty(strfind(ILOG_CPLEX_PATH, '128'))
        generateMexFastFVA;
    end

    [minFluxSerial, maxFluxSerial, optsolSerial, retSerial, fbasolSerial, ...
        fvaminSerial, fvamaxSerial, statussolminSerial, statussolmaxSerial] = fastFVA(model, optPercentage, [], solverName, model.rxns(1:2));

    % Start a parpool environment in MATLAB
    setWorkerCount(nworkers);

    [minFluxParallel, maxFluxParallel, optsolParallel, retParallel, fbasolParallel, ...
        ~, ~, statussolminParallel, statussolmaxParallel] = fastFVA(model, optPercentage, [], solverName, model.rxns(1:2));

    assert(norm(minFluxSerial - minFluxParallel) < tol);
    assert(norm(maxFluxSerial - maxFluxParallel) < tol);
    assert(norm(optsolSerial - optsolParallel) < tol);
    assert(norm(retSerial - retParallel) < tol);
    assert(norm(fbasolSerial - fbasolParallel) < tol);
    assert(norm(fvaminSerial) > 0);
    assert(norm(fvamaxSerial) > 0);
    assert(norm(statussolminSerial - statussolminParallel) < tol);
    assert(norm(statussolmaxSerial - statussolmaxParallel) < tol);

    % Print out the header of the script
    fprintf('\n Toy Example: Flux ranges for a mutant with reaction v6 knocked out\n');
    
    % generate a new model.
    model = createModel();
    model = addMultipleMetabolites(model,strcat('M',cellfun(@num2str, num2cell(1:7),'Uniform',0)));
    % Stoichiometric matrix
    % (adapted from Papin et al. Genome Res. 2002 12: 1889-1900.)
    
    S = [
        %	 v1 v2 v3 v4 v5 v6 b1 b2 b3
        -1,  0,  0,  0,  0,  0,  1,  0,  0;  % A
         1, -2, -2,  0,  0,  0,  0,  0,  0;  % B
         0,  1,  0,  0, -1, -1,  0,  0,  0;  % C
         0,  0,  1, -1,  1,  0,  0,  0,  0;  % D
         0,  0,  0,  1,  0,  1,  0, -1,  0;  % E
         0,  1,  1,  0,  0,  0,  0,  0, -1;  % byp
         0,  0, -1,  1, -1,  0,  0,  0,  0;  % cof
    ];

    % Flux limits
    %           v1   v2   v3   v4   v5   v6   b1    b2   b3
    lb = [0,   0,   0,   0,   0,   0,   0,   0,   0]';  % Irreversibility
    ub = [inf, inf, inf, inf, inf, inf,  10, inf, inf]';  % b1 represents the "substrate"

    % b2 represents the "growth"
    c = [0 0 0 0 0 0 0 1 0]';    

    rxns = {'v1', 'v2', 'v3', 'v4', 'v5', 'v6', 'b1', 'b2', 'b3'}';
    model = addMultipleReactions(model,rxns,model.mets,S,'c',c,'lb',lb,'ub',ub);
    optPercentage = 100;  % FVA based on maximum growth

    model.lb(6) = 0;
    model.ub(6) = 0;

    fprintf('\n>> Toy example - minimal output.\n');
    [minFlux, maxFlux, optsol, ret] = fastFVA(model, optPercentage);

    fprintf('\n>> Toy example - all output arguments.\n');
    [minFluxT, maxFluxT, optsolT, retT, fbasolT, fvaminT, fvamaxT, statussolmin, statussolmax] = fastFVA(model, optPercentage);

    % Validation of Toy Example
    load('refData_fastFVA.mat');

    assert(isequal(maxFlux, referenceToyResults.maxFlux));
    assert(isequal(minFlux, referenceToyResults.minFlux));
    assert(optPercentage == referenceToyResults.optPercentage);
    assert(optsol == referenceToyResults.optsol);

    % load the E.coli model
    model = getDistributedModel('ecoli_core_model.mat');

    optPercentage = 90;  % FVA based on maximum growth

    % full fastFVA
    [minFluxT, maxFluxT, optsolT, retT, fbasolT, fvaminT, fvamaxT, statussolminT, statussolmaxT] = fastFVA(model, optPercentage, objective);

    % calculate the reference values using fluxVariability
    solverOK = changeCobraSolver(solverName);
    if solverOK

        [minFluxTref, maxFluxTref, Vminref, Vmaxref] = fluxVariability(model, optPercentage, objective, model.rxns, true, true, 'FBA');

        % check if the objective values are the same
        assert(norm(minFluxT - minFluxTref) < tol);
        assert(norm(maxFluxT - maxFluxTref) < tol);

        % check if the constraints are satisfied for each flux vector
        for i = 1:length(model.rxns)
            assert(norm(model.S * Vminref(:, i)) < tol)
            assert(norm(model.S * Vmaxref(:, i)) < tol)
        end
    end

    load('refData_distributedFBA.mat');

    % check if the objective values are the same
    assert(norm(minFluxT - minFlux) < tol);
    assert(norm(maxFluxT - maxFlux) < tol);
    assert(norm(minFluxTref - minFlux) < tol);
    assert(norm(maxFluxTref - maxFlux) < tol);
    assert(norm(minFluxTref - minFluxT) < tol);
    assert(norm(maxFluxTref - maxFluxT) < tol);
    assert(abs(optSol - optsolT) < tol)

    % check if the constraints are satisfied for each flux vector
    for i = 1:length(model.rxns)
        assert(norm(model.S * fvaminT(:, i)) < tol)
        assert(norm(model.S * fvamaxT(:, i)) < tol)
        assert(norm(model.S * fvamin(:, i)) < tol)
        assert(norm(model.S * fvamax(:, i)) < tol)
    end

    % fastFVAex and customized set of CPLEX parameters

    % definition of the reaction list (fastFVAex)
    rxnsList = model.rxns(1:10);

    % determine the reaction IDs
    rxnsIDlist = findRxnIDs(model, rxnsList);

    % Choice of the stoichiometric matrix
    matrixAS = 'S';  % 'A'

    % Load CPLEX parameters
    cpxControl = CPLEXParamSet;

    fprintf('\n>> Example with 4 nargin, 2 nargout.\n');
    [minFluxT, maxFluxT] = fastFVA(model, optPercentage, objective, solverName);
    assert(norm(minFluxT - minFluxTref) < tol);
    assert(norm(maxFluxT - maxFluxTref) < tol);

    fprintf('\n>> Example with 5 nargin & 7 nargout.\n');
    [minFluxT, maxFluxT, optsolT, retT, fbasolT, fvaminT, fvamaxT] = fastFVA(model, optPercentage, objective, solverName, rxnsList);
    assert(norm(minFluxT(rxnsIDlist) - minFluxTref(rxnsIDlist)) < tol);
    assert(norm(maxFluxT(rxnsIDlist) - maxFluxTref(rxnsIDlist)) < tol);

    fprintf('\n>> Example with 6 nargin & 7 nargout.\n');
    [minFluxT, maxFluxT, optsolT, retT, fbasolT, fvaminT, fvamaxT] = fastFVA(model, optPercentage, objective, solverName, rxnsList, matrixAS);
    assert(norm(minFluxT(rxnsIDlist) - minFluxTref(rxnsIDlist)) < tol);
    assert(norm(maxFluxT(rxnsIDlist) - maxFluxTref(rxnsIDlist)) < tol);

    fprintf('\n>> Example with 7 nargin & 7 nargout.\n');
    [minFluxT, maxFluxT, optsolT, retT, fbasolT, fvaminT, fvamaxT] = fastFVA(model, optPercentage, objective, solverName, rxnsList, matrixAS, cpxControl);
    assert(norm(minFluxT(rxnsIDlist) - minFluxTref(rxnsIDlist)) < tol);
    assert(norm(maxFluxT(rxnsIDlist) - maxFluxTref(rxnsIDlist)) < tol);

    fprintf('\n>> Example with 5 nargin & 9 nargout.\n');
    [minFluxT, maxFluxT, optsolT, retT, fbasolT, fvaminT, fvamaxT, statussolmin, statussolmax] = fastFVA(model, optPercentage, objective, solverName, rxnsList);
    assert(norm(minFluxT(rxnsIDlist) - minFluxTref(rxnsIDlist)) < tol);
    assert(norm(maxFluxT(rxnsIDlist) - maxFluxTref(rxnsIDlist)) < tol);
    assert(norm(statussolminT(rxnsIDlist) - statussolmin(rxnsIDlist)) < tol);
    assert(norm(statussolmaxT(rxnsIDlist) - statussolmax(rxnsIDlist)) < tol);

    fprintf('\n>> Example with 6 nargin & 9 nargout.\n');
    [minFluxT, maxFluxT, optsolT, retT, fbasolT, fvaminT, fvamaxT, statussolmin, statussolmax] = fastFVA(model, optPercentage, objective, solverName, rxnsList, matrixAS);
    assert(norm(minFluxT(rxnsIDlist) - minFluxTref(rxnsIDlist)) < tol);
    assert(norm(maxFluxT(rxnsIDlist) - maxFluxTref(rxnsIDlist)) < tol);
    assert(norm(statussolminT(rxnsIDlist) - statussolmin(rxnsIDlist)) < tol);
    assert(norm(statussolmaxT(rxnsIDlist) - statussolmax(rxnsIDlist)) < tol);

    fprintf('\n>> Example with 7 nargin & 9 nargout.\n');
    [minFluxT, maxFluxT, optsolT, retT, fbasolT, fvaminT, fvamaxT, statussolmin, statussolmax] = fastFVA(model, optPercentage, objective, solverName, rxnsList, matrixAS, cpxControl);
    assert(norm(minFluxT(rxnsIDlist) - minFluxTref(rxnsIDlist)) < tol);
    assert(norm(maxFluxT(rxnsIDlist) - maxFluxTref(rxnsIDlist)) < tol);
    assert(norm(statussolminT(rxnsIDlist) - statussolmin(rxnsIDlist)) < tol);
    assert(norm(statussolmaxT(rxnsIDlist) - statussolmax(rxnsIDlist)) < tol);

    % test distribution strategies
    for strategy = 0:2
        for printLevel = 0:1
            rxnsList = model.rxns(1:20);

            % determine the reaction IDs
            rxnsIDlist = findRxnIDs(model, rxnsList);
            [minFluxT, maxFluxT] = fastFVA(model, optPercentage, objective, solverName, rxnsList, matrixAS, [], strategy, [], printLevel);
            assert(norm(minFluxT(rxnsIDlist) - minFluxTref(rxnsIDlist)) < tol);
            assert(norm(maxFluxT(rxnsIDlist) - maxFluxTref(rxnsIDlist)) < tol);
        end
    end

    % define the reaction list
    rxnsList = model.rxns([1, 3, 6, 9]);

    % determine the reaction IDs
    rxnsIDlist = findRxnIDs(model, rxnsList);

    fprintf('\n>> Example with 5 nargin (sorted rxnsList).\n');
    [minFluxT, maxFluxT, optsolT, retT, fbasolT, fvaminT, fvamaxT, statussolmin, statussolmax] = fastFVA(model, optPercentage, objective, solverName, rxnsList);
    assert(norm(minFluxT - minFluxTref(rxnsIDlist)) < tol);
    assert(norm(maxFluxT - maxFluxTref(rxnsIDlist)) < tol);
    assert(norm(statussolminT(rxnsIDlist) - statussolmin) < tol);
    assert(norm(statussolmaxT(rxnsIDlist) - statussolmax) < tol);

    % test various cases of reaction lists with different optPercentage values
    testCases = {[4, 5, 7, 8]; [7:10]; [1:3]; [1:12]; [13:16, 77, 78:80, 90, 92:95]};

    for i = 1:length(testCases)
        optPercentage = 100 -  i * ceil(100 / length(testCases));
        if optPercentage < 0
            optPercentage = 0;
        end
        testKey = testCases{i};
        rxnsList = model.rxns(testKey);
        fprintf('\n>> Example with 10 nargin (rxnsOptMode) (%d).\n', i);
        [minFluxT, maxFluxT, optsolT, retT, fbasolT, fvaminT, fvamaxT, statussolmin, statussolmax] = fastFVA(model, optPercentage, objective, solverName, rxnsList);
        [minFluxT1, maxFluxT1, optsolT1, retT1, fbasolT1, fvaminT1, fvamaxT1, statussolmin1, statussolmax1] = fastFVA(model, optPercentage, objective, solverName, model.rxns);

        assert(norm(minFluxT - minFluxT1(testKey)) < tol)
        assert(norm(maxFluxT - maxFluxT1(testKey)) < tol)
    end

    optPercentage = 90.0;
    rxnsList = model.rxns([1, 20, 30, 19, 5, 4, 3]);
    fprintf('\n>> Example with 5 nargin (UNsorted rxnsList & optPercentage = 90).\n');
    try
        [minFluxT, maxFluxT, optsolT, retT, fbasolT, fvaminT, fvamaxT, statussolmin, statussolmax] = fastFVA(model, optPercentage, objective, solverName, rxnsList);
    catch ME
        assert(length(ME.message) > 0)
    end

    % Examples:
    % rxnsOptMode = [0,0,0,0,0,0] -> statussolmin = [1,1,1,1,1,1]; statussolmax = [0,0,0,0,0,0];
    % rxnsOptMode = [1,1,1,1,1,1] -> statussolmin = [0,0,0,0,0,0]; statussolmax = [1,1,1,1,1,1];
    % rxnsOptMode = [2,2,2,2,2,2] -> statussolmin = [1,1,1,1,1,1]; statussolmax = [1,1,1,1,1,1];
    % rxnsOptMode = [0,1,2,0,1,2] -> statussolmin = [1,0,1,1,0,1]; statussolmax = [0,1,1,0,1,1];

    % define the reaction list
    rxnsList = model.rxns([1, 2, 3, 4, 12, 14]);
    fprintf('\n>> Example with 10 nargin (rxnsOptMode) (1).\n');

    % define the optimization mode for each reaction
    rxnsOptMode = [0, 1, 2, 0, 1, 2];

    [minFluxT, maxFluxT, optsolT, retT, fbasolT, fvaminT, fvamaxT, statussolmin, statussolmax] = fastFVA(model, optPercentage, objective, solverName, rxnsList, [], [], [], rxnsOptMode);

    assert(norm(statussolmin - [1, 0, 1, 1, 0, 1]') < tol)
    assert(norm(statussolmax - [0, 1, 1, 0, 1, 1]') < tol)

    % define the reaction list
    rxnsList = model.rxns([8, 9, 15, 27, 38]);
    fprintf('\n>> Example with 10 nargin (rxnsOptMode) (2).\n');
    rxnsOptMode = [2, 1, 2, 0, 0];

    [minFluxT, maxFluxT, optsolT, retT, fbasolT, fvaminT, fvamaxT, statussolmin, statussolmax] = fastFVA(model, optPercentage, objective, solverName, rxnsList, [], [], [], rxnsOptMode);

    assert(norm(statussolmin - [1, 0, 1, 1, 1]') < tol)
    assert(norm(statussolmax - [1, 1, 1, 0, 0]') < tol)

    % print out an exit message
    fprintf('\n Testing fastFVA done. \n')

else
    fprintf('\n testFastFVA is skipped because %s is not installed. \n', solverName)
end

% restore the original path
path(originalUserPath);
addpath(originalUserPath);
