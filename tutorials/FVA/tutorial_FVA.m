%% *Flux Variability analysis (FVA)*
% Flux variability analysis (FVA) is a widely used computational tool for evaluating 
% the minimum and maximum range of each reaction flux that can still satisfy the 
% constraints using two optimisation problems for each reaction of interest$$^1$. 
% 
% 
% 
% $$\begin{array}{lll}\max\limits _{v}/\min\limits _{v} & v_{j} \\\text{s.t.} 
% & Sv=0,\\ & l\leq v\leq u,\\& c_{T}v = c_{T}v^*\end{array}$$
% 
% where $v \in R^{n}$ represents the rate of each biochemical reaction, but 
% typically an infinite set of steady state flux vectors exist can satisfy the 
% same requirement for an optimal objective $$ c_{T}v^* = c_{T}v$. As well as 
% for the flux balance analysis (FBA), there are also many possible variations 
% on flux variability analysis (FVA)$$^2$.
% 
% Depending on the size of the model you are using for the analysis, use:
% 
% * |fluxVariability()| function - for the low dimensional FVA;
% * |fastFVA()| function - for the models with more than 1,000 reactions;
% * <https://github.com/opencobra/COBRA.jl distributedFBA.jl> - for high dimensional 
% FVA,* *models larger than 10,000 reactions$$^2$;
%% EQUIPMENT SETUP
% If necessary, initialize the cobra toolbox with

% initCobraToolbox
warning('off', 'MATLAB:subscripting:noSubscriptsSpecified');
%% 
% For solving linear programming problems in FBA and FVA analysis, certain 
% solvers are required:

% solverOK = changeCobraSolver(solverName, solverType)
%% 
% The present tutorial can run with <https://opencobra.github.io/cobratoolbox/deprecated/docs/cobra/solvers/changeCobraSolver.html 
% glpk package>, which does not require additional installation and configuration. 
% Although, for the analysis of large models is recommended to use the <https://github.com/opencobra/cobratoolbox/blob/master/docs/source/installation/solvers.md 
% GUROBI> package.

changeCobraSolver ('gurobi', 'all');
%% PROCEDURE
% In this tutorial, the provided model is a generic model of the human cellular 
% metabolism, Recon 3D$$^3$ or Recon2.0. Therefore, we assume, that the cellular 
% objectives include energy production or optimisation of uptake rates and by-product 
% secretion for various physiological functions of the human body.
% 
% Before proceeding with the simulations, the path for the model needs to 
% be set up:

