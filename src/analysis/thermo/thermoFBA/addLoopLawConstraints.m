function [MILPproblem, loopInfo] = addLoopLawConstraints(LPproblem, model, rxnIndex, method, reduce_vars, preprocessing, loopInfo, printLevel)
% Adds loop law constraints to LP problem or MILP problem.
%
% USAGE:
%
%    [MILPproblem] = addLoopLawConstraints(LPproblem, model, rxnIndex)
%
% INPUTS:
%    LPproblem:      Structure containing the following fields:
%
%                      * A - LHS matrix
%                      * b - RHS vector
%                      * c - Objective coeff vector
%                      * lb - Lower bound vector
%                      * ub - Upper bound vector
%                      * osense - Objective sense (-1 max, +1 min)
%                      * csense - Constraint senses, a string containting the constraint sense for
%                        each row in A ('E', equality, 'G' greater than, 'L' less than).
%                      * F - (optional) If `*QP` problem
%                      * vartype - (optional) if `MI*P` problem
%    model:          The model for which the loops should be removed
%
% OPTIONAL INPUT:
%    rxnIndex:       The index of variables in LPproblem corresponding to fluxes. Default = `[1:n]`
%    method:         Indicator which method to use:
%                    * 1 - Two variables for each reaction af, ar
%                    * 2 - One variable for each reaction af (default)
%    reduce_vars:    eliminates additional integer variables.  Should be faster in all cases but in practice may not be for some weird reason (default : true).
%    preprocessing:  'original': use the original nullspace for internal reactions (Schellenberger et al., 2009)
%                    'fastSNP':  use the minimal feasible nullspace found by Fast-SNP (Saa and Nielson, 2016)
%                    'LLC-NS':   (default): use the minimal feasible nullspace found by solving a MILP (Chan et al., 2017)
%                    'LLC-EFM':  find whether reactions in cycles are connected by EFMs or not 
%                                for faster localized loopless constraints (Chan et al., 2017)
%    loopInfo:       Use previously calculated data to save preprocessing time
%
% OUTPUT:
%    MILPproblem:    Problem structure containing the following fields describing an MILP problem:
%
%                      * A, b, c, lb, ub - same as before but longer
%                      * vartype - variable type of the MILP problem ('C', and 'B')
%                      * `x0 = []` - Needed for `solveMILPproblem`
%
% .. Author: - Jan Schellenberger Sep 27, 2009

if ~exist('method','var') || isempty(method)
    method = 2;
end
if ~exist('reduce_vars','var') || isempty(reduce_vars)
    reduce_vars = 1;
end
if ~exist('preprocessing', 'var') || isempty(preprocessing)
    preprocessing = 'LLC-NS';
end

% different ways of doing it.  I'm still playing with this.
if nargin < 3
    if size(LPproblem.A,2) == size(model.S,2) % if the number of variables matches the number of model reactions
        rxnIndex = 1:size(model.S,2);
    elseif size(LPproblem.A,2) > size(model.S,2)
        display('warning:  extra variables in LPproblem.  will assume first n correspond to v')
        rxnIndex = 1:size(model.S,2);
    else
        display('LPproblem must have at least as many variables as model has reactions');
        return;
    end
elseif length(find(rxnIndex)) ~= size(model.S,2)
    display('rxnIndex must contain exactly n entries');
    return;
end
if any(rxnIndex > size(LPproblem.A,2))
    display('rxnIndex out of bounds');
    return;
end

% Perhaps this should be moved before the "different ways of doing this" -
% line 47, so the function will not crash retuning an undefined value?
% Either that, or change the display/return to error?
MILPproblem = LPproblem;

S = model.S;
[m,n] = size(LPproblem.A);

