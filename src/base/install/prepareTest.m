function [solversToUse] = prepareTest(varargin)
% Checks the prerequisites of the test, and returns solvers depending on
% the input parameters. If the requirements are NOT met, a
% COBRA:RequirementsNotMet error is thrown.
%
% USAGE:
%    [solversToUse] = prepareTest(varargin)
%
% OPTIONAL INPUTS:
%    varagin:      `ParameterName` value pairs with the following options:
%
%                   - `toolboxes` or `requiredToolboxes`: Names of required toolboxes (the license feature name).(default: {})
%                   - `minimalMatlabSolverVersion`: Minimal version of the optimization toolbox required to use the matlab solver.(default: 0)
%                   - `requiredSolvers`: Names of all solvers that MUST be available. If not empty, the resulting solvers struct will contain cell arrays (default: {})
%                   - `useSolversIfAvailable`: Names of solvers that should be used if available. If not empty, the resulting solvers struct will contain cell arrays (will not throw an error if not). (default: {})
%                   - `requireOneSolverOf`: Names of solvers, at least one of which has to be available
%                   - `excludeSolvers`: Names of solvers which should never be used for the test (because they fail)
%                   - `useMinimalNumberOfSolvers`: Always use only one solver. This option allows tests which only use FBA to generate input, but where no expicit linear programming code is present, to only validate on one solver (default: false).
%                   - `needsLP`: Whether a LP solver is required (default: false)
%                   - `needsMILP`: Whether a MILP solver is required (default: false)
%                   - `needsQP`: Whether a QP solver is required (default: false)
%                   - `needsMIQP`: Whether a MIQP solver is required (default: false)
%                   - `needsNLP`: Whether a NLP solver is required (default: false)
%                   - `needsUnix`: Whether the test only works on a Unix system (macOS or Linux) (default: false)
%                   - `needsWindows`: Whether the test only works on a Windows system (default: false)
%                   - `needsMac`: Whether the test only works on a Mac system (default: false)
%                   - `needsLinux`: Whether the test only works on a Linux system (default: false)
%                   - `needsWebAddress`: Tests, whether the supplied url exists (default: '')
%                   - `needsWebRead`: Tests, whether webread can be used with the given url
%
% OUTPUTS:
%
%    solversToUse:  A struct with one field per solver type listing
%                   the solvers to use for that type of problem in a cell array.
%                   If neither of the 'useIfAvailable' nor the 'reqSolvers'
%                   parameter is provided, only at most one solver
%                   per type will be returned (i.e. the default
%                   solver for that type). See the examples below
%
% EXAMPLE:
%
%      % request a check for the parallel processing toolbox
%      >> solvers = prepareTest('requiredToolboxes', {'distrib_computing_toolbox'})
%      solvers =
%
%                struct with fields:
%
%                      LP: {'gurobi'}
%                    MILP: {'gurobi'}
%                      QP: {'gurobi'}
%                    MIQP: {'gurobi'}
%                     NLP: {'matlab'}
%
%      % request gurobi, ibm_cplex and tomlab if available
%      >> solvers = prepareTest('useIfAvailable', {'tomlab', 'ibm_cplex', 'gurobi'})
%      solvers =
%
%                struct with fields:
%
%                      LP: {2×1 cell}
%                    MILP: {2×1 cell}
%                      QP: {2×1 cell}
%                    MIQP: {'gurobi'}
%                     NLP: {'matlab'}
%
%

global CBT_MISSING_REQUIREMENTS_ERROR_ID
global OPT_PROB_TYPES
persistent availableSolvers

% some Matlab Toolboxes currently in use in the COBRA Toolbox.
% This might have to be extended in the future.
toolboxInfo = struct('statistics_toolbox', {{'Statistics and Machine Learning Toolbox', 'Statistics Toolbox'}}, ...
                     'bioinformatics_toolbox', {{'Bioinformatics Toolbox'}}, ...
                     'distrib_computing_toolbox', {{'Parallel Computing Toolbox'}}, ...
                     'optimization_toolbox', {{'Optimization Toolbox'}}, ...
                     'global_optimization_toolbox', {{'Global Optimization Toolbox'}}, ...
                     'image_toolbox', {{'Image Processing Toolbox'}}, ...
                     'gads_toolbox', {{'Global Optimization Toolbox'}});

