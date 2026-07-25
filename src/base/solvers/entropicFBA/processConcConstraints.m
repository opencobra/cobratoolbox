function [f, u0, c0l, c0u, l_c, u_c, dcl, dcu, l_w, u_w, B, b, l_r, u_r, paramOut] = processConcConstraints(model, param)
% Derives the concentration-related bounds, weights, and external
% stoichiometry used to build an entropic flux balance analysis (EFBA)
% concentration subproblem from a COBRA model and EFBA parameter structure
%
% USAGE:
%
%    [f, u0, c0l, c0u, l_c, u_c, dcl, dcu, l_w, u_w, B, b, l_r, u_r, paramOut] = processConcConstraints(model, param)
%
% INPUTS:
%    model:         COBRA model structure with the following required
%                   fields:
%
%                     * .S - `m x (n + k)` stoichiometric matrix, where `n`
%                       is the number of stoichiometrically consistent
%                       (internal) reactions and `k` is the number of
%                       stoichiometrically inconsistent (external) reactions
%                     * .c - `(n + k) x 1` linear objective coefficients
%                     * .lb - `(n + k) x 1` lower bounds on net flux
%                     * .ub - `(n + k) x 1` upper bounds on net flux
%                     * .SConsistentRxnBool - `(n + k) x 1` boolean
%                       indicating the stoichiometrically consistent
%                       (internal) reactions
%
%                   and the following optional fields:
%
%                     * .rxns - `(n + k) x 1` cell array of reaction
%                       identifiers, used only to report inconsistent
%                       reactions
%                     * .pp - `m x 1` boolean vector indicating the
%                       independent rows of `[N, b]` (default: all rows);
%                       also used to restrict `b`, `B`, `l_r`, and `u_r` to
%                       the independent rows
%                     * .b - `m x 1` right hand side of `N*v = b` (default:
%                       0)
%                     * .f - `m x 1` strictly positive weight on
%                       concentration entropy maximisation, or `'rand'`,
%                       `'one'`, or `'two'` (default `'one'`)
%                     * .u0 - `m x 1` standard transformed Gibbs energy of
%                       formation, or `'rand'`, `'one'`, or `'zero'`
%                       (default `'zero'`)
%                     * .c0l - `m x 1` non-negative lower bound on initial
%                       molecular concentrations (default 0)
%                     * .c0u - `m x 1` non-negative upper bound on initial
%                       molecular concentrations (default `param.maxConc`)
%                     * .l_c - `m x 1` non-negative lower bound on final
%                       molecular concentrations
%                     * .u_c - `m x 1` non-negative upper bound on final
%                       molecular concentrations
%                     * .dcl - `m x 1` real valued lower bound on the
%                       difference between final and initial molecular
%                       concentrations (default -inf)
%                     * .dcu - `m x 1` real valued upper bound on the
%                       difference between final and initial molecular
%                       concentrations (default inf)
%                     * .gasConstant - gas constant in kJ/(K*mol) (default
%                       8.3144621e-3)
%                     * .T - scalar temperature; takes precedence over
%                       `.temperature` if both are present
%                     * .temperature - scalar temperature in Kelvin
%                       (default 310.15)
%
%    param:         Structure with the following optional fields:
%
%                     * .concUnit - concentration unit conversion factor
%                       (default `10-3`, i.e. assumes concentrations are in
%                       mMol)
%                     * .concentrationBounds - `{('none')}` whether/how to
%                       set bounds on final concentration: `'none'`
%                       (`l_c = 0`, `u_c = inf`), `'setToGiven'` (use
%                       `model.l_c`/`model.u_c`, selected automatically
%                       when both are present), or `'maximimumFiniteRange'`
%                       (use `param.minConc`/`param.maxConc`)
%                     * .maxConc - (1e4) maximum micromolar concentration
%                       allowed
%                     * .minConc - (1e-4) minimum micromolar concentration
%                       allowed
%                     * .externalNetFluxBounds - `('original')` how to set
%                       the bounds on external net flux and the
%                       initial/final concentration difference:
%                       `'original'` (use `model.lb`/`model.ub`
%                       unmodified), `'identities'`, `'bReplacingB'`,
%                       `'none'`, or `'dxReplacement'` (when `model.dcl` or
%                       `model.dcu` is provided, use them to set the
%                       exchange bounds); defaults to `'dxReplacement'` if
%                       `model.dcl` or `model.dcu` is present, else
%                       `'original'`
%                     * .printLevel - verbose level, used to print
%                       diagnostic messages about the option chosen for
%                       `.externalNetFluxBounds`
%                     * .qpMassBalance - backward-compatible alias; copied
%                       to `.massBalancePenalty` if `.massBalancePenalty`
%                       is absent
%                     * .strictMassBalance - if present, its logical
%                       negation overwrites `.qpMassBalance`
%                     * .massBalancePenalty - `('none')` penalty applied to
%                       the mass-balance regularisation term: `'quadratic'`
%                       (`l_r`/`u_r` unbounded) or `'none'` (`l_r = u_r = 0`)
%
% OUTPUTS:
%    f:             `m x 1` strictly positive weight on concentration
%                   entropy maximisation
%    u0:            `m x 1` standard transformed Gibbs energy of formation,
%                   divided by `gasConstant*temperature` if both are given
%    c0l:           `m x 1` non-negative lower bound on initial molecular
%                   concentrations
%    c0u:           `m x 1` non-negative upper bound on initial molecular
%                   concentrations
%    l_c:           `m x 1` non-negative lower bound on final molecular
%                   concentrations
%    u_c:           `m x 1` non-negative upper bound on final molecular
%                   concentrations
%    dcl:           `m x 1` real valued lower bound on the difference
%                   between final and initial molecular concentrations
%    dcu:           `m x 1` real valued upper bound on the difference
%                   between final and initial molecular concentrations
%    l_w:           `k x 1` lower bound on external net flux
%    u_w:           `k x 1` upper bound on external net flux
%    B:             `m x k` external stoichiometric matrix (rows
%                   restricted to `model.pp` when present)
%    b:             right hand side of `N*v = b` (rows restricted to
%                   `model.pp` when present)
%    l_r:           lower bound on the regularisation term in
%                   `N*v + r = b` (default -inf)
%    u_r:           upper bound on the regularisation term in
%                   `N*v + r = b` (default inf)
%    paramOut:      `param` structure, returned to capture any fields set
%                   internally (e.g. defaulted fields)
%
% .. Author(s): Ronan Fleming

