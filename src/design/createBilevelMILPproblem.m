function bilevelMILPproblem = createBilevelMILPproblem(model,cLinear,cInteger,selRxns,...
    selRxnMatch,constrOpt,measOpt,options,selPrevSol)
% Creates the necessary matrices and vectors to solve a bilevel MILP with designated inner
% and outer problem objective functions
%
% USAGE:
%
%    bilevelMILPproblem = createBilevelMILPProblem(model, cLinear, cInteger, selRxns, selRxnMatch, constrOpt, measOpt, options, selPrevSol);
%
% INPUTS:
%    model:         Model in irreversible format
%    cLinear:       Objective for linear part of the MILP problem (i.e. for fluxes)
%    cInteger:      Objective for integer part of the MILP problem
%    selRxns:       Reactions that participate in the integer part (e.g. ones
%                   that can be deleted) (in the form [0 0 1 0 0 1 0 1 1 0 1])
%    selRxnMatch:   Matching of the forward and reverse parts
%    constrOpt:     Constraint options 
%
%                     *  rxnInd
%                     *  values
%                     *  sense
%    measOpt:      Measured flux options
%
%                     *  rxnSel
%                     *  values
%                     *  weights
%    options:      General options
%
%                     *  vMax - Maximal/minimal value for cont variables
%                     *  numDel - Number of deletions
%                     *  numDelSense - # of `ko` <=/=/>= K (L/E/G)
%    selPrevSol:   Previous solutions (optional)
%
% OUTPUTS:
%    bilevelMILPproblem:
%
%                          *  A - LHS matrix
%                          *  b - RHS
%                          *  c - Objective
%                          *  csense - Constraint types
%                          *  lb - Lower bounds
%                          *  ub - Upper bounds
%                          *  vartype - Variable types
%                          *  contSolInd - Allows selecting the continuous solution (i.e. fluxes)
%                          *  intsSolInd - Allows selecting the integer solution (i.e. what reactions are used)
%
% .. Author: - Markus Herrgard 5/27/05
%
% .. Outputs suitable for feeding to feeding into a MILP solver
% .. Variables are in order: v(n), y(n_int), u_eq(m), u_u(n), u_z(n_int) u_b(n_ic) s_mm(n_m) s_mp(n_m)
% .. 1/22/07 Add new interface to allow inclusion in the COBRA Toolbox
% .. 5/24/05 Fixed problem with reversible measured fluxes - requires changing
% .. the interpretation of the sel_m input vector (can now have both positive
% .. & negative entries) MH
% .. 5/27/05 Added ability to rule out particular integer solutions (i.e.
% .. existing solutions) MH
% .. 6/10/05 Added ability to delimit fluxes to a certain range


S = model.S;
ub = model.ub;
c = model.c;
clp = cLinear;
cip = cInteger;
sel_int = selRxns;
rev_int = selRxnMatch;
if (~isempty(constrOpt))
    ind_ic = constrOpt.rxnInd;
    b_ic = constrOpt.values;
    csense_ic = constrOpt.sense;
else
    ind_ic = [];
    b_ic = [];
    csense_ic = [];
end
if (~isempty(measOpt))
    sel_m = measOpt.rxnSel;
    b_m = measOpt.values;
    wt_m= measOpt.weights;
else
    sel_m = [];
    b_m = [];
    wt_m = [];
end
H = options.vMax;
K = options.numDel;
ksense = options.numDelSense;
if (nargin < 9)
    sel_int_prev = [];
else
    sel_int_prev = selPrevSol;
end
% Convert inputs above
% clp           Objective for continuous variables in the outer problem
% cip           Objective for integer variables in the outer problem
% S             Stoichiometric matrix (or equality constraint matrix)
% ub            Upper bounds for inner problem
% c             Objective for inner problem
% sel_int       Varibles (inner) corresponding to the integers (in the form [0 0 1 0 0 1 0 0 0 1 1 0 1 1])
% rev_int       Matchings for reversible varibles corresponding to integers (in the form [1 2;4 5])
% ind_ic        Varibles for which there are additional constraints (in the
% form [1 4 4 5 9]);
% b_ic          Additional constraints (in the form [1.5 2.3 3.2 3.3 1.1])
% csense_ic     Directions of additional constraints (in the form 'EGLLG')
% sel_m         Select measured fluxes (in the form [1 0 0 1 -1 0 0 0 0 0 0 0 0])
% b_m           Values for measured fluxes (in the form [2.9 3.0])
% wt_m          Weights for measured fluxes (in the form [0.1 0.9])
% H             Maximal/minimal value for cont variables
% K             Desired number of reaction knockouts
% ksense        # of ko <=/=/>= K (L/E/G)
% sel_int_prev  Varibles corresponding to the previously selected integers
%               (optional). Same form/dimension as sel_int;

