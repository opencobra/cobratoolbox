% %% Tutorial II - Integration of quantitative metabolomic data 

%% Start of the tutorial
clear
initCobraToolbox
tol =  1e-6;

%%% specify your own solver
solver = '...ADD YOUR SOLVER...'; % can be gurobi or tomlab_cplex
solverQuant = 'cplex_direct'; % can only be cplex_direct
path = ' ... ADD YOUR PATH...\'; % output is saved to this location, can be the same as pathToCOBRA 'C: ... \cobratoolbox\metabotools\tutorial_II\';
pathToCOBRA =  '.. ADD YOUR PATH TO cobratoolbox...'; % to load tutorial input files ,; e.g., pathToCOBRA = 'D:\..\Documents\GitHub\'


%% set and check solver
solverQOK = changeCobraSolver(solverQuant,'LP');

if solverQOK ==1
    display('The solverQuant is set.');
else
    display('Error in solverQuant: Check if the solver is in the matlab path (set path) or check for typos? Ignore if not required');
end

solverOK = changeCobraSolver(solver,'LP');

if solverOK ==1
    display('The LP solver is set.');
else
    display('Error in  LP solver: Check if the solver is in the matlab path (set path) or check for typos?');
end

solverQPOK = changeCobraSolver(solver,'QP');
if solverOK ==1
    display('The QP solver is set.');
else
    display('Error in  LP solver: Check if the solver is in the matlab path (set path) or check for typos?');
end


%% load and check tutorial input is loaded correctly
if isequal(exist([pathToCOBRA '\cobratoolbox\metabotools\tutorial_I\starting_model.mat'],'file'),2)% 2 means it's a file.
    % We have a file!
    load([pathToCOBRA '\cobratoolbox\metabotools\tutorial_II\starting_model.mat']);
    display('The model is loaded.');
   
else 
    display('Error in pathToCOBRA: The starting_model and tutorial_II_data could not be loaded. Does pathToCOBRA contain typos or additional '\'? ');
end 

% Check output path and writing permission
if ~exist(path)==7
    display('Error in path: Does pathToCOBRA contain typos or additional '\' ?');
end

% display if writing is not possible
display('Warning: If a red matlab error message appears after this message, files cannot be saved to your path location! Obtain rights to write into output directory or set path to a different directory.');