% check if Recon3 exists:
% pathModel = '~/work/sbgCloud/data/models/unpublished/Recon3D_models/';
% filename = '2017_04_28_Recon3d.mat';
% load([pathModel, filename])
% model = modelRecon3model;
% clear modelRecon3model
% and if not
% select your own model, or use Recon2.0model instead filename='Recon3.0model';
global CBTDIR
load([CBTDIR filesep 'test' filesep 'models' filesep 'Recon2.0model.mat']);
model = Recon2model;
model.rxns = strrep(model.rxns, '(', '[');
model.rxns = strrep(model.rxns, ')', ']');
clear Recon2model
%% 
% The metabolites structures and reactions are from the Virtual Metabolic 
% Human database (VMH, <http://vmh.life http://vmh.life>).
%% TROUBLESHOOTING
% If there are multiple energy sources available in the model, specify more 
% constraints.
% 
% If we do not do that, we will have additional carbon and oxygen energy 
% sources available in the cell and the maximal ATP production. 
% 
% To avoid this issue, all external carbon sources need to be closed.

% Closing the uptake of all energy and oxygen sources
idx = strmatch('Exchange/demand reaction', model.subSystems);
c = 0;
for i = 1:length(idx)
    if model.lb(idx(i)) ~= 0
        c = c + 1;
        uptakes{c} = model.rxns{idx(i)};
    end
end
% If you use Recon3.0 model, than:
% modelalter = model;
% modelalter = changeRxnBounds(modelalter, uptakes, 0, 'b');
% modelalter = changeRxnBounds(modelalter, 'EX_HC00250[e]', -1000, 'l');

% The alternative way to do that, in case you were using another large model, 
% that does not contain defined Subsystem is
% to find uptake exchange reactions with following codes:
% [selExc, selUpt] = findExcRxns(model);
% uptakes = model.rxns(selUpt);

% Selecting from the exchange uptake reactions those 
% which contain at least 1 carbon in the metabolites included in the reaction:
 subuptakeModel = extractSubNetwork(model, uptakes);
 hiCarbonRxns = findCarbonRxns(subuptakeModel,1);
% Closing the uptake of all the carbon sources
 modelalter = model;
 modelalter = changeRxnBounds(modelalter, hiCarbonRxns, 0, 'b');
% Closing other oxygen and energy sources
 exoxygen = {'EX_adp'
    'EX_amp[e]'
    'EX_atp[e]'
    'EX_co2[e]'
    'EX_coa[e]'
    'EX_fad[e]'
    'EX_fe2[e]'
    'EX_fe3[e]'
    'EX_gdp[e]'
    'EX_gmp[e]'
    'EX_gtp[e]'
    'EX_h[e]'
    'EX_h2o[e]'
    'EX_h2o2[e]'
    'EX_nad[e]'
    'EX_nadp[e]'
    'EX_no[e]'
    'EX_no2[e]'
    'EX_o2s[e]'};
modelalter = changeRxnBounds (modelalter, exoxygen, 0, 'l');
%% 
% In this example, we are analysing the variability of several reactions 
% from the human cellular metabolism in the aerobic and anaerobic state. 
% 
% For each simulation, the original model will be copied to a new variable. 
% This preserves the constraints of the original model and allows to perform simulations 
% with new constraints. Additionally, this method of renaming the model avoids 
% confusion while performing multiple simulations at the same time.

% modelfva1 represents aerobic condition
modelfva1 = modelalter;
% For Recon3.0 model
% modelfva1 = changeRxnBounds (modelfva1, 'EX_glc_D[e]', -20, 'l');
modelfva1 = changeRxnBounds(modelfva1, 'EX_glc[e]', -20, 'l');
modelfva1 = changeRxnBounds(modelfva1, 'EX_o2[e]', -1000, 'l');
% modelfva2 represents anaerobic condition
modelfva2 = modelfva1;
modelfva2 = changeRxnBounds(modelfva2, 'EX_o2[e]',  0, 'l');
%% Standard FVA
% The full spectrum of flux variability analysis options can be accessed using 
% the command:

% [minFlux, maxFlux, Vmin, Vmax] = fluxVariability(model, optPercentage,...
%     osenseStr, rxnNameList, verbFlag, allowLoops, method);
%% 
% The |optPercentage| parameter allows one to choose whether to consider 
% solutions that give at least a certain percentage of the optimal solution. 
% 
% Setting the parameters  |osenseStr = 'min'| or |osenseStr = 'max'| determines 
% whether the flux balance analysis problem is first solved with minimization 
% or maximisation. 
% 
% The |rxnNameList| accepts a cell array list of reactions to selectively 
% perform flux variability upon. This is useful for high-dimensional models where 
% computation of a flux variability for all reactions is more time consuming:

% Selecting several reactions from the model that we want to analyse with FVA
rxnsList = {'DM_atp_c_'
    'ACOAHi'
    'ALCD21_D'
    'LALDO'
    'ME2m'
    'AKGDm'
    'PGI'
    'PGM'
    'r0062'};
%% 
% The |verbFlag| input determines how much output to print. 
% 
% |allowLoops==0| invokes a mixed integer linear programming implementation 
% of thermodynamically constrained flux variability analysis for each minimization 
% or maximisation of a reaction rate. 
% 
% The |method| parameter input determines whether are the output flux vectors 
% also minimise the |0-norm|, |1-norm| or |2-norm| whilst maximising or minimising 
% the flux through one reaction. 
% 
% Running |fluxVariability()| on both models (|modelfva1|, |modelfva2|) will 
% generate the minimum and maximum flux ranges of selected reactions, from rxnsList, 
% in the network.
% 
% Run FVA analysis for the model with the constraints that simulates aerobic 
% conditions:

[minFlux1, maxFlux1, Vmin1, Vmax1] = fluxVariability(modelfva1, [], [], rxnsList)
%% 
% Run FVA analysis for the model with the constraints that simulates anaerobic 
% conditions:

[minFlux2, maxFlux2, Vmin2, Vmax2] = fluxVariability(modelfva2, [], [], rxnsList) 
%% 
% The additional |n × k| output matrices |Vmin| and |Vmax| return the flux 
% vector for each of the |k ? n| fluxes selected for flux variability.
% 
% Further, plot and compare the FVA results from the both models:

ymax1 = maxFlux1;
ymin1 = minFlux1;
ymax2 = maxFlux2;
ymin2 = minFlux2;

maxf = table(ymax1, ymax2)
minf = table(ymin1, ymin2)
maxfxs = table2cell(maxf);
minfxs = table2cell(minf);

figure
plot1 = bar(cell2mat(maxfxs(1:end, :)));
hold on
plot2 = bar(cell2mat(minfxs(1:end, :)));
hold off
xticklabels({'DM_atp_c_', 'ACOAHi', 'ALCD21__D', 'LALDO',...
             'ME2m', 'AKGDm', 'PGI', 'PGM', 'r0062'})
set(gca, 'XTickLabelRotation', -80);
yticks([-1000 -800 -600 -400 -200 0 200 400 600 800 1000])
xlabel('Reactions from the models')
ylabel('Fluxes')
legend({'Aerobic', 'Anaerobic'}, 'Location', 'southwest')
title('Variations in fluxes in the aerobic and anaerobic conditions')
%% Fast FVA
% The code is as follows-

% [minFlux, maxFlux, optsol, ret, fbasol, fvamin, fvamax, statussolmin,...
% statussolmax] = fastFVA(model, optPercentage, objective, solverName,...
% rxnsList, matrixAS, cpxControl, strategy, rxnsOptMode)
%% 
% The |fastFVA()| function returns vectors for the initial FBA in |fbasol| 
% together with matrices |fvamin| and |fvamax| containing the flux values for 
% each individual min/max problem.
%% TROUBLESHOOTING
% Note that for large models the memory requirements may become prohibitive.
% 
% The |fastFVA()| function only supports the <https://opencobra.github.io/cobratoolbox/docs/solvers.html  
% CPLX> solver. For detail information, refer to the solver <https://github.com/opencobra/cobratoolbox/blob/master/docs/source/installation/solvers.md 
% installation guide>.

changeCobraSolver ('ibm_cplex', 'all', 1);
%% 
% Run fast FVA analysis for the whole model with the constraints that simulates 
% aerobic conditions:

[minFluxF1, maxFluxF1, optsol, ret, fbasol, fvamin, fvamax,...
    statussolmin, statussolmax] = fastFVA(modelfva1);
%% 
% Run fast FVA analysis for the whole model with the constraints that simulates 
% anaerobic conditions:

[minFluxF2, maxFluxF2, optsol2, ret2, fbasol2, fvamin2, fvamax2,...
    statussolmin2, statussolmax2] = fastFVA(modelfva2);
%% 
% Plotting the results of the fast FVA and comparing them between the aerobic 
% and anaerobic models:

ymaxf1 = maxFluxF1;
yminf1 = minFluxF1;
ymaxf2 = maxFluxF2;
yminf2 = minFluxF2;

maxf =table(ymaxf1, ymaxf2);
minf =table(yminf1, yminf2);

maxf = table2cell(maxf);
minf = table2cell(minf);

figure
plot3 = bar(cell2mat(maxf(1:end, :)));
hold on
plot4 = bar(cell2mat(minf(1:end, :)));
hold off
xticks([0 2000 4000 6000 8000 10600])
yticks([-1000 -800 -600 -400 -200 0 200 400 600 800 1000])
xlabel('All reactions in the model')
ylabel('Fluxes')
legend({'Aerobic', 'Anaerobic'})
title('Variations in fluxes in the aerobic and anaerobic conditions')
%% REFERENCES 
% [1] Gudmundsson, S., Thiele, I. Computationally efficient flux variability 
% analysis. _BMC Bioinformatics. _11, 489 (2010).
% 
% [2] Heirendt, L., Thiele, I., Fleming, R.M. DistributedFBA.jl: high-level, 
% high-performance flux balance analysis in Julia. _Bioinformatics._ 33 (9), 1421-1423 
% (2017).
% 
% [3] Thiele, I., Price, N.D., Vo, T.D., Palsson B. Ø. Candidate Metabolic 
% Network States in Human Mitochondria. Impact of diabetes, ischemia and diet. 
% _J Bio Chem. _280 (12), 11683?11695 (2005).