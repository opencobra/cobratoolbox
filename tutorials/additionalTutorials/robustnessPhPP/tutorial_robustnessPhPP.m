%% Varying Parameters analysis
% *Author(s): Vanja Vlasov, Systems Biochemistry Group, LCSB, University of 
% Luxembourg.*
% 
% *Reviewer(s): Thomas Pfau, Systems Biology Group, LSRU, University of Luxembourg.*
% 
% *Ines Thiele, Molecular Systems Physiology Group, LCSB, University of Luxembourg*
% 
% *Almut Heinken, Molecular Systems Physiology Group, LCSB, University of 
% Luxembourg*
% 
% **
% 
% In this tutorial, we show how computations are performed by varying one 
% or two parameters over a fixed range of numerical values.
%% EQUIPMENT SETUP
% If necessary, initialise the cobra toolbox:

initCobraToolbox;
%% 
% For solving linear programming problems in the analysis, certain solvers 
% are required:

changeCobraSolver ('gurobi', 'all', 1);
%changeCobraSolver ('glpk', 'all', 1);
%% 
% The present tutorial can run with |'glpk'| package, which does not require 
% additional installation and configuration. Although, for the analysis of large 
% models is recommended to use the |'gurobi'| package. For detail information, 
% refer to the solver installation guide: <https://github.com/opencobra/cobratoolbox/blob/master/docs/source/installation/solvers.md 
% https://github.com/opencobra/cobratoolbox/blob/master/docs/source/installation/solvers.md>
%% PROCEDURE
% Before proceeding with the simulations, the path for the model needs to be 
% set up. In this tutorial, the used model is the generic model of human metabolism, 
% Recon 3 [1]. Therefore, we assume, that the cellular objectives include energy 
% production or optimisation of uptake rates and by-product secretion for various 
% physiological functions of the human body. If Recon 3 is not available, please 
% use Recon 2.

%For Recon3D Change the model
modelFileName = 'Recon2.0model.mat';
modelDirectory = getDistributedModelFolder(modelFileName); %Look up the folder for the distributed Models.
modelFileName= [modelDirectory filesep modelFileName]; % Get the full path. Necessary to be sure, that the right model is loaded
model = readCbModel(modelFileName);

%% 
% If Recon2 is used, the reaction nomenclature needs to be adjusted.

model.rxns(find(ismember(model.rxns,'EX_glc(e)')))={'EX_glc_D[e]'};
model.rxns(find(ismember(model.rxns,'EX_o2(e)')))={'EX_o2[e]'};
%% TROUBLESHOOTING
% If there are multiple energy sources available in the model; Specifying more 
% constraints is necessary. If we do not do that, we will have additional carbon 
% and oxygen energy sources available in the cell and the maximal ATP production. 
% 
% To avoid this issue, all external carbon sources need to be closed.

%Closing the uptake of all energy and oxygen sources
for i=1:length(model.rxns)
    if strncmp(model.rxns{i},'EX_',3)
        model.subSystems{i}='Exchange/demand reaction';
    end
end
idx=strmatch('Exchange/demand reaction', model.subSystems);
c=0;
for i=1:length(idx)
    if model.lb(idx(i))~=0
        c=c+1;
        uptakes{c}=model.rxns{idx(i)};
    end
end

modelalter = model;
modelalter = changeRxnBounds(modelalter, uptakes, 0, 'l');

% The alternative way to do that, in case you were using another large model, 
% that does not contain defined Subsystem is
% to find uptake exchange reactions with following codes:
% [selExc, selUpt] = findExcRxns(model);
% uptakes = model.rxns(selUpt);
% Selecting from the exchange uptake reactions those 
% which contain at least 1 carbon in the metabolites included in the reaction:
% subuptakeModel = extractSubNetwork(model, uptakes);
% hiCarbonRxns = findCarbonRxns(subuptakeModel,1);
% Closing the uptake of all the carbon sources
% modelalter = model;
% modelalter = changeRxnBounds(modelalter, hiCarbonRxns, 0, 'l');
%% Robustness analysis
% Robustness analysis is applied to estimate and visualise how changes in the 
% concentration of an environmental parameter (exchange rate) or internal reaction 
% effect on the objective [2]. If we are interested in varying $$v_{j}$ between 
% two values, i.e., $$v_{j,min}$ and $$v_{j,max}$, we can solve $$l$ optimisation 
% problems:
% 
% $$\begin{array}{ll}\max Z_{k}= c^{T}v \\\text{s.t.} & k =1,...,l,\\& Sv=0,\\\text{fixing} 
% & v_{j}=v_{j,min}+ \frac{(k-1)}{(l-1)}*(v_{j,max}-v_{j,min})\\\text{constraints} 
% & v_{i,min}\leq v_{i} \leq v_{i,max}, i=1,...,n,i \neq j \end{array}$$
% 
% 
% 
% The function |robustnessAnalysis()| is used for this analysis:

% [controlFlux, objFlux] = robustnessAnalysis(model, controlRxn, nPoints,...
%      plotResFlag, objRxn,objType)
%% 
% where inputs are a COBRA model, a reaction that has been analysed and 
% optional inputs:

% INPUTS
% model         COBRA model structure
% controlRxn    Reaction of interest whose value is to be controlled
%
% OPTIONAL INPUTS
% nPoints       Number of points to show on plot (Default = 20)
% plotResFlag   Plot results (Default true)
% objRxn        Objective reaction to be maximized
%               (Default = whatever is defined in model)
% objType       Maximize ('max') or minimize ('min') objective
%               (Default = 'max')
%
% OUTPUTS
% controlFlux   Flux values within the range of the maximum and minimum for
%               a reaction of interest
% objFlux       Optimal values of objective reaction at each control
%               reaction flux value
%% 
% Here, we will investigate how robust the maximal ATP production of the 
% network (i.e., the maximal flux through '|DM_atp_c_'|) is with respect to varying 
% glucose uptake rates and fixed oxygen uptake. 

