% The COBRAToolbox: testChangeIBMCplexParams.m
%
% Purpose:
%    This script tests whether input parameters for the IBM ILOG Cplex solver
%    are in effect when calling solveCobraLP.m, and also tests directly the function
%    setCplexParam used to change the IBM ILOG Cplex parameters in solveCobraLP.m

% save the current path
currentDir = pwd;

%get the warning settings and turn on all warnings
cwarn = warning;
warning('on');

% initialize the test
fileDir = fileparts(which('testChangeIBMCplexParams'));
cd(fileDir);

try
    ibm_cplex = changeCobraSolver('ibm_cplex', 'LP');
catch
    ibm_cplex = false;
end
if ibm_cplex
    LP = struct();
    LP.A = 1;
    LP.b = 1;
    LP.lb = -1000;
    LP.ub = 1000;
    LP.c = 1;
    LP.osense = -1;
    LP.csense = 'L';
    sol = solveCobraLP(LP);
    assert(sol.full == 1)

    if isunix
        % change the time limit for the solver
        % Note: On windows, the timelimit parameter has no effect
        CplexParam = struct('timelimit', 0);
        sol = solveCobraLP(LP, CplexParam);
        % no solution because of time limit
        assert(isempty(sol.full) & sol.origStat == 11)
    end

    % print parameters not recognized by Cplex
    CplexParam.notexist = 1;
    diary('testChangeIBMCplexParams.txt');
    sol = solveCobraLP(LP, CplexParam, 'printLevel', 1);
    diary off
    fid = fopen('testChangeIBMCplexParams.txt', 'r');
    text1 = '';
    line = fgetl(fid);
    while ~isequal(line, -1)
        text1 = [strtrim(text1), ' ', line];
        line = fgetl(fid);
    end
    fclose(fid);
    % check if the warning is printed
    assert(~isempty(strfind(text1, 'Warning: *.notexist cannot be identified as a valid cplex parameter. Ignore.')))
    delete('testChangeIBMCplexParams.txt');

    % print parameters that cannot be uniquely identified
    CplexParam = struct('timelimit', 0, 'feasibility', 1e-8);
    diary('testChangeIBMCplexParams.txt');
    sol = solveCobraLP(LP, CplexParam, 'printLevel', 1);
    diary off
    fid = fopen('testChangeIBMCplexParams.txt', 'r');
    text1 = '';
    line = fgetl(fid);
    while ~isequal(line, -1)
        text1 = [strtrim(text1), ' ', line];
        line = fgetl(fid);
    end
    fclose(fid);
    % check if the warning is printed
    assert(~isempty(strfind(text1, 'Warning: *.feasibility cannot be uniquely identified as a valid cplex parameter. Ignore.')))
    delete('testChangeIBMCplexParams.txt');

    % test changing other Cplex parameters
    LP = Cplex('test setCplexParam');
    CplexParam = struct();
    [CplexParam.simplex.display, CplexParam.tune.display] = deal(0);
    [CplexParam.simplex.tolerances.optimality, CplexParam.simplex.tolerances.feasibility] = deal(1e-9, 1e-8);
    % change parameters using setCplexParam
    LP = setCplexParam(LP, CplexParam);
    % Cplex internal method for getting all changed parameters
    ChangedParams = LP.getChgParam;

    % test also with .Cur at the end of the input struct
    LP = Cplex('test setCplexParam');
    CplexParam = struct();
    [CplexParam.simplex.display.Cur, CplexParam.tune.display.Cur] = deal(0);
    [CplexParam.simplex.tolerances.optimality.Cur, CplexParam.simplex.tolerances.feasibility.Cur] = deal(1e-9, 1e-8);
    % change parameters using setCplexParam
    LP = setCplexParam(LP, CplexParam);
    % Cplex internal method for getting all changed parameters
    ChangedParams2 = LP.getChgParam;

    % the changed parameters should be the same using either input structures
    assert(isequal(ChangedParams, ChangedParams2))
    % check if the parameters are really changed
    assert(isfield(ChangedParams, 'simplex') && isfield(ChangedParams.simplex, 'display') ...
        && ChangedParams.simplex.display.Cur == 0 && isfield(ChangedParams.simplex, 'tolerances') ...
        && isfield(ChangedParams.simplex.tolerances, 'optimality') && ChangedParams.simplex.tolerances.optimality.Cur == 1e-9 ...
        && isfield(ChangedParams.simplex.tolerances, 'feasibility') && ChangedParams.simplex.tolerances.feasibility.Cur == 1e-8 ...
        && isfield(ChangedParams, 'tune') && isfield(ChangedParams.tune, 'display') && ChangedParams.tune.display.Cur == 0)
end

%Reset the warning settings
warning(cwarn);

% change the directory
cd(currentDir)
