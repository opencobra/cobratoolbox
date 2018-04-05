function [solversToUse] = testRequirementsAndGetSolversForTest(varargin)
% Checks the prerequisites of the test, and returns solvers depending on
% the input parameters. If the requirements are NOT met, it will throw a
% COBRA:RequirementsNotMet error.
%
% USAGE:
%    [solversToUse] = testRequirementsAndGetSolvers(varargin)
%
% OPTIONAL INPUTS:
%    varagin:       'ParameterName',value pairs with the following
%                   Parameter options:
%                   * 'toolboxes' or 'requiredToolboxes' - Names of required toolboxes (the license
%                                        feature name) (Default: {})
%                   * 'requiredSolvers' - Names of all solvers which MUST be
%                                         available. If not empty, the resulting
%                                         solvers struct will contain cell arrays (Default: {})
%                   * 'useSolversIfAvailable'  - Names of solvers which should be
%                                                used if they are available. If not empty, the resulting
%                                                solvers struct will contain cell arrays (will
%                                                not throw an error if not).
%                                                (Default: {})
%                   * 'needsLP'        - Whether a LP solver is required.
%                                       (Default = false);
%                   * 'needsMILP'      - Whether a MILP solver is required.
%                                       (Default = false);
%                   * 'needsQP'        - Whether a QP solver is required.
%                                       (Default = false);
%                   * 'needsMIQP'      - Whether a MIQP solver is required.
%                                       (Default = false);
%                   * 'needsNLP'       - Whether a NLP solver is required.
%                                       (Default = false);
%                   * 'needsUnix'      - Whether the test only works on a
%                                        Unix system (mac or linux)
%                                        (Default = false);
%                   * 'needsWindows'   - Whether the test only works on a Windows system
%                                        (Default = false);
%                   * 'needsMac'       - Whether the test only works on a Mac system
%                                        (Default = false);
%                   * 'needsLinux'     - Whether the test only works on a Linux system
%                                        (Default = false);
%
% OUTPUTS:
%
%    solversToUse:         A struct with one field per solver type listing
%                          the solvers to use for that type of problem in a cell array.
%                          If neither the 'useIfAvailable' nor the 'reqSolvers'
%                          paramter is provided, only at most one solver
%                          per type will be returned (i.e. the default
%                          solver for that type). See the examples below
%                          
% EXAMPLE:
%
%      %Request a check for the parallel processing toolbox
%      >>> solvers = testRequirementsAndGetSolvers('requiredToolboxes',{'distrib_computing_toolbox'})
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
%      %Request gurobi, ibm_cplex and tomlab if available
%      >>> solvers = testRequirementsAndGetSolvers('useIfAvailable',{'tomlab','ibm_cplex','gurobi'})
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

%Do some precomputation.
global CBT_MISSING_REQUIREMENTS_ERROR_ID;
global OPT_PROB_TYPES
persistent availableSolvers

%Some Matlab Toolboxes currently in use in the COBRA Toolbox.
%This might have to be extended in the future.
toolboxInfo = struct('statistics_toolbox',{{'Statistics and Machine Learning Toolbox','Statistics Toolbox'}},...
    'bioinformatics_toolbox',{{'Bioinformatics Toolbox'}},...
    'distrib_computing_toolbox',{{'Parallel Computing Toolbox'}},...
    'optimization_toolbox',{{'Optimization Toolbox'}},...
    'global_optimization_toolbox',{{'Global Optimization Toolbox'}},...
    'image_toolbox',{{'Image Processing Toolbox'}},...
    'gads_toolbox',{{'Global Optimization Toolbox'}});

if isempty(availableSolvers)
    availableSolvers = getAvailableSolversByType();
    fieldsWithSolvers = fieldnames(availableSolvers);
    availableSolvers.ALL = {};
    for i = 1:numel(fieldsWithSolvers)
        availableSolvers.ALL = union(availableSolvers.ALL,availableSolvers.(fieldsWithSolvers{i}));
    end
end


parser = inputParser();
parser.addParamValue('toolboxes',{},@iscell);
parser.addParamValue('requiredToolboxes',{},@iscell);
parser.addParamValue('requiredSolvers',{},@iscell);
parser.addParamValue('useSolversIfAvailable',{},@iscell);
parser.addParamValue('needsLP',false,@(x) islogical(x) || x == 1 || x == 0 );
parser.addParamValue('needsMILP',false,@(x) islogical(x) || x == 1 || x == 0 );
parser.addParamValue('needsNLP',false,@(x) islogical(x) || x == 1 || x == 0 );
parser.addParamValue('needsQP',false,@(x) islogical(x) || x == 1 || x == 0 );
parser.addParamValue('needsMIQP',false,@(x) islogical(x) || x == 1 || x == 0 );
parser.addParamValue('needsUnix',false,@(x) islogical(x) || x == 1 || x == 0 );
parser.addParamValue('needsLinux',false,@(x) islogical(x) || x == 1 || x == 0 );
parser.addParamValue('needsWindows',false,@(x) islogical(x) || x == 1 || x == 0 );
parser.addParamValue('needsMac',false,@(x) islogical(x) || x == 1 || x == 0 );


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



toolboxes = union(parser.Results.toolboxes,parser.Results.requiredToolboxes);
requiredSolvers = parser.Results.requiredSolvers;
preferredSolvers = parser.Results.useSolversIfAvailable;

