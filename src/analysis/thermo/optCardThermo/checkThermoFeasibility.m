function [thermoConsistentFluxBool,solutionConsistency] = checkThermoFeasibility(model,solution,thermoConsistencyMethod,param)
% Check which internal reactions of a flux vector solution.v are thermodynamically feasible 
%
% INPUT:
%    model:             (the following fields are required - others can be supplied)
%
%     * .S  - `m x n` Stoichiometric matrix
%     * .SConsistentRxnBool - 'n x 1' Boolean vector of stoichiometrically consistent reactions
%
%    solution.v:      n x nlt  flux vectors
%
% OPTIONAL INPUT
% thermoConsistencyMethod: {('cycleFreeFlux'),'signProduct','cardOpt'}
%
% param.printLevel:
% param.eta:                Minimum flux value that is considered nonzero. Default is feasTol. 
%                           Very sensitive to change in this parameter. Don't change it unless you can debug it.
% param.theta:              Parameter to Capped-L1 (Approximate step function). Default 0.5
% param.warmStartMethod:    Method to warm start optimizeCardinality. Default is 'random'
%                           {('random'),'original','zero','l1','l2'};
% param.thermoConsistency:  {('biochemically'), 'chemically'};
%                           'biochemically' allows N'y ~=0 when v = 0, assumes a missing enzyme to catalyse the reaction.
%                           'chemically' enforces the constraint v = 0 => N'y = 0
%
% OUTPUT
% thermoConsistentFluxBool:  'n x 1' Boolean vector true for thermodynamically consistent fluxes and true for all non-zero external reactions
% solutionConsistency:       solution structure returned by thermodynamic consistency check
%           *.vThermo:       'n x 1' repaired thermodynamically consistent flux                       

% .. Author: - Ronan Fleming 2022
% .. Please cite:
% Fleming RMT, Haraldsdottir HS, Le HM, Vuong PT, Hankemeier T, Thiele I. 
% Cardinality optimisation in constraint-based modelling: Application to human metabolism, 2022 (submitted).

if solution.stat~=1
    return
end

%set parameters according to feastol
feasTol = getCobraSolverParams('LP', 'feasTol');

if ~exist('thermoConsistencyMethod','var')
    thermoConsistencyMethod='cycleFreeFlux';
end

if ~exist('param','var')
    param=struct();
end

if ~isfield(param,'eta')
    feasTol = getCobraSolverParams('LP', 'feasTol');
    param.eta = feasTol; %Very sensitive to change in this parameter. Don't change it unless you can debug it.
end

if ~isfield(param,'thermoConsistency')
    param.thermoConsistency='biochemically';
end

if ~isfield(param,'relaxBounds')
    param.relaxBounds=0;
end

if isfield(param,'debug')
    if param.debug && 0
        fprintf('%s\n','Parameters of checkThermoFeasibility:')
        disp(param)
    end
else
    param.debug=0;
end


solutionConsistency=solution;
switch thermoConsistencyMethod
    case 'cycleFreeFlux'
        
        param.parallelize=0;
        if param.debug && 0
            save('debug_prior_to_cycleFreeFlux.mat')
        end
        [solutionConsistency.vThermo,thermoConsistentFluxBool] = cycleFreeFlux(solution.v, model.c, model, model.SConsistentRxnBool,param);
        solutionConsistency.dvThermo = solution.v - solutionConsistency.vThermo;
        
    case 'signProduct'
        if isfield(solution,'g') && isfield(solution,'v')
            signProduct = (diag(sign(solution.g))*sign(solution.v));
            switch param.thermoConsistency
                case 'chemically'
                    thermoConsistentFluxBool = signProduct==1 | (sign(solution.v)==0 & sign(solution.g)==0);
                case 'biochemically'
                    thermoConsistentFluxBool = signProduct==1 | sign(solution.v)==0;
            end
        else
            %dummy argument
            thermoConsistentFluxBool=false(size(model.S,2),1);
        end
        
    case 'cardOpt'
        [thermoConsistentFluxBool,g,y,r,p,q] = checkThermoFeasibilityCard(model,solution,param);
        solutionConsistency.g=g;
        solutionConsistency.y=y;
        solutionConsistency.r=r;
        solutionConsistency.p=p;
        solutionConsistency.q=q;
        
    case 'v2QNty'
        [q, g, ~] = thermoFlux2QNty(model,solution,param);
        solutionConsistency.q = q;
        solutionConsistency.g = g;
        thermoConsistentFluxBool = isfinite(solutionConsistency.q);
