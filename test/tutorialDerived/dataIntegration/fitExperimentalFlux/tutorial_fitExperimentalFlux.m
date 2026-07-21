%% Quadratically penalise devation from a given (subset of) experimental fluxes
%% *Author(s): Ronan M.T. Fleming, School of Medicine, University of Galway*
%% *Reviewer(s):* 
% A given vector of experimentally measured fluxes $v_{\exp }$, may not be consistent 
% with the feasible set of steady state fluxes. Specifically, inconsistent with 
% the set defined by the steady state constraint (Sv=0) as well as the lower and 
% upper bounds on each reactionl, l ≤ v ≤ u. Should this occur, we fit the model 
% to the experimental data, relaxing the constraints on the bounds, that admits 
% a steady state flux v , using the following quadriatic optimisation problem
% 
% $$\begin{array}{ll}\underset{v,p,q}{\textrm{min}} & (v_{exp}-v)^{T}\textrm{diag}(w_{exp})(v_{exp}-v)+p^{T}\textrm{diag}(w_{l})p+q^{T}\textrm{diag}(w_{u})q\\\;\text{s.t.} 
% & Sv=0,\\ & l-p\leq v\leq u+q,\\ & 0\le p\\ & 0\le q\end{array}$$
% 
% where    p ≥ 0 and    q  ≥ 0  are non-negative variables that permit relaxation 
% of the lower and upper bound constraints, respectively. This formulation also 
% allows for different weights to be input as parameters to penalise deviation 
% from experimentally measured mean fluxes, with $w_{\exp }$ = weightExp, penalise 
% relaxation of lower bounds, with           $w_l$ = weightLower,  and penalise 
% relaxation of upper bounds, with $w_u$ = weightUpper. For example, if the experimentally 
% measured flux is actually the mean flux, then one could set $w_{\exp }$ to be 
% the inverse of the variance on the experimental flux measurements, thereby increasing 
% the penalty on deviation from an experimentally measured mean flux where the 
% variance is lower. Certain lower or upper bounds might not be realistic to be 
% relaxed, e.g., an essential amino acid can always be taken up but never secreted, 
% therefore the upper bound on the corresponding exchange reaction must be zero. 
% The code below also works if there are additional coupling constraints, $\textrm{Cv}\le 
% \;d$, but these are not relaxed. This approach was developed and applied within 
% [1].
% 
% Set the solver

LPsolverOK = changeCobraSolver('gurobi','QP');
%LPsolverOK = changeCobraSolver('mosek','QP');
%% 
% Load an example model

filename='~/work/sbgCloud/data/models/unpublished/reconMitochondria/modelRecon3MitoOpen.mat';
%model.c(strcmp(model.rxns,'EX_o2[c]'))=1;
%model.c(strcmp(model.rxns,'EX_h2o2[c]'))=1;
%filename='~/work/sbgCloud/programReconstruction/projects/exoMetDN/results/iPSCderivedModels/2018models/model_iHNESC2DN_unfeasible.mat';
try
    model=readCbModel(filename);
catch
    load(filename)
    modelRecon3Mito = model
end
[nMet,nRxn]=size(model.S);
%% 
% Identify the internal and external reactions

if ~isfield(model,'SIntRxnBool')  || ~isfield(model,'SIntMetBool')
    %finds the reactions in the model which export/import from the model
    %boundary i.e. mass unbalanced reactions
    %e.g. Exchange reactions
    %     Demand reactions
    %     Sink reactions
    model = findSExRxnInd(model,[],-1);
end
% model.SIntRxnBool         Boolean of reactions heuristically though to be mass balanced.
% model.SIntMetBool         Boolean of metabolites heuristically though to be involved in mass balanced reactions.
nIntRxn=nnz(model.SIntRxnBool);
%% 
% Generate a random experimental flux for the external reactions in a model. 
% NaN means no experimental information is available for a reaction rate. Note 
% that some of the experimental fluxes must be outside the bounds on the model, 
% otherwise no relaxation of the bounds will be necessary. 

vExp=(rand(nRxn,1)-1)*1000*4;
vExp(model.SIntRxnBool,1)=NaN;

% vExp(model.SIntRxnBool,1)=0;
%% 
% Set the weight on the Euclidean norm of the relaxation to the lower bounds 
% on the predicted steady state flux vector. Only for allow relaxation for external 
% reactions. The weight penalty on relaxation of the lower bound should be greater 
% than that on the experimental flux, and upper bound, if the model lower bound 
% is considered more reliable than the experimental data and the upper bound.

