%% *ICON-GEMs*
% *Authors: Thummarat Paklao*$$^1$$*, Apichat Suratanee*$$^2$$*, and Kitiporn 
% Plaimas*$$^3$$
% 
% *ICONGEMs* (Integration of CO-expression Network into GEnome scale Metabolic 
% models) [1] - an approach to integrating gene co-expression networks into FBA 
% models, allowing for more accurate determination of flux distribution and functional 
% pathways. By constructing a comprehensive gene co-expression network, we obtained 
% a global perspective on the cell's mechanism. Using quadratic programming, we 
% optimized the alignment between pairs of reaction fluxes and the correlation 
% of their associated genes within the co-expression network.
% 
% $$\max \;\sum_{\left(i,j\right)\;\in \;R} q_i q_j =q^T \textrm{Aq}$$
% 
% Subject to    $\sum_{j=1}^{n+p} {\bar{S} }_{i,j} {\bar{v} }_j =0$,
% 
% $0\le {\bar{v} }_j \le f\left(g_j \right)$        for all $j=1,2,3,^{\prime 
% } \ldotp \ldotp \ldotp ,n+p$,
% 
% $$\sum_{j=1}^{n+p} {\bar{c} }_j {\bar{v} }_j \ge \alpha z^*$$
% 
% $$\sum_{\left(i,j\right)\;\in \;\textrm{Re}} v_i v_j =0$$
% 
% $q_j =1+\frac{v_j }{M_j }$     for all $j=1,2,3,^{\prime } \ldotp \ldotp \ldotp 
% ,n+p$,
% 
% where the matrix $\bar{S} ={\left\lbrack S_{\textrm{irr}} \;\;\;S_{\textrm{rev}} 
% \;\;\;S_{\textrm{rev}} \right\rbrack }^T$ includes submatrices $S_{\textrm{irr}}$� 
% and $\;S_{\textrm{rev}}$�, which correspond to the columns of matrix $S$ that 
% represent irreversible and reversible reaction fluxes, respectively. The vector 
% $\bar{v} ={\left\lbrack v_{\textrm{irr}} \;\;\;v_{\textrm{rev}} \;\;-v_{\textrm{rev}} 
% \right\rbrack }^T$ contains components of irreversibly and reversibly oriented 
% fluxes, where $v_{\textrm{rev}}$� represents the reversible component. The function 
% $f\left(g_i \right)$ converts a gene expression value $g_j$� into a corresponding 
% flux bound value.
% 
% The vector $\bar{c} ={\left\lbrack c_{\textrm{irr}} \;\;\;c_{\textrm{rev}} 
% \;\;\;c_{\textrm{rev}} \right\rbrack }^T$ encompasses components of irreversible 
% and reversible reaction fluxes, where $c_{\textrm{irr}}$ and $c_{\textrm{rev}}$denote 
% the irreversible and reversible fluxes, respectively. The vector $\bar{c}$ is 
% initialized as zeros, with a single one placed at the position of the reaction 
% of interest (biomass flux). The symbol $z^*$ represents the potential maximum 
% biomass predicted using the E-flux method [2]. The parameter $\alpha \in$(0,1] 
% determines the proportion of biomass required to evaluate the organisms' vitality, 
% and in this study, $\alpha$ is set to 1. The set 𝑅𝑒𝑣 consists of reaction 
% pairs derived from the same reversible reaction flux. The term 𝑀𝑗 represents 
% the maximum gene expression value for reaction flux 𝑗.
% 
% In this model, $q_i$ and $q_j$ represent the transformed flux values for reactions 
% $i$ and $j$, respectively. The set 𝑅 includes reaction pairs with genes linked 
% in the co-expression network. The objective function is a summation of the products, 
% specifically for reactions  $i$ and $j$ corresponding to genes connected within 
% the co-expression network. 
%% 
% *REQUIREMENT*
% 
% - Matlab (version 2018a or better)
% 
% - Cobra Toolbox
% 
% - Gurobi solver (version 9.0.1 or better, free academic)
% 
% - Gene expression profile in .csv file 
% 
% (Note that the first column of gene expression data should have gene symbols/names 
% used in  the GPR association of the genome scale metabolic model. First row 
% of gene expression data should have condition names.)

initCobraToolbox(false) % false, as we don't want to update
%% 
% 
%% 
% Load the expression data that will be used for the simulation. For this tutorial, 
% we have choosen to use E. coli Microarray-based gene expression data  (downloaded 
% from http://systemsbiology.ucsd.edu/InSilicoOrganisms/Ecoli/EcoliExpression2) 

modelFileName = 'ecoli_core_model.mat';
modelDirectory = getDistributedModelFolder(modelFileName); %Look up the folder for the distributed Models.
modelFileName= [modelDirectory filesep modelFileName]; % Get the full path. Necessary to be sure, that the right model is loaded
model = readCbModel(modelFileName);
%% 
% 
%% 
% Load the expression data that will be used for the simulation. For this tutorial, 
% we have chosen to use E. coli microarray-based gene expression data

fileGeneName = 'gene_exp.csv';
fileDir = fileparts(which(fileGeneName));
cd(fileDir);
[exp, genetxt] = xlsread([fileDir filesep fileGeneName]);
%% 
% The integration of the co-expression network and metabolic model is completed 
% using the function ICONGEMs. The inputs are: a loaded model file, an expression 
% array (exp), genetxt, a row vector of conditions for calculating flux distribution 
% (with the default set to all conditions), and a threshold for constructing the 
% co-expression network (default value is 0.9). The alpha value represents the 
% proportion of biomass (a value in the range (0,1], with the default set to 1).

solution = ICONGEMs(model, exp, genetxt);
%% 
% Using optional inputs:

% set parameter
condition = 1:size(exp,2);
threashold = 0.9;
alpha = 0.99;
%% 
% Call ICONGEMs function:

solution1 = ICONGEMs(model, exp, genetxt, condition, threshold,alpha);
%% 
% After the algorithm is finished, the solution for the predicted metabolic 
% fluxes will be added to the workspace. Numerical flux values can be examined 
% in more detail by double-clicking the solution. Moreover, the output of this 
% algorithm is reported in the |result.csv| file.
%% 
% *REFERENCES*
% 
% 1. Paklao, T., Suratanee, A. & Plaimas, K. ICON-GEMs: integration of co-expression 
% network in genome-scale metabolic models, shedding light through systems biology. 
% BMC Bioinformatics 24, 492 (2023). <https://doi.org/10.1186/s12859-023-05599-0. 
% https://doi.org/10.1186/s12859-023-05599-0.>
% 
% 2. Colijn C, Brandes A, Zucker J, Lun DS, Weiner B, Farhat MR, Cheng T-Y, 
% Moody DB, Murray M, Galagan JE. Interpreting expression data with metabolic 
% flux models: predicting mycobacterium tuberculosis mycolic acid production. 
% PLoS Comput Biol. 2009;5(8):e1000489.