N=model.S(:,model.SConsistentRxnBool);  % internal stoichiometric matrix
B=model.S(:,~model.SConsistentRxnBool); % external stoichiometric matrix
[m,n]=size(N);
k=nnz(~model.SConsistentRxnBool);

if ~isfield(model,'pp')
    model.pp = ones(m,1);
end
%
if isfield(model,'b')
    %compatible with use of row reduced [model.S(:,model.SConsistentRxnBool), b]
    b = model.b(model.pp);
else
    b = zeros(nnz(model.pp),1);
end

%assume units are in mMol
if ~isfield(param,'concUnit')
    param.concUnit = 10-3;
end

%% processing for concentrations
if ~isfield(param,'concentrationBounds')
    param.concentrationBounds='none';
end
if ~isfield(param,'maxConc')
    param.maxConc=inf;
end
if ~isfield(param,'minConc')
    param.minConc=0;
end

%for backward compatiblity
if isfield(param,'qpMassBalance')
    param.massBalancePenalty = param.qpMassBalance;
end
if ~isfield(param,'massBalancePenalty')
    param.massBalancePenalty='none';
end


if ~isfield(param,'externalNetFluxBounds')
    if isfield(model,'dcl') || isfield(model,'dcu')
        param.externalNetFluxBounds='dxReplacement';
    else
        param.externalNetFluxBounds='original';
    end
end

nMetabolitesPerRxn = sum(model.S~=0,1)';
bool = nMetabolitesPerRxn>1 & ~model.SConsistentRxnBool;
if any(bool)
    fprintf('%s\n',[ int2str(nnz(bool)) ' stoichiometrically inconsistent reactions involving more than one metabolite'])
    if nnz(bool)>10
        ind=find(bool);
        disp(model.rxns(ind(1:10)))
    else
        disp(model.rxns(bool))
    end
end