if isempty(availableSolvers)
    availableSolvers = getAvailableSolversByType();
end


parser = inputParser();
parser.addParamValue('toolboxes', {}, @iscell);
parser.addParamValue('requiredToolboxes', {}, @iscell);
parser.addParamValue('minimalMatlabSolverVersion',0,@isnumeric);

parser.addParamValue('requiredSolvers', {}, @iscell);
parser.addParamValue('useSolversIfAvailable', {}, @iscell);
parser.addParamValue('requireOneSolverOf', {}, @iscell);
parser.addParamValue('excludeSolvers', {}, @(x) iscell(x) || ischar(x) );
parser.addParamValue('useMinimalNumberOfSolvers', false, @(x) islogical(x) || x == 1 || x == 0);
parser.addParamValue('needsLP', false, @(x) islogical(x) || x == 1 || x == 0);
parser.addParamValue('needsMILP', false, @(x) islogical(x) || x == 1 || x == 0);
parser.addParamValue('needsNLP', false, @(x) islogical(x) || x == 1 || x == 0);
parser.addParamValue('needsQP', false, @(x) islogical(x) || x == 1 || x == 0);
parser.addParamValue('needsMIQP', false, @(x) islogical(x) || x == 1 || x == 0);
parser.addParamValue('needsUnix', false, @(x) islogical(x) || x == 1 || x == 0);
parser.addParamValue('needsLinux', false, @(x) islogical(x) || x == 1 || x == 0);
parser.addParamValue('needsWindows', false, @(x) islogical(x) || x == 1 || x == 0);
parser.addParamValue('needsMac', false, @(x) islogical(x) || x == 1 || x == 0);
parser.addParamValue('needsWebAddress', '', @ischar);
parser.addParamValue('needsWebRead', false, @(x) islogical(x) || x == 1 || x == 0);


parser.parse(varargin{:});

useQP = parser.Results.needsQP;
useLP = parser.Results.needsLP;
useMIQP = parser.Results.needsMIQP;
useNLP = parser.Results.needsNLP;
useMILP = parser.Results.needsMILP;

macOnly = parser.Results.needsMac;
windowsOnly = parser.Results.needsWindows;
unixOnly = parser.Results.needsUnix;
linuxOnly = parser.Results.needsLinux;

toolboxes = union(parser.Results.toolboxes, parser.Results.requiredToolboxes);
requiredSolvers = parser.Results.requiredSolvers;
possibleSolvers = parser.Results.requireOneSolverOf;
excludedSolvers = parser.Results.excludeSolvers;
if ischar(excludedSolvers)
    excludedSolvers = {excludedSolvers};
end
preferredSolvers = parser.Results.useSolversIfAvailable;

needsWebAddress = parser.Results.needsWebAddress;
needsWebRead = parser.Results.needsWebRead;
useMinimalNumberOfSolvers = parser.Results.useMinimalNumberOfSolvers;
runtype = getenv('CI_RUNTYPE');

minimalMatlabSolverVersion = parser.Results.minimalMatlabSolverVersion;

errorMessage = {};
infoMessage = {};

% first, check whether the OS is applicable
if macOnly
    if ~ismac
        errorMessage{end + 1} = 'This test only works on macOS';
    end
end

if windowsOnly
    if ~ispc
        errorMessage{end + 1} = 'This test only works on Windows';
    end
end

if linuxOnly
    if ~isunix
        errorMessage{end + 1} = 'This test only works on Linux Systems';
    else
        if ~strcmp(computer('arch'), 'glnx64')
            errorMessage{end + 1} = 'This test only works on Linux Systems';
        end
    end
end