errorMessage = {};

%First, check whether the OS is applicable
if macOnly
    if ~ismac
        errorMessage{end+1} = 'This test only works on macOS';
    end
end

if windowsOnly
    if ~ispc
        errorMessage{end+1} = 'This test only works on Windows';
    end
end


if linuxOnly
    if ~isunix
        errorMessage{end+1} = 'This test only works on Linux Systems';
    else
        if ~strcmp(computer('arch'),'glnx64')
            errorMessage{end+1} = 'This test only works on Linux Systems';
        end
    end
end

if unixOnly
    if ~isunix
        errorMessage{end+1} = 'This test only works on Unix Systems (Mac and Linux)';
    end
end


%Then, check the required Solvers
if ~isempty(requiredSolvers) && ~all(ismember(requiredSolvers,availableSolvers.ALL))
    %We have required solvers and some are missing
    missing = ~ismember(requiredSolvers,availableSolvers.ALL);
    if sum(missing) == 1
        misssolver = requiredSolvers{missing};
         errorMessage{end+1} = sprintf('%s is a required solver for the test and not available on your system.', misssolver);
    else
        errorMessage{end+1} = sprintf('%s are missing solvers required for the test but not available on your system.', strjoin(requiredSolvers(missing),' and '));
    end
else
    %Otherwise add the required Solvers to the preferred solvers.
    preferredSolvers = union(preferredSolvers,requiredSolvers);
end

%Now, Check the Toolboxes
res = ver;
missingTBs = struct('License',{{}},'Installation',{{}});
for i = 1:numel(toolboxes)
    tbstring = lower(toolboxes{i});
    licpres = license('test',tbstring);
    if any(ismember(tbstring,fieldnames(toolboxInfo)))
        tbpres = any(ismember(toolboxInfo.(lower(toolboxes{i})),{res.Name}));
    else
        %We will rely on the license....
        tbpres = licpres;
    end
    if ~tbpres
        missingTBs.Installation{end+1} = tbstring;
    end
    if ~licpres
        missingTBs.License{end+1} = tbstring;
    end
end


%Append the error message.
if ~isempty(missingTBs.License)
    errorMessage{end+1} = sprintf('The test requires licenses for the following Toolboxes: %s', strjoin(missingTBs.License,' and '));
end
if ~isempty(missingTBs.Installation)
    errorMessage{end+1} = sprintf('The test requires the following Toolboxes to be installed: %s', strjoin(missingTBs.Installation,' and '));
end

%Set up default solvers. And test whether the test is useable.
if isempty(availableSolvers.LP)
    if useLP
        errorMessage{end+1} = 'The test requires at least one LP solver but no solver is installed';
    end
else
    if ~isempty(availableSolvers.LP)
        defaultLPSolver = availableSolvers.LP{1};
    else
        defaultLPSolver = '';
    end
end

if isempty(availableSolvers.QP)
    if useQP
        errorMessage{end+1} = 'The test requires at least one QP solver but no solver is installed';
    end
else
    if ~isempty(availableSolvers.QP)
        defaultQPSolver = availableSolvers.QP{1};
    else
        defaultQPSolver = '';
    end
end

if isempty(availableSolvers.MILP)
    if useMILP
        errorMessage{end+1} = 'The test requires at least one MILP solver but no solver is installed';
    end
else
    if ~isempty(availableSolvers.MILP)
        defaultMILPSolver = availableSolvers.MILP{1};
    else
        defaultMILPSolver = '';
    end
    
end

if isempty(availableSolvers.MIQP)
    if useMIQP
        errorMessage{end+1} = 'The test requires at least one MIQP solver but no solver is installed';
    end
else
    if ~isempty(availableSolvers.MIQP)
        defaultMIQPSolver = availableSolvers.MIQP{1};
    else
        defaultMIQPSolver = '';
    end
    
end

if isempty(availableSolvers.NLP)
    if useNLP
        errorMessage{end+1} = 'The test requires at least one NLP solver but no solver is installed';
    end
else
    if ~isempty(availableSolvers.NLP)
        defaultNLPSolver = availableSolvers.NLP{1};
    else
        defaultNLPSolver = '';
    end
end



if ~isempty(errorMessage)
    error(CBT_MISSING_REQUIREMENTS_ERROR_ID,strjoin(errorMessage,'\n'));
end

%Ok, we are successfull. so lets collect the Used Solvers.
solversToUse = struct();
problemTypes = OPT_PROB_TYPES;
for i = 1:numel(problemTypes)
    solversToUse.(problemTypes{i}) = intersect(preferredSolvers,availableSolvers.(problemTypes{i}));
    if isempty(solversToUse.(problemTypes{i})) && ~isempty(availableSolvers.(problemTypes{i}))
        if isempty(preferredSolvers)
            eval(['solversToUse.' problemTypes{i} ' = {default' problemTypes{i} 'Solver};']);
        else
            if isempty(availableSolvers.(problemTypes{i}))
                %No solver exists, the cell array is empty.
                solversToUse.(problemTypes{i}) = {};
            else
                %A Solver exists, provide it.
                eval(['solversToUse.' problemTypes{i} ' = {default' problemTypes{i} 'Solver};']);
            end
        end
    end
end