% Dimensions of the primal problem
[m,n] = size(S);
% Number of integer variables
n_int = sum(sel_int);
% Number of inner problem "special" constraints
n_ic = length(ind_ic);
sel_ic = zeros(length(sel_int),1);
sel_ic(ind_ic) = 1;
% Number of inner problem primal varibles with no integers associated with
% them & not part of the special constraint set
n_nint = n - n_int - sum(sel_ic);
% Number of reversible rxns with integer
[n_intr,tmp] = size(rev_int);
% Number of measured fluxes (count only positive directions)
n_m = sum(sel_m == 1);

% Helper arrays for extracting solutions
sel_cont_sol = [1:n];
sel_int_sol = [n+1:n+n_int];

% Set variable types
vartype_bl(1:2*n+2*n_int+m+n_ic+2*n_m) = 'C';
vartype_bl(n+1:n+n_int) = 'B';

% Set upper/lower bounds
lb_bl = [zeros(n+n_int,1); -H*ones(m,1); zeros(n,1); -H*ones(n_int,1)];
ub_bl = [H*ones(2*n+2*n_int+m,1)];
% Handle inner problem constraints
for i = 1:n_ic
    % Don't constraint equality constrained ones or
    if  (strcmp(csense_ic(i),'E'))
        lb_bl = [lb_bl; -H];
        ub_bl = [ub_bl; H];
    % Lower bound constraints
    elseif (strcmp(csense_ic(i),'L'))
        lb_bl = [lb_bl; 0];
        ub_bl = [ub_bl; H];
    % Upper bound constraints
    elseif (strcmp(csense_ic(i),'G'))
        lb_bl = [lb_bl; -H];
        ub_bl = [ub_bl; 0];
    else
        lb_bl = [lb_bl; -H];
        ub_bl = [ub_bl; H];
    end
end
% Slacks for measured fluxes
lb_bl = [lb_bl; zeros(2*n_m,1)];
ub_bl = [ub_bl; H*ones(2*n_m,1)];
ub_bl(vartype_bl == 'B') = 1;

% Set bilevel objective
c_bl = zeros(2*n+2*n_int+m+n_ic+2*n_m,1);
c_bl(1:n) = clp;
c_bl(n+1:n+n_int) = cip;
%c_bl(2*n+2*n_int+m+n_ic+1:2*n+2*n_int+m+n_ic+2*n_m) = 1;
c_bl(2*n+2*n_int+m+n_ic+1:2*n+2*n_int+m+n_ic+n_m) = wt_m;
c_bl(2*n+2*n_int+m+n_ic+n_m+1:2*n+2*n_int+m+n_ic+2*n_m) = wt_m;

%********************************
% Generate the constraint matrix
%********************************

% Create necessary integer matrices (for SF/n_int sets)
Iint = selMatrix(sel_int);
Inint = selMatrix(~sel_int & ~sel_ic);
Iic = sparse(n_ic,n);
for i = 1:length(ind_ic)
    idx_ic = ind_ic(i);
    Iic(i,idx_ic) = 1;
end
Im = selMatrix(sel_m);

% S*v = 0
A_bl = [S sparse(m,2*n_int+n+m+n_ic+2*n_m)];
b_bl = zeros(m,1);
csense_bl(1:m) = 'E';

% v_ic >= b_ic
A_bl = [A_bl; Iic sparse(n_ic,2*n_int+m+n+n_ic+2*n_m)];
b_bl = [b_bl; b_ic];
csense_bl(end+1:end+n_ic) = csense_ic;

