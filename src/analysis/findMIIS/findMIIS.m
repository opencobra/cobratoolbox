function MIIS = findMIIS(LPProblem,printLevel)
% Finds the Minimal Irreducible Infeasible Subset (MIIS) in an infeasible
% linear program. It uses (for now) the IBM ILOG CPLEX conflict refine
% routine. The MIIS is the smallest infeasible submodel that becomes feasbile if one
% constraint/bound is removed. All subsets of a MIIS are feasbile.
% Where relaxedFBA and feasOpt take corrective measures automatically,
% findMIIS points the user to the infeasible subset which guides decision
% making. The user can then check errors in the data or correct the model based on 
% the literature.
%
% USAGE
%
%    MIIS = findMIIS(model,1)
%
% INPUTS:
%    LPProblem:        Infeasible model as COBRA model structure
%    printLevel:       0/1/2
%
% OUTPUT:
%    MIIS.rxns:        Reactions of MIIS
%    MIIS.mets:        Mets of MIIS
%    MIIS.rxnsStat:    Status of infeasiblity of reactions
%    MIIS.metsStat:    Status of infeasiblity of metabolites
%    please refer to this link for status meaning
% https://www.ibm.com/support/knowledgecenter/de/SSSA5P_12.7.0/ilog.odms.cplex.help/refcallablelibrary/macros/Solution_status_codes.html
%
% .. Author: - Marouen Ben Guebila - 24/07/2017

if ~changeCobraSolver('ibm_cplex','LP',0)
    error('This function requires IBM ILOG CPLEX');
end

if (nargin < 2)
    printLevel=0;
end

if ~isfield(LPProblem,'A')
    if ~isfield(LPProblem,'S')
            error('Equality constraint matrix must either be a field denoted A or S.')
    end
    LPProblem.A=LPProblem.S;
end

if ~isfield(LPProblem,'csense')
    nMet=size(LPProblem.A);
    if printLevel>0
        fprintf('%s\n','Assuming equality constraints, i.e. S*v=b');
    end
    %assuming equality constraints
    LPProblem.csense(1:nMet,1)='E';
end

if ~isfield(LPProblem,'osense')
    %assuming maximisation
    LPProblem.osense=-1;
    if printLevel>0
        fprintf('%s\n','Assuming maximisation of objective');
    end
end

if size(LPProblem.A,2)~=length(LPProblem.c)
    error('dimensions of A & c are inconsistent');
end

if size(LPProblem.A,2)~=length(LPProblem.lb) || size(LPProblem.A,2)~=length(LPProblem.ub)
    error('dimensions of A & bounds are inconsistent');
end

%get data
[c,x_L,x_U,b,csense,osense] = deal(LPProblem.c,LPProblem.lb,LPProblem.ub,LPProblem.b,LPProblem.csense,LPProblem.osense);
%modify objective to correspond to osense
c=full(c*osense);

%cplex expects it dense
b=full(b);

%call cplex
%complex ibm ilog cplex interface
if ~isempty(csense)
    %set up constant vectors for CPLEX
    b_L(csense == 'E',1) = b(csense == 'E');
    b_U(csense == 'E',1) = b(csense == 'E');
    b_L(csense == 'G',1) = b(csense == 'G');
    b_U(csense == 'G',1) = Inf;
    b_L(csense == 'L',1) = -Inf;
    b_U(csense == 'L',1) = b(csense == 'L');
else
    b_L = b;
    b_U = b;
end

% Initialize the CPLEX object
try
    ILOGcplex = Cplex('fba');
catch ME
    error('CPLEX not installed or licence server not up')
end

ILOGcplex.Model.sense = 'minimize';

% Now populate the problem with the data
ILOGcplex.Model.obj   = c;
ILOGcplex.Model.lb    = x_L;
ILOGcplex.Model.ub    = x_U;
ILOGcplex.Model.A     = LPProblem.A;
ILOGcplex.Model.lhs   = b_L;
ILOGcplex.Model.rhs   = b_U;

% Call conflict refiner in the problem
ILOGcplex.Param.conflict.display.Cur=printLevel;
ILOGcplex.refineConflict();
if ILOGcplex.Conflict.status == 31
    fprintf('The conflict refiner found a minimal conflict. \n')
    MIIS.rxns=ILOGcplex.Conflict.colind;
    MIIS.mets=ILOGcplex.Conflict.rowind;
    MIIS.rxnsStat=ILOGcplex.Conflict.colbdstat;
    MIIS.metsStat=ILOGcplex.Conflict.rowbdstat;
else
    fprintf('No conflict available, check if the model is feasible.')
    MIIS.rxns=[];MIIS.mets=[];MIIS.rxnsStat=[];MIIS.metsStat=[];
end
end