modelrobust = modelalter;
modelrobust = changeRxnBounds(modelrobust, 'EX_o2[e]', -17, 'b');
AtpRates = zeros(21, 1);
for i = 0:20
    modelrobust = changeRxnBounds(modelrobust, 'EX_glc_D[e]', -i, 'b');
    modelrobust = changeObjective(modelrobust, 'DM_atp_c_');
    FBArobust = optimizeCbModel(modelrobust, 'max');
    AtpRates(i+1) = FBArobust.f;
end
plot (1:21, AtpRates)
xlabel('Flux through EX-glc-D[e]')
ylabel('Objective function')
%% 
% We can also investigate the robustness of the maximal ATP production when 
% the available glucose amount is fixed, while different levels of oxygen are 
% available.

modelrobustoxy = modelalter;
modelrobustoxy = changeRxnBounds(modelrobustoxy, 'EX_glc_D[e]', -20, 'b');
AtpRatesoxy = zeros(21, 1);
for i = 0:20
    modelrobustoxy = changeRxnBounds(modelrobustoxy, 'EX_o2[e]', -i, 'b');
    modelrobustoxy = changeObjective(modelrobustoxy, 'DM_atp_c_');
    FBArobustoxy = optimizeCbModel(modelrobustoxy, 'max');
    AtpRatesoxy(i+1) = FBArobustoxy.f;
end
plot (1:21, AtpRatesoxy)
xlabel('Flux through EX-o2[e]')
ylabel('Objective function')
%% 
% *    *    Double robust analysis*
% 
% Performs robustness analysis for a pair of reactions of interest and an 
% objective of interest. The double robust analysis is implemented with the function 
% |doubleRobustnessAnalysis()|.

% [controlFlux1, controlFlux2, objFlux] = doubleRobustnessAnalysis(model,...
%  controlRxn1, controlRxn2, nPoints, plotResFlag, objRxn, objType)
%% 
% The inputs are a COBRA model, two reactions for the analysis and optional 
% inputs:

%INPUTS
% model         COBRA model to analyse,
% controlRxn1   The first reaction for the analysis,
% controlRxn2   The second reaction for the analysis;
%
%OPTIONAL INPUTS
% nPoints       The number of flux values per dimension (Default = 20)
% plotResFlag   Indicates whether the result should be plotted (Default = true)
% objRxn        is objective to be used in the analysis (Default = whatever
%               is defined in model)
% objType       Direction of the objective (min or max)
%               (Default = 'max')
%% 
% 

modeldrobustoxy = modelalter;
modeldrobustoxy = changeRxnBounds(modeldrobustoxy, 'EX_glc_D[e]', -20, 'l');
modeldrobustoxy = changeRxnBounds(modeldrobustoxy, 'EX_o2[e]', -17, 'l');
[controlFlux1, controlFlux2, objFlux] = doubleRobustnessAnalysis(modeldrobustoxy,...
    'EX_glc_D[e]', 'EX_o2[e]', 10, 1, 'DM_atp_c_', 'max')
%% *Phenotypic phase plane analysis (PhPP)*
% The PhPP is a method for describing in two or three dimensions, how the objective 
% function would change if additional metabolites were given to the model [3]. 
% 
% Essentially PhPP performs a |doubleRobustnessAnalysis()|, with the difference 
% that shadow prices are retained. The code is as follows-

modelphpp = modelalter;
ATPphppRates = zeros(21);
for i = 0:10
    for j = 0:20
        modelphpp = changeRxnBounds(modelphpp, 'EX_glc_D[e]', -i, 'b');
        modelphpp = changeRxnBounds(modelphpp, 'EX_o2[e]', -j, 'b');
        modelphpp = changeObjective(modelphpp, 'DM_atp_c_');
        FBAphpp = optimizeCbModel(modelphpp, 'max');
        ATPphppRates(i+1,j+1) = FBAphpp.f;
    end
end

surfl(ATPphppRates) % 3d plot
xlabel('Flux through EX-glc-D[e]')
ylabel('Flux through EX-o2[e]')
zlabel('Objective function')
%% 
% To generate a 2D plot: |pcolor(ATPphppRates)|
% 
% Alternatively, use the function |phenotypePhasePlane()|. This function 
% also draws the line of optimality, as well as the shadow prices of the metabolites 
% from the two control reactions. In this case, control reactions are '|EX_glc_D[e]|' 
% and '|EX_o2[e]|'. The line of optimality signifies the state wherein, the objective 
% function is optimal. In this case it is '|DM_atp_c_|'.

modelphpp = changeObjective (modelphpp, 'DM_atp_c_');
[growthRates, shadowPrices1, shadowPrices2] = phenotypePhasePlane(modelphpp,...
    'EX_glc_D[e]', 'EX_o2[e]');
%% 
% 
%% REFERENCES 
% [1] Noronha A., et al. (2017). ReconMap: an interactive visualization of human 
% metabolism. _Bioinformatics_., 33 (4): 605-607.
% 
% [2] Edwards, J.S. and and Palsson, B. Ø. (2000). Robustness analysis of 
% the Escherichia coli metabolic network. _Biotechnology Progress, _16(6):927-39.
% 
% [3] Edwards, J.S., Ramakrishna, R. and and Palsson, B. Ø. (2002). Characterizing 
% the metabolic phenotype: A phenotype phase plane analysis. _Biotechnology and 
% Bioengineering_, 77:27-36.