% vobj = v_ic*b_ic + Sj ub(j)*uu(j)
A_bl = [A_bl; c' sparse(1,n_int+m) -ub' sparse(1,n_int) -b_ic' sparse(1,2*n_m)];
b_bl = [b_bl; 0];
csense_bl(end+1) = 'E';

% v(j) <= ub(j)*y(j) j in selected
A_bl = [A_bl; Iint sparse(diag(-ub(sel_int == 1))) sparse(n_int,m+n+n_int+n_ic+2*n_m)];
b_bl = [b_bl; zeros(n_int,1)];
csense_bl(end+1:end+n_int) = 'L';

% v(j) <= ub(j) j not in selected or inner constraints
A_bl = [A_bl; Inint sparse(n_nint,m+n+2*n_int+n_ic+2*n_m)];
b_bl = [b_bl; ub(~sel_int & ~sel_ic)];
csense_bl(end+1:end+n_nint) = 'L';

% Dual for inner constraints
A_bl = [A_bl; sparse(n_ic,n+n_int) S(:,ind_ic)' Iic sparse(n_ic,n_int) speye(n_ic) sparse(n_ic,2*n_m)];
b_bl = [b_bl; c(ind_ic)];
csense_bl(end+1:end+n_ic) = 'G';

% Dual bound for n_int ub's
A_bl = [A_bl; sparse(n_nint,n+n_int) S(:,sel_int == 0 & sel_ic == 0)' Inint sparse(n_nint,n_int+n_ic+2*n_m)];
b_bl = [b_bl; zeros(n_nint,1)];
csense_bl(end+1:end+n_nint) = 'G';

% Dual bound for selected ub's
A_bl = [A_bl; sparse(n_int,n) -H*speye(n_int) S(:,sel_int == 1)' Iint sparse(n_int,n_int+n_ic+2*n_m)];
b_bl = [b_bl; -H*ones(n_int,1)];
csense_bl(end+1:end+n_int) = 'G';

% Dual bound for selected <= 0's
A_bl = [A_bl; sparse(n_int,n) H*speye(n_int) S(:,sel_int == 1)' sparse(n_int,n) speye(n_int) sparse(n_int,n_ic+2*n_m)];
b_bl = [b_bl; zeros(n_int,1)];
csense_bl(end+1:end+n_int) = 'G';

% Dual bound for selected >= 0's
A_bl = [A_bl; sparse(n_int,n) -H*speye(n_int) S(:,sel_int == 1)' sparse(n_int,n) speye(n_int) sparse(n_int,n_ic+2*n_m)];
b_bl = [b_bl; zeros(n_int,1)];
csense_bl(end+1:end+n_int) = 'L';

% Create matchings for reversible rxns
rev_match = sparse(n_intr,n_int);
sel_fw_rxn = ones(1,n_int);
for i = 1:n_intr
    rev_match(i,rev_int(i,1)) = 1;
    rev_match(i,rev_int(i,2)) = -1;
    sel_fw_rxn(rev_int(i,1)) = 0;
end
A_bl = [A_bl; sparse(n_intr,n) rev_match sparse(n_intr,m+n+n_int+n_ic+2*n_m)];
b_bl = [b_bl; zeros(n_intr,1)];
csense_bl(end+1:end+n_intr) = 'E';

% Limit maximum number of deletions
A_bl = [A_bl; sparse(1,n) -sel_fw_rxn sparse(1,m+n+n_int+n_ic+2*n_m)];
b_bl = [b_bl; -sum(sel_fw_rxn) + K];
csense_bl(end+1) = ksense;

% Slack constraint for measured values
if (n_m > 0)
    tmp1 = [Im; Im];
    tmp2 = [speye(n_m) sparse(n_m,n_m); sparse(n_m,n_m) -speye(n_m)];
    A_bl = [A_bl; tmp1 sparse(2*n_m,m+n+2*n_int+n_ic) tmp2];
    b_bl = [b_bl; b_m; b_m];
    csense_bl(end+1:end+n_m) = 'G';
    csense_bl(end+1:end+n_m) = 'L';
end

% Add constraint to select a new deletion set (with at least one new deletion)
if (~isempty(sel_int_prev))
    [tmp,n_exko] = size(sel_int_prev);
    for i = 1:n_exko
        A_bl = [A_bl; sparse(1,n) sparse(sel_int_prev(sel_int==1,i)') sparse(1,n+n_int+m+n_ic+2*n_m)];
        b_bl(end+1) = 1;
        csense_bl(end+1) = 'G';
    end
end

% Construct problem structure
bilevelMILPproblem.A = A_bl;
bilevelMILPproblem.b = b_bl;
bilevelMILPproblem.c = c_bl;
bilevelMILPproblem.csense = csense_bl;
bilevelMILPproblem.lb = lb_bl;
bilevelMILPproblem.ub = ub_bl;
bilevelMILPproblem.vartype = vartype_bl;
bilevelMILPproblem.contSolInd = sel_cont_sol;
bilevelMILPproblem.intSolInd = sel_int_sol;