% find nullspace matrix
if ~exist('loopInfo', 'var') || isempty(loopInfo)
    loopInfo = struct();
    switch preprocessing
        case 'original'
            % original implementation (Schellenberger et al., 2009)
            if ~isfield(model,'SIntRxnBool')
                model = findSExRxnInd(model);
            end
            isInternal = model.SIntRxnBool; % internal, presumably mass balanced reactions
            if reduce_vars == 1
                active = ~(model.lb ==0 & model.ub == 0);
                S2 = S(:,active); % exclude rxns with ub/lb ==0
                
                N2 = sparseNull(sparse(S2));
                N = zeros(length(active), size(N2,2));
                N(active,:) = N2;
                %size(N)
                active = active & any(abs(N) > 1e-6, 2); % exclude rxns not in null space
                %size(active)
                %size(nontransport)
                isInternal = isInternal & active;
            end
            
            Sn = S(:, isInternal);
            
            Ninternal = sparseNull(sparse(Sn));
            loopInfo.N = sparse(size(S, 2), size(Ninternal, 2));
            loopInfo.N(isInternal, :) = Ninternal;
            loopInfo.isInternal = isInternal;
        case 'fastSNP'
            % Fast-SNP (Saa and Nielson, 2016)
            Ninternal = fastSNP(model);
            loopInfo.N = Ninternal;
            isInternal = any(Ninternal, 2);
            Ninternal = Ninternal(isInternal, :);
            loopInfo.isInternal = isInternal;
        otherwise
            % LLC preprocessing. Solve one single MILP (Chan et al., 2017)
            [loopInfo.rxnInLoops, Ninternal] = findMinNull(model, 1);
            loopInfo.conComp = connectedRxnsInNullSpace(Ninternal);
            loopInfo.N = Ninternal;
            isInternal = any(Ninternal, 2);
            Ninternal = Ninternal(isInternal, :);
            loopInfo.isInternal = isInternal;
            if strcmpi(preprocessing, 'LLC-EFM')
                % find connections by EFMs between reactions in cycles
                loopInfo.rxnLink = getRxnLink(model, loopInfo.conComp, loopInfo.rxnInLoops);
            end
    end
else
    % nullspace matrix given as input
    isInternal = loopInfo.isInternal;
    Ninternal = loopInfo.N(isInternal, :);
end

linternal = size(Ninternal,2);

nint = length(find(isInternal));
temp = sparse(nint, n);
temp(:, rxnIndex(isInternal)) = speye(nint);

if strncmpi(preprocessing, 'llc', 3)
    % store the variable and constraint orders in the MILP problem for method = 2
    loopInfo.con.vU = (m + 1):(m + nint);
    loopInfo.con.vL = (m + nint + 1):(m + nint * 2);
    loopInfo.con.gU = (m + nint * 2 + 1):(m + nint * 3);
    loopInfo.con.gL = (m + nint * 3 + 1):(m + nint * 4);
    loopInfo.var.z = (n + 1):(n + nint);
    loopInfo.var.g = (n + nint + 1):(n + nint * 2);
    loopInfo.rxnInLoopIds = zeros(size(model.S, 2), 1);
    loopInfo.rxnInLoopIds(any(loopInfo.rxnInLoops, 2)) = 1:nint;
    loopInfo.Mv = 10000;  % big M for constraints on fluxes
    loopInfo.Mg = 100;  % big M for constraints on enegy variables
    loopInfo.BDg = 1000;  % default bound for energy variables    
end

