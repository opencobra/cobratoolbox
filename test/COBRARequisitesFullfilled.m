function [solversToUse] = COBRARequisitesFullfilled(varargin)
% Checks the prerequisites of the test, and returns solvers depending on
% the input parameters. If the requirements are NOT met, it will throw a
% COBRA:RequirementsNotMet error.
%
% USAGE:
%    [tf,solversToUse] = COBRARequisitesFullfilled(varargin)
% 
% INPUTS:
%    varagin:       'ParameterName',value pairs with the following
%                   Parameter options:
%                   * 'Toolboxes'      - Names of toolboxes (the license
%                                        feature name) (Default: {})
%                   * 'ReqSolvers'     - Names of all solvers which MUST be
%                                        available (Default: {})
%                   * 'UseIfAvailable' - Names of solvers which should be
%                                        used if they are available (will
%                                        not throw an error if not).
%                   * 'NeedsLP'        - Whether a LP solver is required.
%                                       (Default = false);
%                   * 'NeedsMILP'      - Whether a MILP solver is required.
%                                       (Default = false);
%                   * 'NeedsQP'        - Whether a QP solver is required.
%                                       (Default = false);
%                   * 'NeedsMIQP'      - Whether a MIQP solver is required.
%                                       (Default = false);
%                   * 'NeedsNLP'       - Whether a NLP solver is required.
%                                       (Default = false);
%                   * 'NeedsUnix'      - Whether the test only works on a
%                                        Unix system (mac or linux)
%                                        (Default = false);
%                   * 'NeedsWindows'   - Whether the test only works on a Windows system 
%                                        (Default = false);
%                   * 'NeedsMac'       - Whether the test only works on a Mac system 
%                                        (Default = false);
%                   * 'NeedsLinux'     - Whether the test only works on a Linux system 
%                                        (Default = false);

%Do some precomputation.
global CBT_MISSING_REQUIREMENTS;
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
parser.addParamValue('Toolboxes',{},@iscell);
parser.addParamValue('ReqSolvers',{},@iscell);
parser.addParamValue('UseIfAvailable',{},@iscell);
parser.addParamValue('NeedsLP',false,@(x) islogical(x) || x == 1 || x == 0 );
parser.addParamValue('NeedsMILP',false,@(x) islogical(x) || x == 1 || x == 0 );
parser.addParamValue('NeedsNLP',false,@(x) islogical(x) || x == 1 || x == 0 );
parser.addParamValue('NeedsQP',false,@(x) islogical(x) || x == 1 || x == 0 );
parser.addParamValue('NeedsMIQP',false,@(x) islogical(x) || x == 1 || x == 0 );
parser.addParamValue('NeedsUnix',false,@(x) islogical(x) || x == 1 || x == 0 );
parser.addParamValue('NeedsLinux',false,@(x) islogical(x) || x == 1 || x == 0 );
parser.addParamValue('NeedsWindows',false,@(x) islogical(x) || x == 1 || x == 0 );
parser.addParamValue('NeedsMac',false,@(x) islogical(x) || x == 1 || x == 0 );


parser.parse(varargin{:});

UseQP = parser.Results.NeedsQP;
UseLP = parser.Results.NeedsLP;
UseMIQP = parser.Results.NeedsMIQP;
UseNLP = parser.Results.NeedsNLP;
UseMILP = parser.Results.NeedsMILP;


macOnly = parser.Results.NeedsMac;
windowsOnly = parser.Results.NeedsWindows;
unixOnly = parser.Results.NeedsUnix;
linuxOnly = parser.Results.NeedsLinux;



Toolboxes = parser.Results.Toolboxes;
RequiredSolvers = parser.Results.ReqSolvers;
PreferredSolvers = parser.Results.UseIfAvailable;

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
if ~isempty(RequiredSolvers) && ~all(ismember(RequiredSolvers,availableSolvers.ALL))
    %We have required solvers and some are missing
    missing = ~ismember(RequiredSolvers,availableSolvers.ALL);
    errorMessage{end+1} = sprintf('%s are missing required solvers for the test.', strjoin(RequiredSolvers(missing),' and '));
end

%Now, Check the Toolboxes
res = ver;
missingTBs = struct('License',{{}},'Installation',{{}});
for i = 1:numel(Toolboxes)
    tbstring = lower(Toolboxes{i});
    licpres = license('test',tbstring);
    if any(ismember(tbstring,fieldnames(toolboxInfo)))
        tbpres = any(ismember(toolboxInfo.(lower(Toolboxes{i})),{res.Name}));
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
    errorMessage{end+1} = sprintf('The test the following Toolboxes to be installed: %s', strjoin(missingTBs.Installation,' and '));     
end

%Set up default solvers. And test whether the test is useable.
if isempty(availableSolvers.LP)    
    if UseLP
        errorMessage{end+1} = 'The test requires at least one LP solver but no solver is installed';
    end    
else
    defaultLPSolver = availableSolvers.LP{1};     
end

if isempty(availableSolvers.QP)    
    if UseQP
        errorMessage{end+1} = 'The test requires at least one QP solver but no solver is installed';
    end    
else
    defaultQPSolver = availableSolvers.QP{1};     
end

if isempty(availableSolvers.MILP)    
    if UseMILP
        errorMessage{end+1} = 'The test requires at least one MILP solver but no solver is installed';
    end    
else
    defaultMILPSolver = availableSolvers.MILP{1};     
end

if isempty(availableSolvers.MIQP)    
    if UseMIQP
        errorMessage{end+1} = 'The test requires at least one MIQP solver but no solver is installed';
    end    
else
    defaultMIQPSolver = availableSolvers.MIQP{1};     
end

if isempty(availableSolvers.NLP)    
    if UseNLP
        errorMessage{end+1} = 'The test requires at least one NLP solver but no solver is installed';
    end    
else
    defaultNLPSolver = availableSolvers.NLP{1};     
end



if ~isempty(errorMessage)
    error(CBT_MISSING_REQUIREMENTS,strjoin(errorMessage,'\n'));
end

%Ok, we are successfull. so lets collect the Used Solvers.
solversToUse = struct();
problemTypes = OPT_PROB_TYPES;
for i = 1:numel(problemTypes)
    solversToUse.(problemTypes{i}) = intersect(PreferredSolvers,availableSolvers.(problemTypes{i}));
    if isempty(solversToUse.(problemTypes{i})) && ~isempty(availableSolvers.(problemTypes{i}))
        eval(['solversToUse.' problemTypes{i} ' = default' problemTypes{i} 'Solver;']);
    end
end