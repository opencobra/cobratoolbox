function [vl,vu,vel,veu,vfl,vfu,vrl,vru,ci,ce,cf,cr,g] = processFluxConstraints(model,param)
%
% USAGE:
%   processFluxConstraints(model)
%   processFluxConstraints(model,param)
%
% INPUTS:
%    model:             (the following fields are required - others can be supplied)
%
%          * S  - `m x (n + k)` Stoichiometric matrix
%          * c  - `(n + k) x 1` Linear objective coefficients
%          * lb - `(n + k) x 1` Lower bounds on net flux
%          * ub - `(n + k) x 1` Upper bounds on net flux          
%
% OPTIONAL INPUTS
%   model.osenseStr: ('max') or 'min'. The default linear objective sense is maximisation, i.e. 'max'
%   model.cf:       n x 1    real valued linear objective coefficients on internal forward flux (default 0)
%   model.cr:       n x 1    real valued linear objective coefficients on internal reverse flux (default 0)
%   model.g         n x 1    strictly positive weight on internal flux entropy maximisation (default 2) 
%   model.SConsistentRxnBool: n x 1  boolean indicating  stoichiometrically consistent metabolites
%   model.vfl:      n x 1    non-negative lower bound on internal forward flux (default 0) 
%   model.vfu:      n x 1    non-negative upper bound on internal forward flux (default inf) 
%   model.vrl:      n x 1    non-negative lower bound on internal reverse flux (default 0) 
%   model.vru:      n x 1    non-negative upper bound on internal reverse flux (default 0) 
%
%  param.printLevel:
%  param.solver:    {'pdco',('mosek')}
%  param.debug:     {(0),1} 1 = run in debug mode 
%  param.entropicFBAMethod:    {('fluxes'),'fluxesConcentrations'} maximise entropy of fluxes (default) or also concentrations
%  param.maxUnidirectionalFlux: maximum unidirectional flux (1e5 by default)
%  param.minUnidirectionalFlux: minimum unidirectional flux (zero by default)
%  param.internalNetFluxBounds: ('original')   = use model.lb and model.ub to set the direction and magnitude of internal net flux bounds
%                                'directional' = use model.lb and model.ub to set the direction of net flux bounds (ignoring magnitude)
%                                'none'        = ignore model.lb and model.ub and allow all net flues to be reversible
%
% OUTPUTS:
% vl:       n x 1    lower bound on internal net flux 
% vu:       n x 1    upper bound on internal net flux
% vel:      k x 1    lower bound on external net flux 
% veu:      k x 1    upper bound on external net flux
% vfl:      n x 1    non-negative lower bound on internal forward flux
% vfu:      n x 1    non-negative upper bound on internal forward flux
% vrl:      n x 1    non-negative lower bound on internal reverse flux 
% vru:      n x 1    non-negative upper bound on internal reverse flux
% ci:       n x 1    linear objective coefficients corresponding to internal net fluxes
% vel:      k x 1    linear objective coefficients corresponding to external net fluxes
% cf:       n x 1    real valued linear objective coefficients on internal forward flux
% cr:       n x 1    real valued linear objective coefficients on internal reverse flux
% g         n x 1    strictly positive weight on internal flux entropy maximisation
%
%
% EXAMPLE:
%
% NOTE:
%
% Author(s): Ronan Fleming

%% processing for fluxes
if ~isfield(param,'maxUnidirectionalFlux')
    %try to set the maximum unidirectional flux based on the magnitude of the largest bound but dont have it greater than 1e5
    param.maxUnidirectionalFlux=min(1e5,max(abs(model.ub)));
    %param.maxUnidirectionalFlux=inf;
end
if ~isfield(param,'minUnidirectionalFlux')
    param.minUnidirectionalFlux = 0;
end

if ~isfield(param,'internalNetFluxBounds')
    param.internalNetFluxBounds='original';
end

if ~isfield(param,'externalNetFluxBounds')
    param.externalNetFluxBounds='original';