if method == 1 % two variables (ar, af)
    MILPproblem.A = [LPproblem.A, sparse(m,3*nint);   % Ax = b (from original LPproblem)
        temp, -10000*speye(nint), sparse(nint, 2*nint); % v < 10000*af
        temp, sparse(nint, nint), 10000*speye(nint), sparse(nint, nint); % v > -10000ar
        sparse(nint, n), speye(nint), speye(nint), sparse(nint, nint);  % ar + af <= 1
        sparse(nint, n), -100*speye(nint), 1*speye(nint), speye(nint);  % E < 100 af - ar
        sparse(nint, n), -1*speye(nint), 100*speye(nint), speye(nint);  % E > af - 100 ar
        sparse(linternal, n+2*nint), Ninternal']; % N*E = 0
    
    MILPproblem.b = [LPproblem.b;
        zeros(2*nint,1);
        ones(nint,1);
        zeros(2*nint + linternal,1);];
    
    MILPproblem.c = [LPproblem.c;
        zeros(3*nint,1)];
    
    MILPproblem.csense = LPproblem.csense;
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'L';end   % v < 1000*af
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'G';end  % v > -1000ar
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'L';end  % ar + af < 1
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'L';end  % E <
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'G';end  % E >
    for i = 1:linternal, MILPproblem.csense(end+1,1) = 'E';end % N*E = 0
    
    MILPproblem.vartype = '';
    if isfield(LPproblem, 'vartype')
        MILPproblem.vartype = LPproblem.vartype;  % keep variables same as previously.
    else
        for i = 1:n, MILPproblem.vartype(end+1,1) = 'C';end; %otherwise define as continuous (used for all LP problems)
    end
    for i = 1:2*nint, MILPproblem.vartype(end+1,1) = 'B';end;
    for i = 1:nint, MILPproblem.vartype(end+1,1) = 'C';end;
    
    if isfield(LPproblem, 'F') % used in QP problems
        MILPproblem.F = sparse(size(MILPproblem.A,2),   size(MILPproblem.A,2));
        MILPproblem.F(1:size(LPproblem.F,1), 1:size(LPproblem.F,1)) = LPproblem.F;
    end
    
    
    MILPproblem.lb = [LPproblem.lb;
        zeros(nint*2,1);
        -1000*ones(nint,1);];
    MILPproblem.ub = [LPproblem.ub;
        ones(nint*2,1);
        1000*ones(nint,1);];
    
    MILPproblem.x0 = [];
    
elseif method == 2 % One variables (a)
    MILPproblem.A = [LPproblem.A, sparse(m,2*nint);   % Ax = b (from original LPproblem)
        temp, -10000*speye(nint), sparse(nint, nint); % v < 10000*af
        temp, -10000*speye(nint), sparse(nint, nint); % v > -10000 + 10000*af
        sparse(nint, n), -101*speye(nint), speye(nint);  % E < 100 af - ar
        sparse(nint, n), -101*speye(nint), speye(nint);  % E > af - 100 ar
        sparse(linternal, n + nint), Ninternal']; % N*E = 0
    
    MILPproblem.b = [LPproblem.b; % Ax = b (from original problem)
        zeros(nint,1); % v < 10000*af
        -10000*ones(nint, 1); % v > -10000 + 10000*af
        -ones(nint,1); % e<
        -100*ones(nint, 1); % e>
        zeros(linternal,1)];
    
    MILPproblem.c = [LPproblem.c;
        zeros(2*nint,1)];
    
    MILPproblem.csense = LPproblem.csense;
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'L';end   % v < 1000*af
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'G';end  % v > -1000ar
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'L';end  % E <
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'G';end  % E >
    for i = 1:linternal, MILPproblem.csense(end+1,1) = 'E';end % N*E = 0
    
    MILPproblem.vartype = '';
    if isfield(LPproblem, 'vartype')
        MILPproblem.vartype = LPproblem.vartype;  % keep variables same as previously.
    else
        for i = 1:n, MILPproblem.vartype(end+1,1) = 'C';end; %otherwise define as continuous (used for all LP problems)
    end
    for i = 1:nint, MILPproblem.vartype(end+1,1) = 'B';end; % a variables
    for i = 1:nint, MILPproblem.vartype(end+1,1) = 'C';end; % G variables
    
    if isfield(LPproblem, 'F') % used in QP problems
        MILPproblem.F = sparse(size(MILPproblem.A,2),   size(MILPproblem.A,2));
        MILPproblem.F(1:size(LPproblem.F,1), 1:size(LPproblem.F,1)) = LPproblem.F;
    end
    
    
    MILPproblem.lb = [LPproblem.lb;
        zeros(nint,1);
        -1000*ones(nint,1);];
    MILPproblem.ub = [LPproblem.ub;
        ones(nint,1);
        1000*ones(nint,1);];
    
    MILPproblem.x0 = [];
elseif method == 3 % like method 3 except reduced constraints.
    MILPproblem.A = [LPproblem.A, sparse(m,2*nint);   % Ax = b (from original LPproblem)
        temp, -10000*speye(nint), sparse(nint, nint); % -10000 < v -10000*af < 0
        %temp, -10000*speye(nint), sparse(nint, nint); % v > -10000 + 10000*af
        sparse(nint, n), -101*speye(nint), speye(nint);  %  -100 < E - 101 af < -1
        %sparse(nint, n), -101*speye(nint), speye(nint);  % E > af - 100 ar
        sparse(linternal, n + nint), Ninternal']; % N*E = 0
    
    MILPproblem.b_L = [LPproblem.b; % Ax = b (from original problem)
        %zeros(nint,1); % v < 10000*af
        -10000*ones(nint, 1); % v > -10000 + 10000*af
        %-ones(nint,1); % e<
        -100*ones(nint, 1); % e>
        zeros(linternal,1);];
    MILPproblem.b_U = [LPproblem.b; % Ax = b (from original problem)
        zeros(nint,1); % v < 10000*af
        %-10000*ones(nint, 1); % v > -10000 + 10000*af
        -ones(nint,1); % e<
        %-100*ones(nint, 1); % e>
        zeros(linternal,1);];
    
    MILPproblem.b_L(find(LPproblem.csense == 'E')) = LPproblem.b(LPproblem.csense == 'E');
    MILPproblem.b_U(find(LPproblem.csense == 'E')) = LPproblem.b(LPproblem.csense == 'E');
    MILPproblem.b_L(find(LPproblem.csense == 'G')) = LPproblem.b(LPproblem.csense == 'G');
    MILPproblem.b_U(find(LPproblem.csense == 'G')) = inf;
    MILPproblem.b_L(find(LPproblem.csense == 'L')) = -inf;
    MILPproblem.b_U(find(LPproblem.csense == 'L')) = LPproblem.b(LPproblem.csense == 'L');
    
    MILPproblem.c = [LPproblem.c;
        zeros(2*nint,1)];
    
    MILPproblem.csense = [];
    
    MILPproblem.vartype = [];
    if isfield(LPproblem, 'vartype')
        MILPproblem.vartype = LPproblem.vartype;  % keep variables same as previously.
    else
        for i = 1:n, MILPproblem.vartype(end+1,1) = 'C';end; %otherwise define as continuous (used for all LP problems)
    end
    for i = 1:nint, MILPproblem.vartype(end+1,1) = 'B';end; % a variables
    for i = 1:nint, MILPproblem.vartype(end+1,1) = 'C';end; % G variables
    
    if isfield(LPproblem, 'F') % used in QP problems
        MILPproblem.F = sparse(size(MILPproblem.A,2),   size(MILPproblem.A,2));
        MILPproblem.F(1:size(LPproblem.F,1), 1:size(LPproblem.F,1)) = LPproblem.F;
    end
    
    
    MILPproblem.lb = [LPproblem.lb;
        zeros(nint,1);
        -1000*ones(nint,1);];
    MILPproblem.ub = [LPproblem.ub;
        ones(nint,1);
        1000*ones(nint,1);];
    
    MILPproblem.x0 = [];
else
    display('method not found')
    method
end
end

function conComp = connectedRxnsInNullSpace(N)
% find connected components for reactions in cycles given a minimal feasible
% nullspace as defined in Chan et al., 2017. Loopless constraints are required only 
% for the connected components involving reactions required to have no flux 
% through cycles (the target set) in the resultant flux distribution
% Reactions in the same connected component have the same conComp(j).
% Reactions not in any cycles, thus not in any connected components have conComp(j) = 0.
conComp = zeros(size(N, 1), 1);
nCon = 0;
vCur = false(size(N, 1), 1);
while any(conComp == 0 & any(N, 2))
    vCur(:) = false;
    vCur(find(conComp == 0 & any(N, 2), 1)) = true;
    nCon = nCon + 1;
    nCur = 0;
    while nCur < sum(vCur)
        nCur = sum(vCur);
        vCur(any(N(:, any(N(vCur, :), 1)), 2)) = true;
    end
    conComp(vCur) = nCon;
end
end

function rxnLink = getRxnLink(model, conComp, rxnInLoops)
% rxnLink is a n-by-n matrix (n = #rxns). rxnLink(i, j) = 1 ==> reactions i
% and j are connected by an EFM representing an elementary cycle.

% the path to EFMtool
efmToolpath = which('CalculateFluxModes.m');
if isempty(efmToolpath)
    rxnLink = [];
    %     fprintf('EFMtool not in Matlab path. Unable to calculate EFMs.\n')
    return
end
efmToolpath = strsplit(efmToolpath, filesep);
efmToolpath = strjoin(efmToolpath(1: end - 1), filesep);
p = pwd;
cd(efmToolpath)
% EFMtool call options
options = CreateFluxModeOpts('sign-only', true, 'level', 'WARNING');

rxnLink = sparse(size(model.S, 2), size(model.S, 2));
for jC = 1:max(conComp)
    % for each connected component, find the EFM matrix
    try
        S = model.S(:, conComp == jC);
        S = S(any(S, 2), :);
        % revert the stoichiometries for reactions that are in cycles only in the reverse direction
        S(:, rxnInLoops(conComp == jC, 1) & ~rxnInLoops(conComp == jC, 2)) = -S(:, rxnInLoops(conComp == jC, 1) & ~rxnInLoops(conComp == jC, 2));
        rev = all(rxnInLoops(conComp == jC, :), 2);
        efms = CalculateFluxModes(full(S), double(rev), options);
        % calling Java too rapidly may have problems in tests
        pause(1e-4)
        efms = efms.efms;
        rxnJC = find(conComp == jC);
        for j = 1:numel(rxnJC)
            rxnLink(rxnJC(j), rxnJC) = any(efms(:, efms(j, :) ~= 0), 2)';
        end
    catch msg
        fprintf('Error encountered during calculation of EFMs:\n%s', getReport(msg))
        rxnLink = [];
        return
    end
end
cd(p)

end