if ~isempty(needsWebAddress)
    [status_curl, result_curl] = system(['curl -s -k ' needsWebAddress]);
    if status_curl ~= 0 || isempty(result_curl)
        errorMessage{end + 1} = sprintf('This function needs to connect to %s and was unable to do so.',needsWebAddress);
    end
    if needsWebRead
        if verLessThan('MATLAB','9.3') && isunix && strncmp(needsWebAddress,'https',5)
            errorString = sprintf(['This function needs to connect to a ''https'' address using webread.\n', ...
                                   'Your MATLAB version is shipped with an invalid libssl.so.1.0.0 \n',...
                                   'which will cause MATLAB to crash if webread is called with an \n',...
                                   '''https'' website.\n',...
                                   'To fix this, you can replace your MATLAB library with the system library \n',...
                                   'by running the following commands in the console:\n',...
                                   '$ sudo mv %s/bin/glnxa64/libssl.so.1.0.0 %s/bin/glnxa64/libssl.so.1.0.0.old\n',...
                                   '$ sudo cp /lib/x86_64-linux-gnu/libssl.so.1.0.0 %s/bin/glnxa64/libssl.so.1.0.0\n',...
                                   'Please note that this test will not be able to run on your system,\n',...
                                   'regardless on whether you fixed the library or not. If you want to run it,',...
                                   'you will have to remove the ''needsWebRead'' flag from the ''prepareTest''',...
                                   'statement in the test and run it again.'],...
                                   matlabroot,matlabroot,matlabroot);
            errorMessage{end + 1} = errorString;
        end
    end
end


if unixOnly
    if ~isunix
        errorMessage{end + 1} = 'This test only works on Unix Systems (Mac and Linux)';
    end
end

% restrict the solvers available for this test
solversForTest = availableSolvers;

if any(ismember(solversForTest.LP,'matlab'))
    boxes = ver();
    optBox = find(ismember({boxes.Name},'Optimization Toolbox'));
    if ~isempty(optBox)
        optVer = boxes(optBox).Version;
        if str2double(optVer) < minimalMatlabSolverVersion
            excludedSolvers = [columnVector(excludedSolvers);'matlab'];
        end
    end
end

if ~isempty(excludedSolvers)
    solverTypes = fieldnames(availableSolvers);
    for i = 1:numel(solverTypes)
        excludedPos = ismember(solversForTest.(solverTypes{i}),excludedSolvers);
        solversForTest.(solverTypes{i}) = solversForTest.(solverTypes{i})(~excludedPos);
    end
    if numel(excludedSolvers) == 1
        infoMessage{end+1} = sprintf('%s is not compatible with the tested function and thus excluded.',excludedSolvers{1});
    else
        infoMessage{end+1} = sprintf('The following solvers are not compatible with this test and therefore excluded:\n%s and %s', strjoin(excludedSolvers(1:end-1),' and '),excludedSolvers{end});
    end
end

% then, check the required Solvers
if ~isempty(requiredSolvers) && ~all(ismember(requiredSolvers, solversForTest.ALL))
    % we have required solvers and some are missing
    missing = ~ismember(requiredSolvers, solversForTest.ALL);
    if sum(missing) == 1
        misssolver = requiredSolvers{missing};
            errorMessage{end + 1} = sprintf('%s is a required solver for the test and not available on your system.', misssolver);
    else
        errorMessage{end + 1} = sprintf('%s are missing solvers required for the test but not available on your system.', strjoin(requiredSolvers(missing), ' and '));
    end
else
    % otherwise add the required Solvers to the preferred solvers.
    preferredSolvers = union(preferredSolvers, requiredSolvers);
end

if ~isempty(possibleSolvers) && ~any(ismember(possibleSolvers,solversForTest.ALL))
    if numel(possibleSolvers) == 1
        errorMessage{end + 1} = sprintf('The test requires that the following solver is installed:\n%s', strjoin(possibleSolvers, ' or '));
    else
        errorMessage{end + 1} = sprintf('The test requires that at least one of the following solvers is installed:\n%s or %s', strjoin(possibleSolvers(1:end-1), ', '),possibleSolvers{end});
    end
else
    if ~isempty(possibleSolvers)
        %We have a set of possible solvers.
        %So we restrict the preferredSolvers to those
        % if there are preferred solvers.
        if ~isempty(preferredSolvers)
            preferredSolvers = intersect(preferredSolvers,possibleSolvers);
        else
            solverOptions = intersect(possibleSolvers,solversForTest.ALL);
            preferredSolvers = solversForTest.ALL(find(ismember(solversForTest.ALL,possibleSolvers),1));
        end

    end
end

% check the Toolboxes
res = ver;
missingTBs = struct('License', {{}}, 'Installation', {{}});
for i = 1:numel(toolboxes)
    tbstring = lower(toolboxes{i});
    licpres = license('test', tbstring);
    if any(ismember(tbstring, fieldnames(toolboxInfo)))
        tbpres = any(ismember(toolboxInfo.(lower(toolboxes{i})), {res.Name}));
    else
        % rely on the license
        tbpres = licpres;
    end
    if ~tbpres
        missingTBs.Installation{end + 1} = tbstring;
    end
    if ~licpres
        missingTBs.License{end + 1} = tbstring;
    end