if any(~model.SConsistentRxnBool)
    switch param.externalNetFluxBounds
        case 'original'
            if param.printLevel>0
                fprintf('%s\n','Using existing external net flux bounds without modification.')
            end
            if (isfield(model,'dcl') && any(model.dcl~=0)) || (isfield(model,'dcu') && any(model.dcu~=0))
                error('Option clash between param.externalNetFluxBounds=''original'' and (isfield(model,''dcl'') && any(model.dcl~=0)) || (isfield(model,''dcu'') && any(model.dcu~=0))')
            end
            %
            l_w = model.lb(~model.SConsistentRxnBool);
            u_w = model.ub(~model.SConsistentRxnBool);
            %force initial and final concentration to be equal
            dcl = zeros(m,1);
            dcu = zeros(m,1);
        case 'identities'
            singletonBool = ((model.S~=0)'*ones(m,1))==1;
            if any(singletonBool(~model.SConsistentRxnBool))
                fprintf('\n%s','Ingnoring the following external reactions: ')
                printRxnFormula(model,model.rxns(singletonBool & ~model.SConsistentRxnBool))
            end
            l_w = -inf*ones(2*m,1);
            u_w =  inf*ones(2*m,1);
            %force initial and final concentration to be equal
            dcl = zeros(m,1);
            dcu = zeros(m,1);
            for j=n+1:n+k
                if singletonBool(j)
                    for i = 1:m
                        if model.S(i,j)~=0
                            if model.S(i,j)<0
                                dcl(i) = -model.ub(j);
                                dcu(i) = -model.lb(j);
                                cw(i)  = -model.c(j);%TODO check that is correct
                                cw(i+m)  =  model.c(j);
                            else
                                dcl(i) = model.lb(j);
                                dcu(i) = model.ub(j);
                                cw(i)  = model.c(j);
                                cw(i+m)  = -model.c(j);
                            end

                        end
                        break
                    end
                end
            end
            B = [-speye(m), speye(m)];
        case 'bReplacingB'
            B=B*0;
            l_w =  zeros(k,1);
            u_w =  zeros(k,1);
            dcl = zeros(m,1);
            dcu = zeros(m,1);
        case 'none'
            if param.printLevel>0
                fprintf('%s\n','Using no external net flux bounds.')
            end
            l_w = -ones(k,1)*inf;
            u_w =  ones(k,1)*inf;
            %force initial and final concentration to be equal
            dcl = zeros(m,1);
            dcu = zeros(m,1);
            % l_r = zeros(m,1);
            % u_r = zeros(m,1);
        case 'dxReplacement'
            %TODO
            error('revise how net initial and final conc bounds are dealt with')
            if ~isfield(model,'dcl')
                %close bounds by default
                model.dcl = zeros(m,1);
                dxlB =  -B*model.lb(~model.SConsistentRxnBool);
                dcl(dxlB~=0)=dxlB(dxlB~=0);
            end
            if ~isfield(model,'dcu')
                %close bounds by default
                dcu = zeros(m,1);
                dxuB =  -B*model.ub(~model.SConsistentRxnBool);
                dcu(dxuB~=0)=dxuB(dxuB~=0);
            end
            %eliminate all exchange reactions
            B = B*0;
            l_w = model.lb(~model.SConsistentRxnBool)*0;
            u_w = model.ub(~model.SConsistentRxnBool)*0;
            l_r = zeros(m,1);
            u_r = zeros(m,1);
        otherwise
            error(['param.externalNetFluxBounds = ' param.externalNetFluxBounds ' is an unrecognised input'])
    end
else
    l_w = [];
    u_w =  [];
    dcl = -inf*ones(m,1);
    dcu =  inf*ones(m,1);
end


if isfield(param,'strictMassBalance')
    param.qpMassBalance=~param.strictMassBalance;
end

switch param.massBalancePenalty
    case 'quadratic'
        l_r = -inf*ones(nnz(model.pp),1);
        u_r =  inf*ones(nnz(model.pp),1);
    case 'none'
        l_r = zeros(nnz(model.pp),1);
        u_r = zeros(nnz(model.pp),1);
    otherwise
        error(['param.massBalancePenalty = ' param.massBalancePenalty ' is an unrecognised input'])
end

clear lb ub

if isfield(model,'c0l')
    c0l = model.c0l;
else
    c0l = zeros(m,1);
end
if isfield(model,'c0u')
    c0u = model.c0u;
else
    c0u = param.maxConc*ones(m,1);
end

if isfield(model,'l_c') && isfield(model,'u_c')
    param.concentrationBounds = 'setToGiven';
end

switch param.concentrationBounds
    case 'none'
        l_c = zeros(m,1);
        u_c = inf*ones(m,1);      
    case 'setToGiven'
        if isfield(model,'l_c') && isfield(model,'u_c')
            l_c = model.l_c;
            u_c = model.u_c;
        end
    case 'maximimumFiniteRange'
        l_c = param.minConc*ones(m,1);
        u_c = param.maxConc*ones(m,1);
    otherwise
        error('unrecognised option for param.concentrationBounds')
end

if ~isfield(model,'u0') || isempty(model.u0)
    model.u0='zero';
end
if ischar(model.u0)
    switch model.u0
        case 'rand'
            u0=rand(m,1);
        case 'one'
            u0=ones(m,1);
        case 'zero'
            u0=zeros(m,1);
        otherwise
            error('unrecognised option for model.u0')
    end
else
    if length(model.u0)==size(model.S,1)
        u0 = columnVector(model.u0);
    else
        if length(model.u0)==1
            u0=ones(m,1)*model.u0;
        else
            error('model.u0 is of incorrect dimension')
        end
    end
    if any(~isfinite(u0))
        error('u0 must be finite')
    end
end



% Define constants
if isfield(model,'gasConstant') && isfield(model,'T')
    if isfield(model,'gasConstant')
        gasConstant = model.gasConstant;
    else
        gasConstant=8.3144621e-3; % Gas constant in kJ/(K*mol) %same as vonB default
    end
    if isfield(model,'T')
        temperature = model.T;
    else
        if isfield(model,'temperature')
            temperature = model.temperature;
        else
            temperature = 310.15;
        end
    end
    %dimensionless
    u0 = u0/(gasConstant*temperature);
end

if ~isfield(model,'f') || isempty(model.f)
    model.f='one';
end
if ischar(model.f)
    switch model.f
        case 'rand'
            f=N'*rand(m,1);
        case 'one'
            f=ones(m,1);
        case 'two'
            f=ones(m,1)*2;
    end
else
    if length(model.f)==size(model.S,1)
        f = columnVector(model.f);
    else
        if length(model.f)==1
            f=ones(m,1)*model.f;
        end
    end
    if any(~isfinite(f))
        error('f must all be finite')
    end
end

if isfield(model,'pp')
    %compatible with use of row reduced [model.S(:,model.SConsistentRxnBool), b]
    B = B(model.pp,:);
end

paramOut=param;