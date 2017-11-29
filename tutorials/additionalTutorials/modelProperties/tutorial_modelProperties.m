%% Create an overview table with model properties
% *Author(s): Ines Thiele, Ronan M. T. Fleming, Systems Biochemistry Group, 
% LCSB, University of Luxembourg.*
% 
% *Reviewer(s): Catherine Fleming, Stefania Magnusdottir, Molecular Systems 
% Physiology Group, LCSB, University of Luxembourg.*
%% INTRODUCTION
% In this tutorial, we evaluate the basic properties of the metabolic model, 
% such as the number of reactions, unique metabolites, blocked reactions, dead-end 
% metabolites, and store the information in a table ('Table_Prop'). 
%% EQUIPMENT SETUP
%% *Initialize the COBRA Toolbox.*
% If necessary, initialize The Cobra Toolbox using the |initCobraToolbox| function.

initCobraToolbox
%% *Setting the *optimization* solver.*
% This tutorial will be run with a |'glpk'| package, which is a linear programming 
% ('|LP'|) solver. The |'glpk'| package does not require additional instalation 
% and configuration.

solverName='glpk';
solverType='LP'; 
changeCobraSolver(solverName,solverType);
%% 
% However, for the analysis of large models, such as Recon 2.04, it is not 
% recommended to use the |'glpk'| package but rather an industrial strength solver, 
% such as the |'gurobi'| package. For detailed information, refer to The Cobra 
% Toolbox <https://github.com/opencobra/cobratoolbox/blob/master/docs/source/installation/solvers.md 
% solver instalation guide>. 
% 
% A solver package may offer different types of optimization programmes to 
% solve a problem. The above example used a LP optimization, other types of optimization 
% programmes include; mixed-integer linear programming ('|MILP|'), quadratic programming 
% ('|QP|'), and mixed-integer quadratic programming ('|MIQP|').

warning off MATLAB:subscripting:noSubscriptsSpecified
%% COBRA model. 
% In this tutorial, the model used is the generic reconstruction of human metabolism, 
% the Recon 2.04 [1], which is provided in the COBRA Toolbox. The Recon 2.04 model* 
% *can also be downloaded from the <https://vmh.uni.lu/#downloadview Virtual Metabolic 
% Human> webpage. Before proceeding with the simulations, the path to the model 
% needs to be set up and the model loaded:

modelFileName = 'Recon2.v04.mat';
modelDirectory = getDistributedModelFolder(modelFileName); %Look up the folder for the distributed Models.
modelFileName= [modelDirectory filesep modelFileName]; % Get the full path. Necessary to be sure, that the right model is loaded
model = readCbModel(modelFileName);
%% PROCEDURE
% We first initialize the table

clear TableProp
r = 1;
TableProp(r, :) = {'Model'}; r = r+1;
%% 
% Determine the number of reactions in the model.

TableProp(r, 1) = {'Reactions'};
TableProp{r, 2} = num2str(length(model.rxns));
r = r + 1;
%% 
% Determine the number of metabolites in the model.

TableProp(r, 1) = {'Metabolites'};
TableProp{r, 2} = num2str(length(model.mets));
r = r + 1;
%% 
%  Determine the number of unique metabolites in the model.

TableProp(r, 1) = {'Metabolites (unique)'};
[g, remR3M] = strtok(model.mets,'[');
TableProp{r, 2} = num2str(length(unique(g)));
r = r + 1;
%% 
%  Determine the number of compartments in model.

TableProp(r, 1) = {'Compartments (unique)'};
TableProp{r, 2} = num2str(length(unique(remR3M)));
r = r + 1;
%% 
% Determine the number of unique genes.

TableProp(r, 1) = {'Genes (unique)'};
[g,rem]=strtok(model.genes,'.');
TableProp{r, 2} = num2str(length(unique(g)));
r = r + 1;
%% 
%  Determine the number of subsystems.

TableProp(r, 1) = {'Subsystems'};
TableProp{r, 2} = num2str(length(unique(model.subSystems)));
r = r + 1;
%% 
%  Determine the number of deadends.

TableProp(r, 1) = {'Deadends'};
D3M = detectDeadEnds(model);
TableProp{r, 2} = num2str(length(D3M));
r = r + 1;
%% 
%  Determine the size of the S matrix.

TableProp(r, 1) = {'Size of S'};
TableProp{r, 2} = strcat(num2str(size(model.S,1)),'; ',num2str(size(model.S,2)));
r = r + 1;
%% 
% Determine the rank of S.

TableProp(r, 1) = {'Rank of S'};
TableProp{r, 2} = strcat(num2str(rank(full(model.S))));
r = r + 1;
%% 
% Determine the percentage of non-zero entries in the S matrix (nnz)

TableProp(r, 1) = {'Percentage nz'};
TableProp{r, 2} = strcat(num2str((nnz(model.S)/(size(model.S,1)*size(model.S,2)))));
r = r + 1;
%% 
% View table.

TableProp
%% 
% Determine blocked reactions properties (optional).
% 
% To evaluate the following model properties of bloack reactions, the solver 
% package of IBM ILOG CPLEX is required. To install CPLEX refer to The Cobra Toolbox 
% <https://github.com/opencobra/cobratoolbox/blob/master/docs/source/installation/solvers.md 
% solver instalation guide>, and change the solver to 'ibm_cplex' using the changeCobraSolver 
% as shown above in equipment set-up. 
% 
% * Determine the number of blocked reactions using fastFVA with 4 paralell 
% workers (optional).

nworkers = 2;
solver = 'ibm_cplex';
setWorkerCount(nworkers);
tol = 1e-6;

TableProp(r, 1) = {'Blocked Reactions'};
[minFluxR3M, maxFluxR3M] = fastFVA(model, 0, 'max', solver);
TableProp{r, 2} = num2str(length(intersect(find(abs(minFluxR3M) < tol), find(abs(maxFluxR3M) < tol))));
r = r + 1;
%% 
% *  Determine the percentage of blocked reactions.

TableProp(r, 1) = {'Blocked Reactions (Percentage)'};
TableProp{r, 2} = num2str(length(intersect(find(abs(minFluxR3M) < tol), find(abs(maxFluxR3M) < tol)))/length(model.rxns));
r = r + 1;
%% 
% View table

TableProp
%% TIMING
% This tutorial takes a few minutes depending on solver, computer, and model 
% size. The most time consuming step is the flux variability analysis.
%% References
%  [1] <http://www.nature.com/nbt/journal/v31/n5/full/nbt.2488.html Thiele et 
% al., A community-driven global reconstruction of human metabolism, Nat Biotech, 
% 2013.>