end

if ~isfield(param,'entropicFBAMethod')
    if isfield(param,'method') && contains(param.method,'flux')
        param.entropicFBAMethod=param.method;
        param=rmfield(param,'method');
    else
        param.entropicFBAMethod='fluxes';
    end
end

%find the maximal set of metabolites and reactions that are stoichiometrically consistent
if ~isfield(model,'SConsistentMetBool') || ~isfield(model,'SConsistentRxnBool')
    massBalanceCheck=0;
    [~, ~, ~, ~, ~, ~, model, ~] = findStoichConsistentSubset(model, massBalanceCheck, param.printLevel-1);
end

N=model.S(:,model.SConsistentRxnBool);
[m,n]=size(N);
k=nnz(~model.SConsistentRxnBool);

if ~isfield(model,'osenseStr') || isempty(model.osenseStr)
    %default linear objective sense is maximisation
    model.osenseStr = 'max';
end
[~,osense] = getObjectiveSense(model);

if isfield(param,'internalBounds')
    error('internalBounds replaced by other parameter options')
end

if isfield(param,'debug') && param.debug && 0
    solution_optimizeCbModel = optimizeCbModel(model,param);
    switch solution_optimizeCbModel.stat
        case 0
            disp(solution_optimizeCbModel.origStat)
            message = 'Input model is not feasible according to optimizeCbModel.';
            warning(message)
            solution = solution_optimizeCbModel;
            modelOut = model;
            return
        case 1
            message ='Input model is feasible according to optimizeCbModel.';
            disp(message)
            solution = solution_optimizeCbModel;
            messages = cellstr(message);
    end
end

if 0
    %ignore this for now - TODO
    nMetInRxn=sum(model.S~=0,1);
    if any(nMetInRxn==0)
        nTrivialRxn = nnz(nMetInRxn==0);
        error(['model.S is incorrectly specified as it contains ' int2str(nTrivialRxn) ' zero columns'])
    end
    
    nonUnitaryRxn = (nMetInRxn~=1)';
    rxnBool = nonUnitaryRxn & ~model.SConsistentRxnBool;
    if any(rxnBool)
        if param.printLevel> 0
            fprintf('%s\n',['Assigned ' int2str(nnz(rxnBool)) ' non-unitary exchange reactions as stoichiometrically consistent.'])
            if param.printLevel> 1
                printConstraints(model, -inf, inf, rxnBool, [], 0);
            end
        end
        %non-unitary exchange reactions are assumed to be stoichiometrically
        %consistent because it is assumed this model was generated using
        %thermoKernel, and all reactions should be forced in some way
        %TODO why is this reaction one:
        %'CYSTS_H2S'        'Cystathionine Beta-Synthase (sulfide-forming)'    -10000    10000    'cyk_L[c] + hcyk_L[c]  <=> HC00250[c] + cyst_L[c] '
        model.SConsistentRxnBool = model.SConsistentRxnBool | rxnBool;
    end
end

