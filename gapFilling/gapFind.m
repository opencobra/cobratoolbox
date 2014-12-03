function [allGaps,rootGaps,downstreamGaps] = gapFind(model,findNCgaps,verbFlag)
%gapFind Identifies all blocked metabolites (anything downstream of a gap) 
%in a model.  MILP algorithm that finds gaps that may be missed by simple 
%inspection of the S matrix. To find every gap in a model, change the rxn
%bounds on all exchange reactions to allow uptake of every metabolite.
%
% [allGaps,rootGaps,downstreamGaps] = gapFind(model,findNCgaps,verbFlag)
%
%INPUT
% model             a COBRA model
%
%OPTIONAL INPUTS
% findNCgaps        find no consupmption gaps as well as no production gaps
%                   (default false)   
% verbFlag          verbose flag (default false)
%
%OUTPUTS
% allGaps           all gaps found by GapFind
% rootGaps          all root no production (and consumption) gaps
% downstreamGaps    all downstream gaps
%
% based on:
% Kumar, V. et al. BMC Bioinformatics. 2007 Jun 20;8:212.
%
% solve problem:
%   max ||xnp||
%       s.t. S(i,j)*v(j) >= e*w(i,j)        S(i,j) > 0, j in IR
%            S(i,j)*v(j) <= M*w(i,j)        S(i,j) > 0, j in IR
%            S(i,j)*v(j) >= e - M(1-w(i,j)) S(i,j) ~= 0, j in R
%            S(i,j)*v(j) <= M*w(i,j)        S(i,j) ~= 0, j in R
%            ||w(i,j)|| >= xnp(i)
%            lb <= v <= ub
%            S*v >= 0
%            xnp(i) = {0,1}
%            w(i,j) = {0,1}
%
% reformulated for COBRA MILP as:
%   max sum(xnp(:))
%       s.t. S*v >= 0   (or = 0 if findNCgaps = true)               (1)
%            S(i,j)*v(j) - e*w(i,j) >= 0     S(i,j) > 0, j in IR    (2)
%            S(i,j)*v(j) - M*w(i,j) <= 0     S(i,j) > 0, j in IR    (3)
%            S(i,j)*v(j) - M*w(i,j) >= e-M   S(i,j) ~= 0, j in R    (4)
%            S(i,j)*v(j) - M*w(i,j) <= 0     S(i,j) ~= 0, j in R    (5)
%            sum(w(i,:)) - xnp(i) >= 0                              (6)
%            lb <= v <= ub
%            xnp and w are binary variables, v are continuous
%
%
% Jeff Orth 7/6/09

if nargin < 2
    findNCgaps = false;
end
if nargin < 3
    verbFlag = false;
end

M = length(model.rxns); %this was set to 100 in GAMS GapFind implementation
N = length(model.mets);
R = model.rev ~= 0; %reversible reactions
R_index = find(R);
IR = model.rev == 0; %irreversible reactions
IR_index = find(IR);
e = 0.0001;
S = model.S;
lb = model.lb;
ub = model.ub;

% MILPproblem
%  A      LHS matrix
%  b      RHS vector
%  c      Objective coeff vector
%  lb     Lower bound vector
%  ub     Upper bound vector
%  osense Objective sense (-1 max, +1 min)
%  csense Constraint senses, a string containting the constraint sense for
%         each row in A ('E', equality, 'G' greater than, 'L' less than).
%  vartype Variable types
%  x0      Initial solution

% initialize MILP fields

% get number of rows and cols for each constraint
%rows
m_c1 = N; %number of metabolites
m_c2 = length(find(S(:,IR) > 0)); %number of Sij>0 in irreverisible reactions
m_c3 = m_c2;
m_c4 = length(find(S(:,R))); %number of Sij>0 in reversible reactions
m_c5 = m_c4;
m_c6 = N; %number of xnp (metabolites)
%columns
n_v = M; %number of reactions
n_wij_IR = m_c2;
n_wij_R = m_c4;
n_xnp = N;

% LHS matrix A

% constraint 1
A = [S sparse(m_c1,(n_wij_IR+n_wij_R+n_xnp))];