end


% append the error message
if ~isempty(missingTBs.License)
    errorMessage{end + 1} = sprintf('The test requires licenses for the following Toolboxes: %s', strjoin(missingTBs.License, ' and '));
end
if ~isempty(missingTBs.Installation)
    errorMessage{end + 1} = sprintf('The test requires the following Toolboxes to be installed: %s', strjoin(missingTBs.Installation, ' and '));
end

% set up default solvers and test whether the test is useable
if isempty(solversForTest.LP)
    if useLP
        errorMessage{end + 1} = 'The test requires at least one LP solver but no solver is installed';
    end
else
    if ~isempty(solversForTest.LP)
        defaultLPSolver = solversForTest.LP{1};
    else
        defaultLPSolver = '';
    end
end

if isempty(solversForTest.QP)
    if useQP
        errorMessage{end + 1} = 'The test requires at least one QP solver but no solver is installed';
    end
else
    if ~isempty(solversForTest.QP)
        defaultQPSolver = solversForTest.QP{1};
    else
        defaultQPSolver = '';
    end
end

if isempty(solversForTest.MILP)
    if useMILP
        errorMessage{end + 1} = 'The test requires at least one MILP solver but no solver is installed';
    end
else
    if ~isempty(solversForTest.MILP)
        defaultMILPSolver = solversForTest.MILP{1};
    else
        defaultMILPSolver = '';
    end

end

if isempty(solversForTest.MIQP)
    if useMIQP
        errorMessage{end + 1} = 'The test requires at least one MIQP solver but no solver is installed';
    end
else
    if ~isempty(solversForTest.MIQP)
        defaultMIQPSolver = solversForTest.MIQP{1};
    else
        defaultMIQPSolver = '';
    end

end

if isempty(solversForTest.NLP)
    if useNLP
        errorMessage{end + 1} = 'The test requires at least one NLP solver but no solver is installed';
    end
else
    if ~isempty(solversForTest.NLP)
        defaultNLPSolver = solversForTest.NLP{1};
    else
        defaultNLPSolver = '';
    end
end


if ~isempty(errorMessage)
    errorString = strjoin(errorMessage, '\n');
    infoString = strjoin(infoMessage, '\n');
    error(CBT_MISSING_REQUIREMENTS_ERROR_ID, strjoin({errorString,infoString}, '\n'));
end

% collect the Used Solvers.
solversToUse = struct();
problemTypes = OPT_PROB_TYPES;
% if this is the extensive test suite, and the solver use not just about
% testing whether the actual work succeeded.
if strcmpi(runtype, 'extensive') && ~useMinimalNumberOfSolvers
    solversToUse = solversForTest;
    % exclude pdco if not explicitly requested and available, as it has issues at the moment.
    if ~any(ismember('pdco',preferredSolvers)) && any(ismember('pdco',solversToUse.LP))
        solversToUse.LP(ismember(solversToUse.LP,'pdco')) = [];
        solversToUse.QP(ismember(solversToUse.LP,'pdco')) = [];
    end
    if ~isempty(possibleSolvers)
        %Restrict to the possibleSolvers
        for i = 1:numel(problemTypes)
            solversToUse.(problemTypes{i}) = intersect(solversToUse.(problemTypes{i}),possibleSolvers);
        end
    end
else
    for i = 1:numel(problemTypes)
        solversToUse.(problemTypes{i}) = intersect(preferredSolvers, solversForTest.(problemTypes{i}));
        if isempty(solversToUse.(problemTypes{i})) && ~isempty(solversForTest.(problemTypes{i}))
            if isempty(preferredSolvers)
                eval(['solversToUse.' problemTypes{i} ' = {default' problemTypes{i} 'Solver};']);
            else
                if isempty(solversForTest.(problemTypes{i}))
                    % no solver exists, the cell array is empty.
                    solversToUse.(problemTypes{i}) = {};
                else
                    % a solver exists, provide it.
                    eval(['solversToUse.' problemTypes{i} ' = {default' problemTypes{i} 'Solver};']);
                end
            end
        end
    end
end