lb=model.lb;
ub=model.ub;
switch param.internalNetFluxBounds
    case {'originalNetFluxBounds','original'}
        if param.printLevel>0
            fprintf('%s\n','Using existing internal net flux bounds without modification.')
        end
    case 'directional'
        if param.printLevel>0
            fprintf('%s\n','Using directional internal net flux bounds only.')
        end
        lb(lb<0 & model.SConsistentRxnBool,1)=-param.maxUnidirectionalFlux;
        lb(lb>0 & model.SConsistentRxnBool,1)=0;
        
        ub(ub>0 & model.SConsistentRxnBool,1)=param.maxUnidirectionalFlux;
        ub(ub<0 & model.SConsistentRxnBool,1)=0;
    case {'maxInternalNetFluxBounds','max'}
        lb(model.SConsistentRxnBool)=-ones(n,1)*param.maxUnidirectionalFlux;
        ub(model.SConsistentRxnBool)= ones(n,1)*param.maxUnidirectionalFlux;
        
    case 'none'
        if isfield(param,'printLevel') && param.printLevel>0
            fprintf('%s\n','Using no internal net flux bounds.')
        end
        lb(model.SConsistentRxnBool,1)=-ones(n,1)*inf;
        ub(model.SConsistentRxnBool,1)= ones(n,1)*inf;
        
    case 'random'
        lb(model.SConsistentRxnBool,1)=-rand(n,1)*param.maxUnidirectionalFlux;
        ub(model.SConsistentRxnBool,1)= rand(n,1)*param.maxUnidirectionalFlux;
        
    case 'rangeNt'
        u1=rand(m,1);
        u2=rand(m,1);
        u=u2-u1;
        %reorient S
        N=N*diag(sign(N'*u));
        lb(model.SConsistentRxnBool,1)=N'*u2;
        ub(model.SConsistentRxnBool,1)=N'*u1;
        
    case 'expRangeNt'
        u1=rand(m,1);
        u2=rand(m,1);
        u=u2-u1;
        %reorient S
        N=N*diag(sign(N'*u));
        lb(model.SConsistentRxnBool,1)=-exp(N'*u2);
        ub(model.SConsistentRxnBool,1)= exp(N'*u1);
        
    otherwise
        error(['param.internalNetFluxBounds = ' param.internalNetFluxBounds ' is an unrecognised input'])
end

switch param.externalNetFluxBounds
    case 'none'
        if param.printLevel>0
            fprintf('%s\n','Using no external net flux bounds.')
        end
        lb(~model.SConsistentRxnBool,1)=-ones(k,1)*inf;
        ub(~model.SConsistentRxnBool,1)= ones(k,1)*inf;
    case 'original'
        if param.printLevel>0
            fprintf('%s\n','Using existing external net flux bounds without modification.')
        end
end

vl = lb(model.SConsistentRxnBool);
vu = ub(model.SConsistentRxnBool);
%exchange reaction bounds (may be overwritten if conc method is chosen)
vel = lb(~model.SConsistentRxnBool);
veu = ub(~model.SConsistentRxnBool);

relaxedUnidirectionalUpperBounds = 1;
%lower bound on forward fluxes
if isfield(model,'vfl')
    vfl = model.vfl;
else
    vfl = max(param.minUnidirectionalFlux,vl);
    %vfl = ones(n,1)*param.minUnidirectionalFlux;
end

if any(vfl<0)
    error('lower bound on forward flux cannot be less than zero')
end
%upper bounds on forward fluxes
if isfield(model,'vfu')
    vfu = model.vfu;
else
    if relaxedUnidirectionalUpperBounds
        vfu = ones(n,1)*param.maxUnidirectionalFlux;
    else
        vfu = vu;
        bool = vfu<=0;
        vfu(bool) = param.maxUnidirectionalFlux;
    end
end
if any(vfl>0)
    if param.printLevel
        fprintf('%s\n','Lower bound on forward flux is positive for the following internal reactions:')
        vfl2= zeros(n+k,1);
        vfl2(model.SConsistentRxnBool,1)=vfl;
        %print the non-zero lower bounds
        printFluxVector(model,vfl2,1);
    end
end
if any(vfl>vfu)
    bool = vfl>vfu;
    %print the problematic bounds
    fprintf('%s%s%s\n','Reaction','vfl','vul')
    vfl2 = vfl;
    vfl2(vfl<=vfu)=0;
    vfl3 = zeros(n+k,1);
    vfl3(model.SConsistentRxnBool,1)=vfl;

    vfu2 = vfu;
    vfu2(vfl<=vfu)=0;
    vfu3 = zeros(n+k,1);
    vfu3(model.SConsistentRxnBool,1)=vfu;
    printFluxVector(model,[vfl3,vfu3],1);
    error('lower bound on forward flux is greater than upper bound')
end
%lower bounds on reverse fluxes
if isfield(model,'vrl')
    vrl = model.vrl;
else
    vrl = max(param.minUnidirectionalFlux,-vu);
    %vrl = ones(n,1)*param.minUnidirectionalFlux;
end
if any(vrl<0)
    error('lower bound on reverse flux cannot be less than zero')
end
%upper bounds on reverse fluxes
if isfield(model,'vru')
    vru = model.vru;
else
    if relaxedUnidirectionalUpperBounds
        vru = ones(n,1)*param.maxUnidirectionalFlux;
    else
        vru = -vl;
        vru(vru<=0) = param.maxUnidirectionalFlux;
    end
end
if any(vrl>vru)
    error('lower bound on reverse flux is greater than upper bound')
end

if any(vl>0 | vu<0) && ~strcmp(param.internalNetFluxBounds,'original')
    if param.printLevel> 2
        histogram([vl;vu])
        title('internal reaction bounds not directional')
    end
    warning('internal reaction bounds not directional')
end

if ~isfield(model,'c') || isempty(model.c)
    ci = zeros(n,1);
    ce = zeros(k,1);
else
    %osense is only used to changes the sense of the model.c part
    ci = osense*model.c(model.SConsistentRxnBool);
    ce = osense*model.c(~model.SConsistentRxnBool);
end

if ~isfield(model,'cf') && isfield(model,'c_vf')
    model.cf=model.c_vf;
end
if ~isfield(model,'cr') && isfield(model,'c_vr')
    model.cr=model.c_vr;
end

if ~isfield(model,'cf') || isempty(model.cf)
    model.cf='zero';
end
if ~isfield(model,'cr') || isempty(model.cr)
    model.cr='zero';
end
if ischar(model.cf) || ischar(model.cr)
    switch model.cf
        case 'rand'
            cf=N'*rand(m,1);
            cr=-cf;
        case 'one'
            cf=ones(n,1);
            cr=ones(n,1);
        case 'zero'
            cf=zeros(n,1);
            cr=zeros(n,1);
    end
else
    if length(model.cf)~=length(model.cr)
        error('model.cf and model.cr must have the same dimensions')
    end
    if length(model.cf)==size(model.S,2)
        cf = columnVector(model.cf(model.SConsistentRxnBool));
        cr = columnVector(model.cr(model.SConsistentRxnBool));
    else
        if length(model.cf)==1
            model.cf=ones(n,1)*model.cf;
            model.cr=ones(n,1)*model.cr;
        end
        if length(model.cf)~=nnz(model.SConsistentRxnBool)
            error('cf and cr must have the same dimension as nnz(model.SConsistentRxnBool) x 1')
        else
            cf = columnVector(model.cf);
            cr = columnVector(model.cr);
        end
    end
    if any(~isfinite([cf;cr]))
        error('cf and cr must all be finite')
    end
end

if ~isfield(model,'g') || isempty(model.g)
    if isequal(param.entropicFBAMethod,'fluxes')
        model.g='one';
    else
        model.g='two';
    end
end
if ischar(model.g)
    switch model.g
        case 'zero'
            g=zeros(n,1);
        case 'rand'
            g=rand(n,1);
        case 'one'
            g=ones(n,1);
        case 'two'
            g=ones(n,1)*2;
        otherwise
            error('unrecognised option for model.g')
    end
else
    if length(model.g)==size(model.S,2)
        g = columnVector(model.g(model.SConsistentRxnBool));
    else
        if length(model.g)==1
            model.g=ones(n,1)*model.g;
        end
        if length(model.g)~=nnz(model.SConsistentRxnBool)
            error('g and cf must have the same dimension as nnz(model.SConsistentRxnBool) x 1')
        else
            g = columnVector(model.g);
        end
    end
    if any(~isfinite(g))
        error('g must all be finite')
    end
    if length(g)~=length(cf)
        error('g and cf must have the same dimensions')
    end
end