% constraint 2
% create Sij IR matrix and wij IR matrix
Sij_IR = sparse(m_c2,n_v);
wij_IR = sparse(m_c6,n_wij_IR);
row = 1;
for i = 1:length(IR_index)
    rxn_index = IR_index(i);
    met_index = find(S(:,rxn_index) > 0);
    for j = 1:length(met_index)
        Sij_IR(row,rxn_index) = S(met_index(j),rxn_index);
        wij_IR(met_index(j),row) = 1;
        row = row + 1;
    end
end  

A = [A ; Sij_IR -e*speye(m_c2,n_wij_IR) sparse(m_c2,(n_wij_R+n_xnp))];

% constraint 3
A = [A ; Sij_IR -M*speye(m_c3,n_wij_IR) sparse(m_c3,(n_wij_R+n_xnp))];

% constraint 4
% create Sij R matrix
Sij_R = sparse(m_c4,n_v);
wij_R = sparse(m_c6,n_wij_R);
row = 1;
for i = 1:length(R_index)
    rxn_index = R_index(i);
    met_index = find(S(:,rxn_index) ~= 0);
    for j = 1:length(met_index)
        Sij_R(row,rxn_index) = S(met_index(j),rxn_index);
        wij_R(met_index(j),row) = 1;
        row = row + 1;
    end
end  

A = [A ; Sij_R sparse(m_c4,n_wij_IR) -M*speye(m_c4,n_wij_R) sparse(m_c4,n_xnp)];

% constraint 5
A = [A ; Sij_R sparse(m_c5,n_wij_IR) -M*speye(m_c5,n_wij_R) sparse(m_c5,n_xnp)];

% constraint 6
A = [A ; sparse(m_c6,n_v) wij_IR wij_R -1*speye(m_c6,n_xnp)];

% RHS vector b 
b = [zeros(m_c1+m_c2+m_c3,1);(e-M)*ones(m_c4,1);zeros(m_c5+m_c6,1)];

% objective coefficient vector c
c = [zeros(n_v+n_wij_IR+n_wij_R,1);ones(n_xnp,1)];

% upper and lower bounds on variables (v,w,xnp) 
lb = [lb;zeros(n_wij_IR+n_wij_R+n_xnp,1)];
ub = [ub;ones(n_wij_IR+n_wij_R+n_xnp,1)];

% objective sense osense
osense = -1; %want to maximize objective

% constraint senses csense
if findNCgaps
    csense(1:m_c1) = 'E';
else
    csense(1:m_c1) = 'G';
end
csense((m_c1+1):(m_c1+m_c2)) = 'G';
csense((m_c1+m_c2+1):(m_c1+m_c2+m_c3)) = 'L';
csense((m_c1+m_c2+m_c3+1):(m_c1+m_c2+m_c3+m_c4)) = 'G';
csense((m_c1+m_c2+m_c3+m_c4+1):(m_c1+m_c2+m_c3+m_c4+m_c5)) = 'L';
csense((m_c1+m_c2+m_c3+m_c4+m_c5+1):(m_c1+m_c2+m_c3+m_c4+m_c5+m_c6)) = 'G';

% variable types vartype
vartype(1:n_v) = 'C';
vartype((n_v+1):(n_v+n_wij_IR+n_wij_R+n_xnp)) = 'B';

% inital solution x0
x0 = [];


% run COBRA MILP solver    
gapFindMILPproblem.A = A;
gapFindMILPproblem.b = b;
gapFindMILPproblem.c = c;
gapFindMILPproblem.lb = lb;
gapFindMILPproblem.ub = ub;
gapFindMILPproblem.osense = osense;
gapFindMILPproblem.csense = csense;
gapFindMILPproblem.vartype = vartype;
gapFindMILPproblem.x0 = x0;

if verbFlag
    parameters.printLevel = 3; 
else
    parameters.printLevel = 0;
end

solution = solveCobraMILP(gapFindMILPproblem,parameters);

% get the list of gaps from MILP solution
metsProduced = solution.full((n_v+n_wij_IR+n_wij_R+1):(n_v+n_wij_IR+n_wij_R+n_xnp),1);
allGaps = model.mets(~metsProduced);
rootGaps = findRootNPmets(model,findNCgaps); %identify root gaps using findRootNPmets
downstreamGaps = allGaps(~ismember(allGaps,rootGaps));




