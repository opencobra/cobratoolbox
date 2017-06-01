function solvers = checkGAMSSolvers(problemType)
%% DESCRIPTION
% This function return the solvers that can be used in GAMS to solve the
% type of problem especified by the user

%% INPUTS
% problemType(obligatory)   Type: string
%                           Description: string containing the problem type
%                           for which this function will search solvers.
%                           Example: problem type = 'LP'
%                           (Linear Programming)

%% OUTPUTS
% solvers                   Type: cell array of solvers that are available
%                           for GAMS in your systems which allow solve
%                           problem of type "problemType"
%

%% CODE

if nargin < 1
    error('The type of problem must be specified')
end

%verify that gams is installed
gamsPath = which('gams');
if isempty(gamsPath)
    error('GAMS is not installed or GAMS path has not been added to MATLAB path.');
end

%verify that licememo.gms in the path of the system
licememoFullPath = which('licememo.gms');
if isempty(licememoFullPath)
    error('licememo.gms in not in MATLAB path.');
end

%find the available solver available in GAMS to solve a problem of type
%"problemType"
[~,numTable,problemTypes,solvers]=getAvailableGAMSSolvers;
[~,posProblemType]=ismember(problemType,problemTypes);
if ~isempty(posProblemType)
    solvers=solvers((numTable(:,posProblemType))==1);
else
    solvers={};
end

end