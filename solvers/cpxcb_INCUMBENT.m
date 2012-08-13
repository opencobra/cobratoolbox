% function ret = cpxcb_INCUMBENT(x,f,Prob,cbxCBInfo)
%
% CPLEX MIP Incumbent callback
%
% Called from TOMLAB /CPLEX during mixed integer optimization when a new integer
% solution has been found but before this solution has replaced the current best known integer solution.
%
% This file can be used to perform any desired analysis of the new integer
% solution and return a status flag to the solver deciding whether to stop 
% or continue the optimization, and also whether to accept or discard the newly 
% found solution. 
%
% This callback is enabled by setting callback(14)=1 in the call to
% cplex.m, or Prob.MIP.callback(14)=1 if using tomRun('cplex',...)
%
% cpxcb_INCUMBENT is called by the solver with three arguments:
%
%  x    - the new integer solution
%  f    - the objective value at x
%  Prob - the Tomlab problem structure 
%
% cpxcb_INCUMBENT should return one of the following scalar values:
%
%   0    Continue optimization and accept new integer solution
%   1    Continue optimization but discard new integer solution
%   2    Stop optimization and accept new integer solution
%   3    Stop optimization adn discard new integer solution
%
% Any other return value will be interpreted as 0. 
%
% If modifying this file, it is recommended to make a copy of it which
% is placed before the original file in the MATLAB path.
%

% Anders Goran, Tomlab Optimization Inc., E-mail: tomlab@tomopt.com
% Copyright (c) 2002-2007 by Tomlab Optimization Inc., $Release: 10.1.0$
% Written Jun 1, 2007.  Last modified Jun 1, 2007.

function ret = cpxcb_INCUMBENT(x,f,Prob)

% ADD USER CODE HERE.

% Accepted return values are: 
%
%   0    Continue optimization and accept new integer solution
%   1    Continue optimization but discard new integer solution
%   2    Stop optimization and accept new integer solution
%   3    Stop optimization adn discard new integer solution
%
% Any other return value will be interpreted as 0. 

global MILPproblemType;

switch MILPproblemType
    case 'OptKnock'
        % Allow printing intermediate OptKnock solutions

        global cobraIntSolInd;
        global cobraContSolInd;
        global selectedRxnIndIrrev;
        global rxnList;
        global irrev2rev;
        global biomassRxnID;
        global solutionFileName;
        
        global OptKnockKOrxnList;
        global OptKnockObjective;
        global OptKnockGrowth;
        global solID;
        
        % Initialize
        if isempty(solID)
            solID = 0;
            OptKnockObjective = [];
            OptKnockGrowth = [];
            OptKnockKOrxnList = {};
        end
            
        solID = solID + 1;
        
        % Get the reactions
        OptKnockObjective(solID) = -f;
        optKnockRxnInd = selectedRxnIndIrrev(x(cobraIntSolInd) < 1e-4);
        optKnockRxns = rxnList(unique(irrev2rev(optKnockRxnInd)));
        OptKnockKOrxnList{solID} = optKnockRxns;
        
        % Get the growth rate
        fluxes = x(cobraContSolInd);
        growth = fluxes(biomassRxnID);
        OptKnockGrowth(solID) = growth;
        
        fprintf('OptKnock\t%f\t%f\t',-f,growth);
        for i = 1:length(optKnockRxns)
            fprintf('%s ',optKnockRxns{i});
        end
        fprintf('\n');
        save(solutionFileName,'OptKnockKOrxnList','OptKnockObjective','OptKnockGrowth');
        ret = 0;
        
    otherwise
        ret = 0;
end
