function solvers = checkGAMSSolvers(problemType)
% This function return the solvers that can be used in GAMS to solve the
% type of problem especified by the user
%
% USAGE:
%
%    solvers = checkGAMSSolvers(problemType) 
%
% INPUTS:
%    problemType               Type: string
%                              Description: string containing the problem
%                              type for which this function will search
%                              solvers. 
%                              E.g.: problem type = 'LP' (Linear
%                              Programming)
%
% OUTPUTS:
%    solvers                   Type: cell array for available GAMS solvers
%                              in your systems which allows the user to
%                              solve problems of type "problemType"
% 
% EXAMPLE:
%
%    solvers = checkGAMSSolvers('MIP') 
%    % returns the GAMS solvers available to solve Mixed Integer Programming
%    % problems. You can see the entire list of problem types with the
%    % function getAvailableGAMSSolvers.m
%
% .. Author: - Sebasti·n Mendoza, May 30th 2017, Center for Mathematical Modeling, University of Chile, snmendoz@uc.cl

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