end

%all external reactions are NOT considered to be thermodynamically consistent
thermoConsistentFluxBool(~model.SConsistentRxnBool)=0;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [thermoConsistentFluxBool,g,y,r,p,q] = checkThermoFeasibilityCard(model,solution,param)
% The internal reactions of a flux vector v are thermodynamically consistent if there
% exists a y such that diag(N'*y)*v <= 0. The maximum number of
% thermodynamically consistent fluxes in a vector is estimated by approximately
% solving the following cardinality optimisation problem:
%
% :math:`min   diag(d>0)*||p||_0   + diag(d<0)*||q||_0
% s.t. :math:  `N'y - diag(d~=0)*(p - q) = 0`
% :math:              `-inf <= y <= inf`
% :math:       `diag(d<0)*1 <= p <= 1e4`
% :math:       `diag(d>0)*1 <= q <= 1e4`
%
% where N is an m x n stoichiometrically consistent matrix, and d = sign(v(internal)).
% When d> 0, then the zero norm of p is minimised, with p required to be greater than one.
% When d< 0, then the zero norm of  q is minimised, with p required to be greater than one.
% When d==0, i.e. fluxes of small magnitude (less than param.tolZero) which are considered zero,
% the corresponding change in chemical potential is constrained to be zero, i.e. N'*y = 0.
%
% INPUT:
%    model:             (the following fields are required - others can be supplied)
%
%                     * S  - `m x n` Stoichiometric matrix
%                     * .SConsistentRxnBool - Boolean vector of stoichiometrically consistent reactions
%
%    solution.v:      n x nlt  flux vectors
%
% OPTIONAL INPUT
% param.printLevel:
% param.epsilon:            Minimum flux value that is considered nonzero. Default is feasTol.
% param.theta:              Parameter to Capped-L1 (Approximate step function). Default 0.5
% param.warmStartMethod:    Method to warm start optimizeCardinality. Default is 'random'
%                           {('random'),'original','zero','l1','l2'};
% param.thermoConsistency   {('chemically'), 'biochemically'};
%                           'chemically' enforces the constraint v = 0 => N'y = 0
%                           'biochemically' allows N'y ~=0 when v = 0, assumes a missing enzyme to catalyse the reaction.
%
%
% OUTPUTS
% thermoConsistentFluxBool:   n x nlt logical array indicating thermodynamically consistent fluxes
% g:                          n x nlt vector in the range of N', and NaN otherwise
% r:                          n x nlt vector of relaxations to thermodynamic feasibility, , and NaN otherwise
% y:                          m x nlt vector of chemical potentials
% p:                          n x nlt vector of positive component to approximate change in chemical potential, and NaN otherwise
% q:                          n x nlt vector of negative component to approximate change in chemical potential, and NaN otherwise

% Ronan M.T. Fleming, 2020 

if isfield(solution,'thermoConsistentFluxBool')
    thermoConsistentFluxBool=solution.thermoConsistentFluxBool;
    nlt=size(solution.v,2);
    %skip check if solution.thermoConsistentFluxBool already exists
    [nMet,nRxn]=size(model.S);
    g=NaN*ones(nRxn,nlt);
    y=NaN*ones(nMet,nlt);
    r=NaN*ones(nRxn,nlt);
    p=NaN*ones(nRxn,nlt);
    q=NaN*ones(nRxn,nlt);
    return
end
if ~exist('param','var')
    param=struct();
end

if isfield(param,'epsilon')
    epsilon=param.epsilon;
else
    epsilon = getCobraSolverParams('LP', 'feasTol');
end

if ~isfield(param,'theta')
    param.theta=2;
end

if ~isfield(param,'warmStartMethod')
    param.warmStartMethod='random';
    %param.warmStartMethod='original';
    %param.warmStartMethod='0';
    %param.warmStartMethod='l1';
    %param.warmStartMethod='l2';
end


if ~isfield(param,'condenseW')
    if 0
        param.condenseW = 1;
    else
        param.condenseW = 0;
    end
end
if ~isfield(param,'condenseT')
    if 0
        param.condenseT = 1;
    else
        param.condenseT = 0;
    end
end
        
if ~isfield(param,'theta')
    param.theta=0.5;
end

if ~isfield(param,'printLevel')
    param.printLevel=0;
end

if ~isfield(param,'warmStartMethod')
    param.warmStartMethod='random';
end


if ~isfield(param,'thermoConsistency')
    param.thermoConsistency='chemically';
end

bigNum=1e4;


SConsistentRxnBool=model.SConsistentRxnBool;
N = model.S(:,SConsistentRxnBool);

[nMet,nRxn]=size(model.S);
[m,n] = size(N);

% function solution = optimizeCardinality(problem, param)
% DC programming for solving the cardinality optimization problem
% The `l0` norm is approximated by capped-`l1` function.
% :math:`min c'(x, y, z) + lambda_0*||k.*x||_0 - delta_0*||d.*y||_0
%                        + lambda_1*||x||_1    + delta_1*||y||_1`
% s.t. :math:`A*(x, y, z) <= b`
% :math:`l <= (x,y,z) <= u`
% :math:`x in R^p, y in R^q, z in R^r`
%
% USAGE:
%
%    solution = optimizeCardinality(problem, param)
%
% INPUT:
%    problem:     Structure containing the following fields describing the problem:
%
%                   * .p - size of vector `x`
%                   * .q - size of vector `y`
%                   * .r - size of vector `z`
%                   * .A - `s x (p+q+r)` LHS matrix
%                   * .b - `s x 1` RHS vector
%                   * .csense - `s x 1` Constraint senses, a string containing the constraint sense for
%                     each row in `A` ('E', equality, 'G' greater than, 'L' less than).
%                   * .lb - `(p+q+r) x 1` Lower bound vector
%                   * .ub - `(p+q+r) x 1` Upper bound vector
%                   * .c - `(p+q+r) x 1` linear objective function vector


b = zeros(n,1);
csense = repmat('E',n,1);

c = zeros(m+2*n,1);
osense = 1;

v=solution.v;

%pad out the vectors so they are the same length as the number of reactions
nlt=size(v,2);
y=NaN*ones(nMet,nlt);
thermoConsistentFluxBool=false(nRxn,nlt);
g=NaN*ones(nRxn,nlt);
r=NaN*ones(nRxn,nlt);
p=NaN*ones(nRxn,nlt);
q=NaN*ones(nRxn,nlt);

for j=1:nlt
    %internal reaction rates
    z=v(model.SConsistentRxnBool,j);
    z(abs(z)<epsilon)=0;
    d = sign(z);
    
    ub = bigNum*ones(2*n+m,1);
    
    %depending on d, the zero norm of either p or q is minimised
    % N'y - p + q = 0
    switch param.thermoConsistency
        case 'biochemically'
            % v = 0 NOT IMPLIES N'y = 0
            A = [ N' -speye(n) speye(n)];
        case 'chemically'
            % v = 0 IMPLIES N'y = 0
            A = [ N' -diag(d~=0)*speye(n) diag(d~=0)*speye(n)];
    end
    
    lbp = zeros(n,1);
    lbq = zeros(n,1);
    
    pCardOpt=false(2*n+m,1);
    qCardOpt=false(2*n+m,1);
    rCardOpt=true(2*n+m,1);
    
    % v > 0 => d=1 => min ||p||_0 s.t.  N'y - p + q = 0, q >= 1;
    lbq(d==1)=1;
    %minimise ||p||_0
    pCardOpt(m+find(d==1))=1;
    rCardOpt(m+find(d==1))=0;
    
    % v < 0 => d=-1 => min ||q||_0 s.t. N'y - p + q = 0, p >= 1;
    lbp(d==-1)=1;
    %minimise ||q||_0
    pCardOpt(m+n+find(d==-1))=1;
    rCardOpt(m+n+find(d==-1))=0;
    
    lb = [-bigNum*ones(m,1); lbp; lbq];
    
    if 0 %debug
        disp([pCardOpt(m+1:m+2*n),rCardOpt(m+1:m+2*n),[z;z],[d;d],[lbp;lbq]]);
    end
    
    %note that p,q,r in this cardinality optimisation structure do not relate to
    %p, q in N'y -diag(d)*p + diag(d)*q = 0
    problem = struct('p',pCardOpt,'q',qCardOpt,'r',rCardOpt,'c',c,'osense',osense,'A',A,'b',b,'csense',csense,'lb',lb,'ub',ub);
    
    problem.lambda0=10;
    %problem.lambda0=0;
    %problem.lambda1=1e-8;
    %problem.lambda1=0;
    problem.lambda1=0.1;
    
    solution = optimizeCardinality(problem, param);
    
    % OUTPUT:
    %    solution:    Structure containing the following fields:
    %
    %                   * .x - `p x 1` solution vector
    %                   * .y - `q x 1` solution vector
    %                   * .z - `r x 1` solution vector
    %                   * .stat - status
    %
    %                     * 1 =  Solution found
    %                     * 2 =  Unbounded
    %                     * 0 =  Infeasible
    %                     * -1=  Invalid input
    
    %chemical potential that maximises the number of
    %thermodynamically consistent reactions
    y0=solution.xyz(1:m,1);
    
    p0=solution.xyz(m+1:m+n,1);
    q0=solution.xyz(m+n+1:m+2*n,1);
    
    %eliminate very small numbers
    p0(p0<epsilon)=0;
    q0(q0<epsilon)=0;
    
    %identify thermodynamically consistent reactions
    thermoConsistentBool0=false(n,1);
    
    % v > 0 => d=1 => min ||p||_0 s.t.  N'y - p + q = 0, q >= 1; => p - q < 0
    consistentFwdBool = d==1 & (p0-q0)<-epsilon;
    thermoConsistentBool0(consistentFwdBool)=1;
    
    % v < 0 => d=-1 => min ||q||_0 s.t. N'y - p + q = 0, p >= 1; => p - q > 0
    consistentRevBool = d==-1 & (p0-q0)>epsilon;
    thermoConsistentBool0(consistentRevBool)=1;
    
    % abs(v) <= epsilon <=> d==0
    switch param.thermoConsistency
        case 'biochemically'
            % v = 0 DOES NOT IMPLY N'y = 0
            thermoConsistentBool0(d==0)=1;
        case 'chemically'
            % v = 0 IMPLIES N'y = 0
            consistentZeroBool = d==0 & abs(p0-q0)< epsilon;
            thermoConsistentBool0(consistentZeroBool)=1;
    end
    
    r0=zeros(n,1);
    inConsistentFwdBool = d==1 & (p0-q0)>=-epsilon;
    r0(inConsistentFwdBool)=p0(inConsistentFwdBool)-q0(inConsistentFwdBool);
    inConsistentRevBool = d==-1 & (p0-q0)<=epsilon;
    r0(inConsistentRevBool)=p0(inConsistentRevBool)-q0(inConsistentRevBool);
    
    %pseudo change in Gibbs energy
    g0=N'*y0;
    
    if 0 %debug
        disp([thermoConsistentBool0,z,d,g0,(p0-q0),r0])
    end
    
    %add only the internal reactions
    y(:,j)=y0;
    r(SConsistentRxnBool,j)=r0;
    p(SConsistentRxnBool,j)=p0;
    q(SConsistentRxnBool,j)=q0;
    g(SConsistentRxnBool,j)=g0;
    thermoConsistentFluxBool(SConsistentRxnBool,j)=thermoConsistentBool0;
end
end





