% The COBRAToolbox: testIsCompatible.m
%
% Purpose:
%     - testIsCompatible tests the isCompatible function. The table parser and the reporting of
%       a known solver are driven with a compatMatrix.rst fixture in a temporary folder, reached
%       by pointing the global CBTDIR there for the duration of one section.
%
% Function under test:
%     src/base/solvers/isCompatible.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - no model; an LP solver is selected for the loop on the available solvers.
%
% Coverage exemptions:
%     Lines 142-156: macOS branch, OS-specific.
%     Lines 160-169: Windows branch, OS-specific.
%     Lines 253-255: unreachable, needs a MATLAB older than 8.4 (R2014b) and the baseline is R2024b.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The distributed compatibility matrix is not understood by the parser
%       SEVERITY: wrong-result
%       TRIGGER: any call, with documentation/source/installation/compatMatrix.rst as distributed
%       OBSERVED: the file is a reStructuredText list-table, the parser only reads grid tables
%         whose rows start with a vertical bar, so every solver gets status 2 (unverified)
%       EXPECTED: the status of the table: 1 for the solvers marked as tested
%       LINES: 98-116
%
% Authors:
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.


%Define Requirements for the test
usedSolvers = {'gurobi','mosek','ibm_cplex'};
solverPkgs = prepareTest('needsUnix',true,'requireOneSolverOf',usedSolvers,'useSolversIfAvailable',usedSolvers);
initialSolverState = CobraSolverState.get();


% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIsCompatible'));
cd(fileDir);

matlabVersion = ['R' version('-release')];

%{
if isunix && strcmp(matlabVersion, 'R2016b')
    % GUROBI 8.0.0 is compatible on UNIX when running R2016b
    compatibleStatus = isCompatible('gurobi', 1, '8.0.0');
    assert(compatibleStatus == 1);

    % IBM CPLEX 12.6.3 is not compatible on UNIX when running R2016b
    compatibleStatus = isCompatible('ibm_cplex', 0, '12.6.3');
    assert(compatibleStatus == 0);

    % NOTE: for untested solvers, the compatibility matrix must be established
end
%}

if isunix && ~ismac
    % loop through all solver names
    solverNames = solverPkgs.LP;

    for i = 1:length(solverNames)
        solverOK = changeCobraSolver(solverNames{i});

        % define a compatibility status with default printLevel
        compatibleStatus = isCompatible(solverNames{i});

        % define a compatibility status with printLevel = 1
        compatibleStatus2 = isCompatible(solverNames{i}, 1);

        % evalute the compatibility status as
        if solverOK %If solver is not ok, then compatibleStatus can be anything...
            assert(solverOK && compatibleStatus);
            assert(solverOK && compatibleStatus2);
        else
            if ~compatibleStatus
                assert(solverOK == 0); %If it is not compatible, than the status has to be 0;
            end
            %Otherwise, anything can be true... it can be installed or
            %not...
        end
    end
end

%% solver name aliases: they resolve without error to a defined status
for aliasCell = {'tomlab_snopt', 'quadMinos', 'lindo_old'}
    assert(ismember(isCompatible(aliasCell{1}, 0, '1.0'), [0, 1, 2]));
end

%% the parser and the status of a solver, with a grid table fixture
% the parser keeps the table in persistent variables, so the function is cleared around this section
global CBTDIR
realCBTDIR = CBTDIR;
fixtureDir = tempname;
mkdir(fullfile(fixtureDir, 'documentation', 'source', 'installation'));
fixtureFile = fullfile(fixtureDir, 'documentation', 'source', 'installation', 'compatMatrix.rst');
matlabColumn = ['R' version('-release')];
fixtureError = [];
try
    writeCompatFixture(fixtureFile, 'Ubuntu', matlabColumn);
    clear isCompatible;
    CBTDIR = fixtureDir;

    % the printed table only appears with printLevel above 1, and a tested solver gets status 1
    printed = evalc('statusTested = isCompatible(''gurobi'', 2, ''8.0.0'');');
    assert(statusTested == 1);
    assert(contains(printed, 'SolverName') && contains(printed, 'is compatible and fully tested'));

    % incompatible and untested solvers, silently and with a message
    assert(isCompatible('ibm_cplex', 0, '12.6.3') == 0);
    assert(isCompatible('mosek', 0, '10.1') == 2);
    printed = evalc('statusBad = isCompatible(''ibm_cplex'', 1, ''12.6.3'');');
    assert(statusBad == 0 && contains(printed, 'is NOT compatible'));
    printed = evalc('statusUntested = isCompatible(''mosek'', 1, ''10.1'');');
    assert(statusUntested == 2 && contains(printed, 'is not fully tested'));

    % without a version the installed one is read; a row without a version matches glpk
    printed = evalc('statusNoVersion = isCompatible(''glpk'', 1);');
    assert(statusNoVersion == 1 && contains(printed, 'glpk is compatible'));

    % a solver that is not in the table keeps the default status
    assert(isCompatible('pdco', 0, '1.0') == 2);

    % a MATLAB release without a column cannot be verified
    writeCompatFixture(fixtureFile, 'Ubuntu', 'R1999a');
    clear isCompatible;
    printed = evalc('statusNoColumn = isCompatible(''gurobi'', 1, ''8.0.0'');');
    assert(statusNoColumn == 2 && contains(printed, 'cannot be verified with MATLAB'));

    % a table for another Linux distribution cannot be used on this machine
    if isunix && ~ismac
        writeCompatFixture(fixtureFile, 'NoSuchDistribution', matlabColumn);
        clear isCompatible;
        printed = evalc('statusOtherOS = isCompatible(''gurobi'', 1, ''8.0.0'');');
        assert(statusOtherOS == 2 && contains(printed, 'can only be verified on Linux'));
        clear isCompatible;
        assert(isCompatible('gurobi', 0, '8.0.0') == 2);
    end
catch fixtureError
end
% the real table and root folder are back, whatever happened above
CBTDIR = realCBTDIR;
clear isCompatible;
rmdir(fixtureDir, 's');
CobraSolverState.restore(initialSolverState);
if ~isempty(fixtureError)
    rethrow(fixtureError);
end

% change back to the old directory
cd(currentDir);

function writeCompatFixture(fileName, osName, matlabColumn)
% Writes a compatibility matrix in the grid table format of the parser: a Linux table, a closing
% paragraph that ends it, and the two kinds of table rules the parser has to skip.
    fid = fopen(fileName, 'w');
    fprintf(fid, 'Solver compatibility\n--------------------\n\n');
    fprintf(fid, 'Linux %s\n~~~~~~~~~~~~\n\n', osName);
    fprintf(fid, '+-------------------+-----------+\n');
    fprintf(fid, '| SolverName        | %s |\n', matlabColumn);
    fprintf(fid, '+====================+==========+\n');
    fprintf(fid, '| GUROBI 8.0.0      | |white_check_mark| |\n');
    fprintf(fid, '| IBM CPLEX 12.6.3  | |x|       |\n');
    fprintf(fid, '| MOSEK 10.1        | |warning| |\n');
    fprintf(fid, '| GLPK              | |white_check_mark| |\n');
    fprintf(fid, '+-------------------+-----------+\n\n');
    fprintf(fid, 'End of the table.\n');
    fclose(fid);
end

