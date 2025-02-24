function [f,u0,c0l,c0u,cl,cu,dcl,dcu,wl,wu,B,b,rl,ru] = processConcConstraints(model,param)
%
% USAGE:
%   [] = processConcConstraints(model,param)
%
% INPUTS:
%    model: (the following fields are required - others can be supplied)
%
%          * S  - `m x (n + k)` Stoichiometric matrix
%          * c  - `(n + k) x 1` Linear objective coefficients
%          * lb - `(n + k) x 1` Lower bounds on net flux
%          * ub - `(n + k) x 1` Upper bounds on net flux
%
%
% OPTIONAL INPUTS
% model.SConsistentMetBool: m x 1  boolean indicating  stoichiometrically consistent metabolites
% model.SConsistentRxnBool: n x 1  boolean indicating  stoichiometrically consistent metabolites
% model.rxns:
%
%  model.f:       m x 1    strictly positive weight on concentration entropy maximisation (default 1)
%  model.u0:      m x 1    standard transformed Gibbs energy of formation (default 0)
%  model.c0l:     m x 1    non-negative lower bound on initial molecular concentrations
%  model.c0u:     m x 1    non-negative upper bound on initial molecular concentrations
%  model.cl:      m x 1    non-negative lower bound on final molecular concentrations
%  model.cu:      m x 1    non-negative lower bound on final molecular concentrations
%  model.dcl:     m x 1    real valued lower bound on difference between final and initial molecular concentrations   (default -inf)
%  model.dcu:     m x 1    real valued upper bound on difference between final and initial initial molecular concentrations  (default inf)
%  model.gasConstant:    scalar gas constant (default 8.31446261815324 J K^-1 mol^-1)
%  model.temperature:              scalar temperature (default 310.15 Kelvin)
%  param.maxConc: (1e4) maximim micromolar concentration allowed
%  param.maxConc: (1e-4) minimum micromolar concentration allowed
%  param.externalNetFluxBounds:   ('original') =  
%                                 'dxReplacement' = when model.dcl or model.dcu is provided then they set the upper and lower bounds on metabolite exchange
%  param.printLevel:
%
% OUTPUTS:
% f:       m x 1    strictly positive weight on concentration entropy maximisation (default 1)
% u0:      m x 1    standard transformed Gibbs energy of formation, divided by RT (default 0)  
% c0l:     m x 1    non-negative lower bound on initial molecular concentrations 
% c0u:     m x 1    non-negative upper bound on initial molecular concentrations
% cl:      m x 1    non-negative lower bound on final molecular concentrations 
% cu:      m x 1    non-negative lower bound on final molecular concentrations
% dcl:     m x 1    real valued lower bound on difference between final and initial molecular concentrations  
% dcu:     m x 1    real valued upper bound on difference between final and initial initial molecular concentrations  
%  wl:     k x 1    lower bound on external net flux 
%  wu:     k x 1    upper bound on external net flux
%   B:    `m x k`   External stoichiometric matrix
%   b:     m x 1    RHS of S*v = b
%
% EXAMPLE:
%
% NOTE:
%
% Author(s): Ronan Fleming

N=model.S(:,model.SConsistentRxnBool);  % internal stoichiometric matrix
B=model.S(:,~model.SConsistentRxnBool); % external stoichiometric matrix
[m,n]=size(N);
k=nnz(~model.SConsistentRxnBool);

%
if isfield(model,'b')
    b=model.b;
else
    b = zeros(m,1);
end

%% processing for concentrations
if ~isfield(param,'maxConc')
    param.maxConc=inf;
end
if ~isfield(param,'minConc')
    param.minConc=0;
end
% %assume units are in mMol
% if ~isfield(param,'concUnit')
%     param.concUnit = 10-3;
% end

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
    warning([ int2str(nnz(bool)) ' stoichiometrically inconsistent reactions involving more than one metabolite, check bounds on x - x0'])
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
            wl = model.lb(~model.SConsistentRxnBool);
            wu = model.ub(~model.SConsistentRxnBool);
            %force initial and final concentration to be equal
            dcl = zeros(m,1);
            dcu = zeros(m,1);
        case 'identities'
            singletonBool = ((model.S~=0)'*ones(m,1))==1;
            if any(singletonBool(~model.SConsistentRxnBool))
                fprintf('\n%s','Ingnoring the following external reactions: ')
                printRxnFormula(model,model.rxns(singletonBool & ~model.SConsistentRxnBool))
            end
            wl = -inf*ones(2*m,1);
            wu =  inf*ones(2*m,1);
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
            wl =  zeros(k,1);
            wu =  zeros(k,1);
            dcl = zeros(m,1);
            dcu = zeros(m,1);
        case 'none'
            if param.printLevel>0
                fprintf('%s\n','Using no external net flux bounds.')
            end
            wl = -ones(k,1)*inf;
            wu =  ones(k,1)*inf;
            %force initial and final concentration to be equal
            dcl = zeros(m,1);
            dcu = zeros(m,1);
            rl = zeros(m,1);
            ru = zeros(m,1);
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
            wl = model.lb(~model.SConsistentRxnBool)*0;
            wu = model.ub(~model.SConsistentRxnBool)*0;
            rl = zeros(m,1);
            ru = zeros(m,1);
        otherwise
            error(['param.externalNetFluxBounds = ' param.externalNetFluxBounds ' is an unrecognised input'])
    end
else
    wl = [];
    wu =  [];
    dcl = -inf*ones(m,1);
    dcu =  inf*ones(m,1);

end


if isfield(param,'strictMassBalance')
    param.qpMassBalance=~param.strictMassBalance;
end

if param.qpMassBalance
    rl = -inf*ones(m,1);
    ru =  inf*ones(m,1);
else
    rl = zeros(m,1);
    ru = zeros(m,1);
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
if isfield(model,'cl')
    cl = model.cl;
else
    cl = param.minConc*ones(m,1);
end
if isfield(model,'cu')
    cu = model.cu;
else
    cu = param.maxConc*ones(m,1);
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
        %8.31446261815324 J K^-1 mol^-1
        gasConstant = 8.3144621e-3; % Gas constant in kJ K^-1 mol^-1
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
