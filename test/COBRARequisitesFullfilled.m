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


%Do some precomputation.
global CBT_MISSING_REQUIREMENTS;

persistent availableSolvers


%Some Matlab Toolboxes currently in use in the COBRA Toolbox. 
%This might have to be extended in the future. 
toolboxInfo = struct('statistics_toolbox',{'Statistics and Machine Learning Toolbox','Statistics Toolbox'},...
                     'bioinformatics_toolbox',{'Bioinformatics Toolbox'},...
                     'distrib_computing_toolbox',{'Parallel Computing Toolbox'},...
                     'optimization_toolbox',{'Optimization Toolbox'},...
                     'global_optimization_toolbox',{'Global Optimization Toolbox'},...
                     'image_toolbox','Image Processing Toolbox');

if isempty(availableSolvers)
    availableSolvers = getAvailableSolversByType();
    fieldsWithSolvers = fieldnames(availableSolvers);
    availableSolvers.ALL = {};
    for i = 1:numel(fieldsWithSolvers)
        availableSolvers.ALL = union(availableSolvers.ALL,availableSolvers.(fieldsWithSolvers{i}));
    end
end


parser = inputParser()
parser.addParamValue('Toolboxes',{},@iscell);
parser.addParamValue('ReqSolvers',{},@iscell);
parser.addParamValue('UseIfAvailable',{},@iscell);
parser.addParamValue('NeedsLP',false,@(x) islogic(x) || x == 1 || x == 0 );
parser.addParamValue('NeedsMILP',false,@(x) islogic(x) || x == 1 || x == 0 );
parser.addParamValue('NeedsNLP',false,@(x) islogic(x) || x == 1 || x == 0 );
parser.addParamValue('NeedsQP',false,@(x) islogic(x) || x == 1 || x == 0 );
parser.addParamValue('NeedsMIQP',false,@(x) islogic(x) || x == 1 || x == 0 );

parser.parse(varargin{:});

UseQP = parser.Results.NeedsQP;
UseLP = parser.Results.NeedsLP;
UseMIQP = parser.Results.NeedsMIQP;
UseNLP = parser.Results.NeedsNLP;
UseMILP = parser.Results.NeedsMILP;

Toolboxes = parser.Results.Toolboxes;
RequiredSolvers = parser.Results.ReqSolvers;
PreferredSolvers = parser.Results.UseIfAvailable;

errorMessage = {};

%First, check the required Solvers
if ~isempty(RequiredSolvers) && ~all(ismember(RequiredSolvers,availableSolvers.ALL))
    %We have required solvers and some are missing
    missing = ~ismember(RequiredSolvers,availableSolvers.ALL);
    errorMessage{end+1} = sprintf('%s are missing required solvers for the test.', strjoin(RequiredSolvers(missing),' and '));
end

%Now, Check the Toolboxes
res = ver;
missingTBs = struct('License',{},'Installation',{});
for i = 1:numel(Toolboxes)
    tbstring = lower(Toolboxes{i});
    licpres = license('test',tbstring);
    if any(tbstring,fieldnames(toolboxInfo))
        tbpres = any(ismember(toolboxInfo.(Toolboxes{i}),{ver.name}));
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
if ~isempty(missingTbs.License)
    errorMessage{end+1} = sprintf('The test requires licenses for the following Toolboxes: %s', strjoin(missingTbs.License,' and '));     
end
if ~isempty(missingTbs.Installation)
    errorMessage{end+1} = sprintf('The test the following Toolboxes to be installed: %s', strjoin(missingTbs.Installation,' and '));     
end

%Set up default solvers.
if isempty(availableSolvers.LP)    
    if needLP
        errorMessage{end+1} = 'The test requires at least one LP solver but no solver is installed';
    end    
else
    defaultLPSolver = availableSolvers.LP{1};     
end

if isempty(availableSolvers.QP)    
    if needQP
        errorMessage{end+1} = 'The test requires at least one QP solver but no solver is installed';
    end    
else
    defaultQPSolver = availableSolvers.QP{1};     
end

if isempty(availableSolvers.MILP)    
    if needMILP
        errorMessage{end+1} = 'The test requires at least one MILP solver but no solver is installed';
    end    
else
    defaultMILPSolver = availableSolvers.MILP{1};     
end

if isempty(availableSolvers.MIQP)    
    if needMIQP
        errorMessage{end+1} = 'The test requires at least one MIQP solver but no solver is installed';
    end    
else
    defaultMIQPSolver = availableSolvers.MIQP{1};     
end

if isempty(availableSolvers.NLP)    
    if needNLP
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
problemTypes = fieldnames(availableSolvers);
for i = 1:problemTypes
    solversToUse.(problemTypes{i}) = intersect(PreferredSolvers,availableSolvers.(problemTypes{i}));
    if isempty(solversToUse.(problemTypes{i})) && ~isempty(availableSolvers.(problemTypes{i}))
        eval(['solversToUse.' problemTypes{i} ' = default' problemTypes{i} 'Solver']);
    end
end