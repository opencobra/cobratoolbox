% The COBRAToolbox: testIsCompatible.m
%
% Purpose:
%     - testIsCompatible tests the isCompatible function

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIsCompatible'));
cd(fileDir);

matlabVersion = ['R' version('-release')];

if isunix && strcmp(matlabVersion, 'R2016b')
    % GUROBI 6.5.0 is compatible on UNIX when running R2016b
    compatibleStatus = isCompatible('gurobi', 1, '6.5.0');
    assert(compatibleStatus == 1);

    % IBM CPLEX 12.7.0 is not compatible on UNIX when running R2016b
    compatibleStatus = isCompatible('ibm_cplex', -1, '12.6.3');
    assert(compatibleStatus == 0);

    % NOTE: for untested solvers, the compatibility matrix must be established
end

% loop through all solver names
solverNames = {'ibm_cplex', 'gurobi', 'mosek'};

for i = 1:length(solverNames)
    solverOK = changeCobraSolver(solverNames{i});

    % define a compatibility status with default printLevel
    compatibleStatus = isCompatible(solverNames{i});

    % define a compatibility status with printLevel = 1
    compatibleStatus2 = isCompatible(solverNames{i}, 1);

    % evalute the compatibility status as
    assert(solverOK == compatibleStatus);
    assert(solverOK == compatibleStatus2);
end

% change back to the old directory
cd(currentDir);
