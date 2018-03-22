function MDFBAProblem = buildMDFBAProblem(model, varargin)
% Creates a MDFBA problem from the provided model.
%
% USAGE:
%
%    MDFBAProblem = buildMDFBAProblem(model, varargin)
%
% INPUT:
%    model:           A COBRA style model with the following fields:
%
%                       * S       - Stoichiometric Matrix
%                       * lb      - lower bounds
%                       * ub      - upper bounds
%                       * b       - metabolic constraints
%                       * c       - objective coefficients
%                       * csense  - Constraint senses (optional, default Equality)
%                       * osense  - Optimisation sense (optional, default maximisation)
%
% OPTIONAL INPUTS:
%    varargin:        Variable arguments as parameter/value pairs:
%
%                       * 'ignoredMets' - Metabolites that do not need to be
%                         produced, even if used.
%                       * 'minProd' - the minimal production, if a
%                         metabolite is used, default(max(ub,abs(lb))/10000)
%
% OUTPUT:
%    MDFBAProblem:    The MILPproblem structure representing the MDFBA
%                     problem
%
% NOTE:
%
%    Implementation based on description in:
%    `Benyamini et al. "Flux balance analysis accounting for metabolite
%    dilution." Genome Biol. 2010;11(4):R43. doi: 10.1186/gb-2010-11-4-r43`
%
% .. Author:   - Thomas Pfau (June 2017)

parser = inputParser();
parser.addRequired('model',@isstruct)
parser.addParamValue('ignoredMets',{},@(x) iscell(x) && all(ismember(x,model.mets)));
parser.addParamValue('minProd',max([abs(model.lb);model.ub])/10000,@isnumeric);

parser.parse(model,varargin{:});
ignoredMets = parser.Results.ignoredMets;
minprod = parser.Results.minProd;

[nMets,nRxns] = size(model.S);

MILPproblem = struct();
%We need the following constraints:
%S * v - d = 0;
%if met i is used, then  d = minprod
%Vars will be:
% Rxns,k,d,i_act,y
% d,i_act and y will only be generated for non ignored metabolites.
%Constraints will be:
%S * v - d =? b (depending on csense)
%k - v >= 0
%k + v >= 0
%(abs(S))*k - i_act = 0;    %-> indicates whether a metabolite is used
%-M1 <= -M1y - i_act     %-> if i_act > 0 then y = 0;
%minprod = minprod * y + d  %-> if y = 0 then d = minprod;

relmets = ~ismember(model.mets,ignoredMets);
metspeye = speye(nMets,nMets);
metspeyeA = metspeye(:,relmets);
metspeyeB = metspeye(relmets,relmets);
nRelMets = sum(relmets);
%Take a number 1e5 larger than the largest bound.
M1 = 10000*max([model.ub; abs(model.lb)]);

%We assume, that at least the following fields exist in the model.
b = [model.b;zeros(2*nRxns,1);zeros(nRelMets,1);-M1*ones(nRelMets,1);minprod*ones(nRelMets,1)];
lb = [model.lb; zeros(nRxns,1);zeros(3*nRelMets,1)];
ub = [model.ub; inf(nRxns,1); minprod*ones(nRelMets,1); inf(nRelMets,1); ones(nRelMets,1)];
c = [model.c;zeros(nRxns,1);zeros(3*nRelMets,1)];

%Osense and csense might be missing, if osense is missing, we assume
%maximisation.
[~,osense] = getObjectiveSense(model);

if isfield(model,'csense')
    csense = [model.csense;repmat('G',2*nRxns,1);repmat('E',nRelMets,1);repmat('G',nRelMets,1);repmat('E',nRelMets,1)];
else
    csense = [repmat('E',size(model.mets));repmat('G',2*nRxns,1);repmat('E',nRelMets,1);repmat('G',nRelMets,1);repmat('E',nRelMets,1)];
end
%All a continous except for the indicators (y).
vartype = [repmat('C',2*nRxns,1);repmat('C',2*nRelMets,1),;repmat('B',nRelMets,1)];

A = [model.S, sparse(nMets,nRxns), -metspeyeA, sparse(nMets,2*nRelMets);...
     speye(nRxns,nRxns),speye(nRxns,nRxns),sparse(nRxns,3*nRelMets);...
     -speye(nRxns,nRxns),speye(nRxns,nRxns),sparse(nRxns,3*nRelMets);...
     sparse(nRelMets,nRxns),abs(model.S(relmets,:)),sparse(nRelMets,nRelMets),-metspeyeB, sparse(nRelMets,nRelMets);...
     sparse(nRelMets,nRxns),sparse(nRelMets,nRxns),sparse(nRelMets,nRelMets),-metspeyeB, -M1*metspeyeB;...
     sparse(nRelMets,nRxns),sparse(nRelMets,nRxns),metspeyeB,sparse(nRelMets, nRelMets), minprod*metspeyeB];

%And create the COBRA MILP struct
MDFBAProblem = struct('A', A, 'b', b, 'c', c, 'osense', osense,...
                    'lb',lb,'ub',ub,'csense',csense,'vartype',vartype,'x0',zeros(size(A,2),1));