% make and save dummy file to test writing to output directory
A = rand(1);
save([path '\' 'A']);


display('Continue with tutorial if solver and paths are set correctly.');

%% Section 1 - Define the model bounds using setMediumConstraints

set_inf = 2000;
current_inf = 1000;
medium_composition = {};
met_Conc_mM = [];
cellConc = [];
t =[];
cellWeight =[];

mediumCompounds = {'EX_h(e)', 'EX_h2o(e)', 'EX_hco3(e)', 'EX_nh4(e)', 'EX_o2(e)', 'EX_pi(e)', 'EX_so4(e)'};
ions={'EX_ca2(e)', 'EX_cl(e)', 'EX_co(e)', 'EX_fe2(e)', 'EX_fe3(e)', 'EX_k(e)', 'EX_na1(e)', 'EX_i(e)', 'EX_sel(e)'};

mediumCompounds = [ions mediumCompounds];
mediumCompounds_lb = -100;

customizedConstraints = {'EX_co2(e)','EX_o2(e)','EX_his_L(e)','EX_ile_L(e)', 'EX_leu_L(e)',  'EX_lys_L(e)', 'EX_phe_L(e)', 'EX_thr_L(e)', 'EX_trp_L(e)','EX_val_L(e)', 'EX_met_L(e)','EX_ascb_L(e)', 'EX_btn(e)', 'EX_chol(e)', 'EX_fol(e)', 'EX_pnto_R(e)', 'EX_retn(e)', 'EX_thm(e)', 'EX_vitd2(e)', 'EX_vitd3(e)','EX_retinol(e)'};
customizedConstraints_ub = [2000,0,2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000];
customizedConstraints_lb = [-100,-1000, -10,-10,-10,-10,-10,-10,-10,-10,-10, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1];

close_exchanges = 0;

[modelMedium,basisMedium] = setMediumConstraints(starting_model, set_inf, current_inf, medium_composition, met_Conc_mM, cellConc, t, cellWeight, mediumCompounds, mediumCompounds_lb, customizedConstraints, customizedConstraints_ub, customizedConstraints_lb, close_exchanges);


clearvars -EXCEPT modelMedium tol solver path solverQuant

%% Section 2 - Generate an individual exchange profiles for each sample

load([path 'tutorial_II_data']);
model = modelMedium;
test_max = 500;
test_min = 0.0001;
variation = 20;

prepIntegrationQuant(model,metData,exchanges,samples,test_max,test_min,path,tol,variation);

clearvars -EXCEPT modelMedium samples tol solver path solverQuant



%% Section 2B - Prepare table to check exchange profiles
nmets = 70;
[mapped_exchanges, minMax,mapped_uptake, mapped_secretion] = checkExchangeProfiles(samples, path ,nmets);

clearvars -EXCEPT modelMedium samples tol solver mapped_exchanges  path solverQuant

save ([path 'Result_checkExchangeProfiles']);


%% Section 3 - Generate contextualized models

changeCobraSolver(solverQuant,'LP');

minGrowth= 0.008;
obj= 'biomass_reaction2';
no_secretion= {'EX_o2(e)'};
no_uptake= {'EX_o2s(e)','EX_h2o2(e)'};
medium= {};
tol =  1e-6;
model = modelMedium;
epsilon = 1e-4;

addExtraExch = {'EX_tdchola(e)','Ex_5hoxindoa[e]'};
addExtraExch_value = 1;
[ResultsAllCellLines,OverViewResults] = setQuantConstraints(model,samples,tol,minGrowth,obj,no_secretion,no_uptake,medium,addExtraExch,addExtraExch_value,path,epsilon);
clearvars -EXCEPT modelMedium samples ResultsAllCellLines OverViewResults tol solver mapped_exchanges path

%% Section 4 - Analyze added exchanges

changeCobraSolver(solver,'LP');

[Ex_added_all_unique] = statisticsAddedExchanges(ResultsAllCellLines,samples);
clearvars -EXCEPT modelMedium samples ResultsAllCellLines OverViewResults Ex_added_all_unique tol solver mapped_exchanges path


[Added_all] = mkTableOfAddedExchanges(ResultsAllCellLines,samples,Ex_added_all_unique);

save([path 'statistics']);

clearvars -EXCEPT modelMedium samples ResultsAllCellLines OverViewResults tol solver mapped_exchanges path



%% Section 5 - Analyze the sets of essential genes

cutoff= 0.05;

[genes,ResultsAllCellLines,OverViewResults] = analyzeSingleGeneDeletion(ResultsAllCellLines, path, samples, cutoff, OverViewResults);

clearvars -EXCEPT modelMedium samples ResultsAllCellLines OverViewResults Ex_added_all_unique genes tol solver mapped_exchanges  path


%% Section 6 - Check which individual gene-associated reaction makes the model infeasible

samples_to_test = samples;
fill = 'NAN';
genes_to_test = {'55293.1'};

[FBA_Rxns_KO,ListResults] = checkEffectRxnKO(samples_to_test,fill,genes_to_test,samples,ResultsAllCellLines);

clearvars -EXCEPT modelMedium samples ResultsAllCellLines OverViewResults Ex_added_all_unique genes FBA_Rxns_KO ListResults tol solver mapped_exchanges  path


%% Section 7 - Make intersect and union model

mk_union = 1;
mk_intersect = 1;
mk_reactionDiff = 1;
load([path 'starting_model']);
model = starting_model;

[unionModel,intersectModel, diffRxns, diffExRxns] = makeSummaryModels(ResultsAllCellLines,samples, model, mk_union, mk_intersect, mk_reactionDiff);
clearvars -EXCEPT modelMedium samples ResultsAllCellLines OverViewResults Ex_added_all_unique genes FBA_Rxns_KO ListResults unionModel intersectModel  diffRxns diffExRxns tol solver mapped_exchanges  path model

save([path 'summary']);


%% Section 8 - Predict differences in metabolite production or consumption
%% Section 8A ATP production
obj= 'DM_atp_c_';
carbon_source = {'EX_glc(e)'};
samples=samples(1:4,1);
dir = 1;

% ATP production
% exclude transport reactions from flux split analysis
transportRxns = {'ATPtm' 
    'ATPtn'
    'ATPtx'
    'ATP1ter'
    'ATP2ter'
    'EX_atp(e)'
    'DNDPt13m'
    'DNDPt2m'
    'DNDPt31m'
    'DNDPt56m'
    'DNDPt32m'
    'DNDPt57m'
    'DNDPt20m'
    'DNDPt44m'
    'DNDPt19m'
    'DNDPt43m'
    'ADK1'
    'ADK1m'
    };


ATPprod = {
'ATPS4m'
'PGK'
'PYK'
'SUCOASm'
};


met2test = {'atp[c]','atp[m]','atp[n]','atp[r]','atp[x]'};
[BMall,ResultsAllCellLines,metRsall, maximum_contributing_rxn,maximum_contributing_flux,ATPyield] = predictFluxSplits(model, obj, met2test,samples,ResultsAllCellLines, dir,  transportRxns,ATPprod,carbon_source);

PHs =[samples maximum_contributing_rxn(:,1)];

maximum_contributing_flux_ATP = maximum_contributing_flux;

clear ATPprod transportRxns met2test maximum_contributing_rxn
 
 
 
 
%% Section 8B NADH production
met2test ={'nadh[c]','nadh[m]','nadh[n]','nadh[x]', 'nadh[r]'};

transportRxns = {'NADHtpu'
    'NADHtru'
    'NADtpu'
    };


[BMall,ResultsAllCellLines,metRsall, maximum_contributing_rxn, maximum_contributing_flux_NADH] = predictFluxSplits(model, obj, met2test,samples,ResultsAllCellLines, dir, transportRxns);
PHs =[PHs maximum_contributing_rxn(:,1)];


clear transportRxns met2test  maximum_contributing_rxn


%% Section 8C FADH2 production
transportRxns = {'FADH2tru'
    'FADH2tx'
    };


met2test ={'fadh2[c]','fadh2[m]','fadh2[n]','fadh2[x]', 'fadh2[r]'};
[BMall,ResultsAllCellLines,metRsall, maximum_contributing_rxn, maximum_contributing_flux_FADH2] = predictFluxSplits(model, obj, met2test,samples,ResultsAllCellLines, dir,  transportRxns);

clear transportRxns met2test

PHs =[PHs maximum_contributing_rxn(:,1)];



%% Section 8D NADPH production

transportRxns = {'NADPHtru'
    'NADPHtxu'
    };

met2test ={'nadph[c]','nadph[m]','nadph[n]','nadph[x]', 'nadph[r]'};
[BMall,ResultsAllCellLines,metRsall, maximum_contributing_rxn, maximum_contributing_flux_NADPH] = predictFluxSplits(model, obj, met2test,samples,ResultsAllCellLines, dir, transportRxns);
clear transportRxns met2test 

PHs =[PHs maximum_contributing_rxn(:,1)];

save([path 'fluxSplits']);

%% Section 8E illustrate the phenotypes (PHs) on 3Dplot 

diff_view = 1;
fonts = 18;

make3Dplot(PHs, maximum_contributing_flux_ATP, fonts, path, diff_view);

 
%% Section 9 Perform phase Plane Analysis

mets ={'EX_glc(e)','EX_o2(e)';'EX_gln_L(e)','EX_o2(e)';'EX_lac_L(e)','EX_o2(e)'};
step_size = [40,40;20,40;40,40];
step_num = [28,26;21,26;42,26];
direct = [-1,-1;-1,-1;1,-1];

[ResultsAllCellLines] = performPPP(ResultsAllCellLines,mets,step_size,samples,step_num,direct);

save([path 'PPP']);



%% Section 9b illustrate phase plane analysis results

label = {'Glucose uptake (fmol/cell/hr)'; 'Oxygen uptake (fmol/cell/hr)';'Growth rate (hr-1)'};
mets ={'EX_glc(e)';'EX_o2(e)'};
fonts = 12;
samples = {'IGROV1'};
illustrate_ppp(ResultsAllCellLines,mets,path,samples,label,fonts,tol);