weightLower=ones(nRxn,1);
weightLower(model.SIntRxnBool)=inf;
%% 
% Set the weight on the Euclidean norm of the relaxation to the upper bounds 
% on the predicted steady state flux vector. Only for allow relaxation for external 
% reactions. The weight penalty on relaxation of the upper bound should be greater 
% than that on the experimental flux, and lower bound, if the model upper bound 
% is considered more reliable than the experimental data and the lower bound.

weightUpper=ones(nRxn,1);
weightUpper(model.SIntRxnBool)=inf;
%% 
% Set the weight weighton the Euclidean distance of the predicted steady state 
% flux from the experimental steady state flux. Uniform at first. The weight penalty 
% on relaxation from the experimental flux vector should be greater than that 
% on the lower and upper bounds, if the experimental data is considered more reliable 
% than the lower and upper bounds of the model. Weights are ignored on the reactions 
% without experimental data, i.e. vExp(n)==NaN.

weightExp =ones(nRxn,1);
% weightExp(model.SIntRxnBool) =0;
%% 
% Select the amount of information to be returned by the solver

printLevel=0;
%printLevel=1;
%% 
% Compute the steady state flux vector that minimises the weighted Euclidean 
% norm between experimental and predicted steady state flux vector, plus the weighted 
% Euclidean norm relaxation of the model lower bounds, plus the  weighted Euclidean 
% norm relaxation of the model upper bounds. Also save the relaxed model that 
% admits such a steady state flux.

%   changeCobraSolver('gurobi','all');
%   changeCobraSolver('ibm_cplex','all');
%    changeCobraSolver('glpk','all');
%    changeCobraSolver('pdco','all');
%    changeCobraSolver('qpng','all')
%   
[modelRelaxed,v,p,q,dv] = fitExperimentalFlux(model, vExp, weightLower, weightUpper, weightExp, printLevel);
%% 
% Estimate the smallest nonzero significant flux

feasTol = getCobraSolverParams('LP', 'feasTol');
tol=feasTol*1e5;
disp(tol)
%% 
% Identify the reactions where the bounds are relaxed

boolRelaxedLowerBound=p>tol;
boolRelaxedUpperBound=q>tol;
%% 
% Display the predicted fluxes in relation to the original model bounds and 
% the relaxation of the lower model bounds

k=1;
for n=1:nRxn
    if k==100 %only show 100 reactions maximum
        break;
    end
    if n==1
        fprintf('%-20s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s\n','rxns{n}','lb_new','wl','-p','lb','v','vexp','wexp','ub','q','wu','ub_new');
    end
    if boolRelaxedLowerBound(n)
        k=k+1;
        fprintf('%-20s%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g\n',...
            model.rxns{n},modelRelaxed.lb(n),weightLower(n),-p(n),model.lb(n),v(n),vExp(n),weightExp(n),model.ub(n),q(n),weightUpper(n),modelRelaxed.ub(n));
    end
end
%% 
% Display the predicted fluxes in relation to the original model bounds and 
% the relaxation of the upper model bounds

k=1;
for n=1:nRxn
    if k==100 %only show 100 reactions maximum
        break;
    end
    if n==1
        fprintf('%-20s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s\n','rxns{n}','lb_new','wl','-p','lb','v','vexp','wexp','ub','q','wu','ub_new');
    end
    if boolRelaxedUpperBound(n)
        k=k+1;
        fprintf('%-20s%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g\n',...
            model.rxns{n},modelRelaxed.lb(n),weightLower(n),-p(n),model.lb(n),v(n),vExp(n),weightExp(n),model.ub(n),q(n),weightUpper(n),modelRelaxed.ub(n));
    end
end
%% _Acknowledgments_
% _Please note an acknowledgments section can be included._
%% REFERENCES
%% _Acknowledgments_
% Co-funded by the European Union's Horizon Europe Framework Programme (101080997)
%% REFERENCES
% [1] Preciat, German and Moreno, Edinson Lucumi, "Mechanistic model-driven 
% exometabolomic characterisation of human dopaminergic neuronal metabolism", 
% _bioRxiv_ (2022). <https://www.biorxiv.org/content/10.1101/2021.11.08.467803v2 
% https://www.biorxiv.org/content/10.1101/2021.11.08.467803v2> 
% 
%