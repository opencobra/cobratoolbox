%% Computation and analysis of microbe-microbe metabolic interactions
%% Author: Almut Heinken, Molecular Systems Physiology Group, National University of Ireland Galway.
% This tutorial demonstrates how to join a given list of microbial COBRA models 
% in all possible combinations and compute the metabolic
% 
% interactions between the microbes depending on the implemented diet. Moreover, 
% the tradeoff between the growth of different joined microbes is computed. The 
% tutorial can be adapted to any number of AGORA models and dietary conditions 
% analyzed.
%% Requirements
% This tutorial requires the Parallel Computing Toolbox, Bioinformatics Toolbox, 
% and Statistics and Machine Learning Toolbox add-ons in MATLAB.
%% Initialize the COBRA Toolbox

initCobraToolbox
%% Prepare input data and models
% We will use the AGORA resource (Magnusdottir et al., Nat Biotechnol. 2017 
% Jan;35(1):81-89) in this tutorial. AGORA version 1.03 is available at https://github.com/VirtualMetabolicHuman/AGORA. 
% Download AGORA and place the models into a folder.

websave('AGORA-master.zip','https://github.com/VirtualMetabolicHuman/AGORA/archive/master.zip')
try
    unzip('AGORA-master')
end
modPath = [pwd filesep 'AGORA-master' filesep 'CurrentVersion' filesep 'AGORA_1_03' filesep' 'AGORA_1_03_mat'];
%% 
% Import a file with information on the AGORA organisms including reconstruction 
% names and taxonomy.

[~,infoFile,~]=xlsread('AGORA_infoFile.xlsx');
%% 
% Note: if you get a 'file not found' error for AGORA_infoFile.xlsx, please 
% run initCobraToolbox and ensure that the cobratoolbox/papers folder is in the 
% MATLAB path.
%% Creation of pairwise models
% For the sake of this tutorial, we will use ten random AGORA reconstructions 
% from the info file.

modelList = infoFile(randi([2 length(infoFile)],1,10),1);
%% 
% Uncomment the following line to join all AGORA reconstructions in all combinations. 
% NOTE: this is very time-consuming due to the large number of model combinations 
% analyzed.
% 
% modelList=infoFile(2:end,1);
% 
% You may also enter a custom selection of AGORA reconstructions as a cell array 
% named modelList.
% 
% Let us define some parameters for joining the models. Set the coupling factor 
% c, which defined how the flux through all reactions in a model is coupled to 
% the flux through its biomass reaction. Allowed flux span through each reaction= 
% -(c * flux(biomass)) to +(c * flux(biomass)).

c = 400;
%% 
% Set the threshold u, which defines the flux through each reaction that is 
% allowed if flux through the biomass reaction is zero.

u = 0;
%% 
% Define whether or not genes from the models are merged and kept in the joined 
% models. If set to true the joining is more time-consuming.

mergeGenes = false;
%% 
% Define the number workers for parallel pool to allow parallel computing.Recommended 
% if a large number of microbe models is computed. Set to zero if parallel computing 
% is not available.

numWorkers = 4;
%% 
% path where to save results

mkdir('Results');
resPath = [pwd filesep 'Results'];
%% 
% Join the models in all possible combinations.

joinModelsPairwiseFromList(modelList,modPath,'pairwiseModelFolder', resPath,'c',c,'u',u,'mergeGenesFlag',mergeGenes,'numWorkers',numWorkers);
%% Computation of pairwise interactions
% The interactions between all microbes joined in the first step will be simulated 
% on given dietary conditions. Here, we will use four dietary conditions used 
% in Magnusdottir et al., Nat Biotechnol. 2017.: Western Diet without oxygen, 
% Western Diet with oxygen, High fiber diet without oxygen, and High fiber diet 
% with oxygen. Let us define the input parameters for the simulation of pairwise 
% interactions.
% 
% Name the four dietary conditions that will be simulated.

conditions = {'WesternDiet_NoOxygen','WesternDiet_WithOxygen','HighFiberDiet_NoOxygen','HighFiberDiet_WithOxygen'};
%% 
% Define the corresponding constraints to implement for each diet. The input 
% file needs to be a string array.

dietConstraints{1}={'EX_fru[u]','-0.14899','1000';'EX_glc_D[u]','-0.14899','1000';'EX_gal[u]','-0.14899','1000';'EX_man[u]','-0.14899','1000';'EX_mnl[u]','-0.14899','1000';'EX_fuc_L[u]','-0.14899','1000';'EX_glcn[u]','-0.14899','1000';'EX_rmn[u]','-0.14899','1000';'EX_arab_L[u]','-0.17878','1000';'EX_drib[u]','-0.17878','1000';'EX_rib_D[u]','-0.17878','1000';'EX_xyl_D[u]','-0.17878','1000';'EX_oxa[u]','-0.44696','1000';'EX_lcts[u]','-0.074493','1000';'EX_malt[u]','-0.074493','1000';'EX_sucr[u]','-0.074493','1000';'EX_melib[u]','-0.074493','1000';'EX_cellb[u]','-0.074493','1000';'EX_tre[u]','-0.074493','1000';'EX_strch1[u]','-0.25734','1000';'EX_amylopect900[u]','-1.5673e-05','1000';'EX_amylose300[u]','-4.7019e-05','1000';'EX_arabinan101[u]','-0.00016628','1000';'EX_arabinogal[u]','-2.1915e-05','1000';'EX_arabinoxyl[u]','-0.00030665','1000';'EX_bglc[u]','-7.05e-08','1000';'EX_cellul[u]','-2.8212e-05','1000';'EX_dextran40[u]','-0.00017632','1000';'EX_galmannan[u]','-1.4106e-05','1000';'EX_glcmannan[u]','-3.2881e-05','1000';'EX_homogal[u]','-0.00012823','1000';'EX_inulin[u]','-0.00047019','1000';'EX_kestopt[u]','-0.0028212','1000';'EX_levan1000[u]','-1.4106e-05','1000';'EX_lmn30[u]','-0.00047019','1000';'EX_lichn[u]','-8.2976e-05','1000';'EX_pect[u]','-3.3387e-05','1000';'EX_pullulan1200[u]','-1.1755e-05','1000';'EX_raffin[u]','-0.0047019','1000';'EX_rhamnogalurI[u]','-1.4492e-05','1000';'EX_rhamnogalurII[u]','-0.00026699','1000';'EX_starch1200[u]','-1.1755e-05','1000';'EX_xylan[u]','-3.2059e-05','1000';'EX_xyluglc[u]','-1.3146e-05','1000';'EX_arachd[u]','-0.003328','1000';'EX_chsterol[u]','-0.004958','1000';'EX_glyc[u]','-1.7997','1000';'EX_hdca[u]','-0.39637','1000';'EX_hdcea[u]','-0.036517','1000';'EX_lnlc[u]','-0.35911','1000';'EX_lnlnca[u]','-0.017565','1000';'EX_lnlncg[u]','-0.017565','1000';'EX_ocdca[u]','-0.16928','1000';'EX_ocdcea[u]','-0.68144','1000';'EX_octa[u]','-0.012943','1000';'EX_ttdca[u]','-0.068676','1000';'EX_ala_L[u]','-1','1000';'EX_cys_L[u]','-1','1000';'EX_ser_L[u]','-1','1000';'EX_arg_L[u]','-0.15','1000';'EX_his_L[u]','-0.15','1000';'EX_ile_L[u]','-0.15','1000';'EX_leu_L[u]','-0.15','1000';'EX_lys_L[u]','-0.15','1000';'EX_asn_L[u]','-0.225','1000';'EX_asp_L[u]','-0.225','1000';'EX_thr_L[u]','-0.225','1000';'EX_glu_L[u]','-0.18','1000';'EX_met_L[u]','-0.18','1000';'EX_gln_L[u]','-0.18','1000';'EX_pro_L[u]','-0.18','1000';'EX_val_L[u]','-0.18','1000';'EX_phe_L[u]','-1','1000';'EX_tyr_L[u]','-1','1000';'EX_gly[u]','-0.45','1000';'EX_trp_L[u]','-0.08182','1000';'EX_12dgr180[u]','-1','1000';'EX_26dap_M[u]','-1','1000';'EX_2dmmq8[u]','-1','1000';'EX_2obut[u]','-1','1000';'EX_3mop[u]','-1','1000';'EX_4abz[u]','-1','1000';'EX_4hbz[u]','-1','1000';'EX_5aop[u]','-1','1000';'EX_ac[u]','-1','1000';'EX_acald[u]','-1','1000';'EX_acgam[u]','-1','1000';'EX_acmana[u]','-1','1000';'EX_acnam[u]','-1','1000';'EX_ade[u]','-1','1000';'EX_adn[u]','-1','1000';'EX_adocbl[u]','-1','1000';'EX_akg[u]','-1','1000';'EX_ala_D[u]','-1','1000';'EX_amet[u]','-1','1000';'EX_amp[u]','-1','1000';'EX_anth[u]','-1','1000';'EX_arab_D[u]','-1','1000';'EX_avite1[u]','-1','1000';'EX_btn[u]','-1','1000';'EX_ca2[u]','-1','1000';'EX_cbl1[u]','-1','1000';'EX_cgly[u]','-1','1000';'EX_chol[u]','-1','1000';'EX_chor[u]','-1','1000';'EX_cit[u]','-1','1000';'EX_cl[u]','-1','1000';'EX_cobalt2[u]','-1','1000';'EX_csn[u]','-1','1000';'EX_cu2[u]','-1','1000';'EX_cytd[u]','-1','1000';'EX_dad_2[u]','-1','1000';'EX_dcyt[u]','-1','1000';'EX_ddca[u]','-1','1000';'EX_dgsn[u]','-1','1000';'EX_etoh[u]','-1','1000';'EX_fald[u]','-1','1000';'EX_fe2[u]','-1','1000';'EX_fe3[u]','-1','1000';'EX_fe3dcit[u]','-1','1000';'EX_fol[u]','-1','1000';'EX_for[u]','-1','1000';'EX_fum[u]','-1','1000';'EX_gam[u]','-1','1000';'EX_glu_D[u]','-1','1000';'EX_glyc3p[u]','-1','1000';'EX_gsn[u]','-1','1000';'EX_gthox[u]','-1','1000';'EX_gthrd[u]','-1','1000';'EX_gua[u]','-1','1000';'EX_h[u]','-1','1000';'EX_h2[u]','-1','1000';'EX_h2s[u]','-1','1000';'EX_hom_L[u]','-1','1000';'EX_hxan[u]','-1','1000';'EX_indole[u]','-1','1000';'EX_ins[u]','-1','1000';'EX_k[u]','-1','1000';'EX_lac_L[u]','-1','1000';'EX_lanost[u]','-1','1000';'EX_mal_L[u]','-1','1000';'EX_metsox_S_L[u]','-1','1000';'EX_mg2[u]','-1','1000';'EX_mn2[u]','-1','1000';'EX_mobd[u]','-1','1000';'EX_mqn7[u]','-1','1000';'EX_mqn8[u]','-1','1000';'EX_na1[u]','-1','1000';'EX_nac[u]','-1','1000';'EX_ncam[u]','-1','1000';'EX_nmn[u]','-1','1000';'EX_no2[u]','-1','1000';'EX_no2[u]','-1','1000';'EX_no3[u]','-1','1000';'EX_orn[u]','-1','1000';'EX_pheme[u]','-1','1000';'EX_phyQ[u]','-1','1000';'EX_pi[u]','-1','1000';'EX_pime[u]','-1','1000';'EX_pnto_R[u]','-1','1000';'EX_ptrc[u]','-1','1000';'EX_pydam[u]','-1','1000';'EX_pydx[u]','-1','1000';'EX_pydx5p[u]','-1','1000';'EX_pydxn[u]','-1','1000';'EX_q8[u]','-1','1000';'EX_retinol[u]','-1','1000';'EX_ribflv[u]','-1','1000';'EX_sel[u]','-1','1000';'EX_sheme[u]','-1','1000';'EX_so4[u]','-1','1000';'EX_spmd[u]','-1','1000';'EX_succ[u]','-1','1000';'EX_thf[u]','-1','1000';'EX_thm[u]','-1','1000';'EX_thymd[u]','-1','1000';'EX_ura[u]','-1','1000';'EX_uri[u]','-1','1000';'EX_vitd3[u]','-1','1000';'EX_xan[u]','-1','1000';'EX_zn2[u]','-1','1000';'EX_meoh[u]','-10','1000';'EX_h2o[u]','-10','1000'};
dietConstraints{2}={'EX_fru[u]','-0.14899','1000';'EX_glc_D[u]','-0.14899','1000';'EX_gal[u]','-0.14899','1000';'EX_man[u]','-0.14899','1000';'EX_mnl[u]','-0.14899','1000';'EX_fuc_L[u]','-0.14899','1000';'EX_glcn[u]','-0.14899','1000';'EX_rmn[u]','-0.14899','1000';'EX_arab_L[u]','-0.17878','1000';'EX_drib[u]','-0.17878','1000';'EX_rib_D[u]','-0.17878','1000';'EX_xyl_D[u]','-0.17878','1000';'EX_oxa[u]','-0.44696','1000';'EX_lcts[u]','-0.074493','1000';'EX_malt[u]','-0.074493','1000';'EX_sucr[u]','-0.074493','1000';'EX_melib[u]','-0.074493','1000';'EX_cellb[u]','-0.074493','1000';'EX_tre[u]','-0.074493','1000';'EX_strch1[u]','-0.25734','1000';'EX_amylopect900[u]','-1.5673e-05','1000';'EX_amylose300[u]','-4.7019e-05','1000';'EX_arabinan101[u]','-0.00016628','1000';'EX_arabinogal[u]','-2.1915e-05','1000';'EX_arabinoxyl[u]','-0.00030665','1000';'EX_bglc[u]','-7.05e-08','1000';'EX_cellul[u]','-2.8212e-05','1000';'EX_dextran40[u]','-0.00017632','1000';'EX_galmannan[u]','-1.4106e-05','1000';'EX_glcmannan[u]','-3.2881e-05','1000';'EX_homogal[u]','-0.00012823','1000';'EX_inulin[u]','-0.00047019','1000';'EX_kestopt[u]','-0.0028212','1000';'EX_levan1000[u]','-1.4106e-05','1000';'EX_lmn30[u]','-0.00047019','1000';'EX_lichn[u]','-8.2976e-05','1000';'EX_pect[u]','-3.3387e-05','1000';'EX_pullulan1200[u]','-1.1755e-05','1000';'EX_raffin[u]','-0.0047019','1000';'EX_rhamnogalurI[u]','-1.4492e-05','1000';'EX_rhamnogalurII[u]','-0.00026699','1000';'EX_starch1200[u]','-1.1755e-05','1000';'EX_xylan[u]','-3.2059e-05','1000';'EX_xyluglc[u]','-1.3146e-05','1000';'EX_arachd[u]','-0.003328','1000';'EX_chsterol[u]','-0.004958','1000';'EX_glyc[u]','-1.7997','1000';'EX_hdca[u]','-0.39637','1000';'EX_hdcea[u]','-0.036517','1000';'EX_lnlc[u]','-0.35911','1000';'EX_lnlnca[u]','-0.017565','1000';'EX_lnlncg[u]','-0.017565','1000';'EX_ocdca[u]','-0.16928','1000';'EX_ocdcea[u]','-0.68144','1000';'EX_octa[u]','-0.012943','1000';'EX_ttdca[u]','-0.068676','1000';'EX_ala_L[u]','-1','1000';'EX_cys_L[u]','-1','1000';'EX_ser_L[u]','-1','1000';'EX_arg_L[u]','-0.15','1000';'EX_his_L[u]','-0.15','1000';'EX_ile_L[u]','-0.15','1000';'EX_leu_L[u]','-0.15','1000';'EX_lys_L[u]','-0.15','1000';'EX_asn_L[u]','-0.225','1000';'EX_asp_L[u]','-0.225','1000';'EX_thr_L[u]','-0.225','1000';'EX_glu_L[u]','-0.18','1000';'EX_met_L[u]','-0.18','1000';'EX_gln_L[u]','-0.18','1000';'EX_pro_L[u]','-0.18','1000';'EX_val_L[u]','-0.18','1000';'EX_phe_L[u]','-1','1000';'EX_tyr_L[u]','-1','1000';'EX_gly[u]','-0.45','1000';'EX_trp_L[u]','-0.08182','1000';'EX_12dgr180[u]','-1','1000';'EX_26dap_M[u]','-1','1000';'EX_2dmmq8[u]','-1','1000';'EX_2obut[u]','-1','1000';'EX_3mop[u]','-1','1000';'EX_4abz[u]','-1','1000';'EX_4hbz[u]','-1','1000';'EX_5aop[u]','-1','1000';'EX_ac[u]','-1','1000';'EX_acald[u]','-1','1000';'EX_acgam[u]','-1','1000';'EX_acmana[u]','-1','1000';'EX_acnam[u]','-1','1000';'EX_ade[u]','-1','1000';'EX_adn[u]','-1','1000';'EX_adocbl[u]','-1','1000';'EX_akg[u]','-1','1000';'EX_ala_D[u]','-1','1000';'EX_amet[u]','-1','1000';'EX_amp[u]','-1','1000';'EX_anth[u]','-1','1000';'EX_arab_D[u]','-1','1000';'EX_avite1[u]','-1','1000';'EX_btn[u]','-1','1000';'EX_ca2[u]','-1','1000';'EX_cbl1[u]','-1','1000';'EX_cgly[u]','-1','1000';'EX_chol[u]','-1','1000';'EX_chor[u]','-1','1000';'EX_cit[u]','-1','1000';'EX_cl[u]','-1','1000';'EX_cobalt2[u]','-1','1000';'EX_csn[u]','-1','1000';'EX_cu2[u]','-1','1000';'EX_cytd[u]','-1','1000';'EX_dad_2[u]','-1','1000';'EX_dcyt[u]','-1','1000';'EX_ddca[u]','-1','1000';'EX_dgsn[u]','-1','1000';'EX_etoh[u]','-1','1000';'EX_fald[u]','-1','1000';'EX_fe2[u]','-1','1000';'EX_fe3[u]','-1','1000';'EX_fe3dcit[u]','-1','1000';'EX_fol[u]','-1','1000';'EX_for[u]','-1','1000';'EX_fum[u]','-1','1000';'EX_gam[u]','-1','1000';'EX_glu_D[u]','-1','1000';'EX_glyc3p[u]','-1','1000';'EX_gsn[u]','-1','1000';'EX_gthox[u]','-1','1000';'EX_gthrd[u]','-1','1000';'EX_gua[u]','-1','1000';'EX_h[u]','-1','1000';'EX_h2[u]','-1','1000';'EX_h2s[u]','-1','1000';'EX_hom_L[u]','-1','1000';'EX_hxan[u]','-1','1000';'EX_indole[u]','-1','1000';'EX_ins[u]','-1','1000';'EX_k[u]','-1','1000';'EX_lac_L[u]','-1','1000';'EX_lanost[u]','-1','1000';'EX_mal_L[u]','-1','1000';'EX_metsox_S_L[u]','-1','1000';'EX_mg2[u]','-1','1000';'EX_mn2[u]','-1','1000';'EX_mobd[u]','-1','1000';'EX_mqn7[u]','-1','1000';'EX_mqn8[u]','-1','1000';'EX_na1[u]','-1','1000';'EX_nac[u]','-1','1000';'EX_ncam[u]','-1','1000';'EX_nmn[u]','-1','1000';'EX_no2[u]','-1','1000';'EX_no2[u]','-1','1000';'EX_no3[u]','-1','1000';'EX_orn[u]','-1','1000';'EX_pheme[u]','-1','1000';'EX_phyQ[u]','-1','1000';'EX_pi[u]','-1','1000';'EX_pime[u]','-1','1000';'EX_pnto_R[u]','-1','1000';'EX_ptrc[u]','-1','1000';'EX_pydam[u]','-1','1000';'EX_pydx[u]','-1','1000';'EX_pydx5p[u]','-1','1000';'EX_pydxn[u]','-1','1000';'EX_q8[u]','-1','1000';'EX_retinol[u]','-1','1000';'EX_ribflv[u]','-1','1000';'EX_sel[u]','-1','1000';'EX_sheme[u]','-1','1000';'EX_so4[u]','-1','1000';'EX_spmd[u]','-1','1000';'EX_succ[u]','-1','1000';'EX_thf[u]','-1','1000';'EX_thm[u]','-1','1000';'EX_thymd[u]','-1','1000';'EX_ura[u]','-1','1000';'EX_uri[u]','-1','1000';'EX_vitd3[u]','-1','1000';'EX_xan[u]','-1','1000';'EX_zn2[u]','-1','1000';'EX_meoh[u]','-10','1000';'EX_h2o[u]','-10','1000';'EX_o2[u]','-10','1000'    };
dietConstraints{3}={'EX_fru[u]','-0.03947','1000';'EX_glc_D[u]','-0.03947','1000';'EX_gal[u]','-0.03947','1000';'EX_man[u]','-0.03947','1000';'EX_mnl[u]','-0.03947','1000';'EX_fuc_L[u]','-0.03947','1000';'EX_glcn[u]','-0.03947','1000';'EX_rmn[u]','-0.03947','1000';'EX_arab_L[u]','-0.04737','1000';'EX_drib[u]','-0.04737','1000';'EX_rib_D[u]','-0.04737','1000';'EX_xyl_D[u]','-0.04737','1000';'EX_oxa[u]','-0.11842','1000';'EX_lcts[u]','-0.01974','1000';'EX_malt[u]','-0.01974','1000';'EX_sucr[u]','-0.01974','1000';'EX_melib[u]','-0.01974','1000';'EX_cellb[u]','-0.01974','1000';'EX_tre[u]','-0.01974','1000';'EX_strch1[u]','-0.06818','1000';'EX_amylopect900[u]','-0.00034722','1000';'EX_amylose300[u]','-0.0010417','1000';'EX_arabinan101[u]','-0.0036837','1000';'EX_arabinogal[u]','-0.0004855','1000';'EX_arabinoxyl[u]','-0.0067935','1000';'EX_bglc[u]','-1.5625e-06','1000';'EX_cellul[u]','-0.000625','1000';'EX_dextran40[u]','-0.0039062','1000';'EX_galmannan[u]','-0.0003125','1000';'EX_glcmannan[u]','-0.00072844','1000';'EX_homogal[u]','-0.0028409','1000';'EX_inulin[u]','-0.010417','1000';'EX_kestopt[u]','-0.0625','1000';'EX_levan1000[u]','-0.0003125','1000';'EX_lmn30[u]','-0.010417','1000';'EX_lichn[u]','-0.0018382','1000';'EX_pect[u]','-0.00073965','1000';'EX_pullulan1200[u]','-0.00026042','1000';'EX_raffin[u]','-0.10417','1000';'EX_rhamnogalurI[u]','-0.00032106','1000';'EX_rhamnogalurII[u]','-0.0059148','1000';'EX_starch1200[u]','-0.00026042','1000';'EX_xylan[u]','-0.00071023','1000';'EX_xyluglc[u]','-0.00029124','1000';'EX_arachd[u]','-0.001664','1000';'EX_chsterol[u]','-0.002479','1000';'EX_glyc[u]','-0.89983','1000';'EX_hdca[u]','-0.19819','1000';'EX_hdcea[u]','-0.018258','1000';'EX_lnlc[u]','-0.17955','1000';'EX_lnlnca[u]','-0.008783','1000';'EX_lnlncg[u]','-0.008783','1000';'EX_ocdca[u]','-0.084641','1000';'EX_ocdcea[u]','-0.34072','1000';'EX_octa[u]','-0.006471','1000';'EX_ttdca[u]','-0.034338','1000';'EX_ala_L[u]','-1','1000';'EX_cys_L[u]','-1','1000';'EX_ser_L[u]','-1','1000';'EX_arg_L[u]','-0.15','1000';'EX_his_L[u]','-0.15','1000';'EX_ile_L[u]','-0.15','1000';'EX_leu_L[u]','-0.15','1000';'EX_lys_L[u]','-0.15','1000';'EX_asn_L[u]','-0.225','1000';'EX_asp_L[u]','-0.225','1000';'EX_thr_L[u]','-0.225','1000';'EX_glu_L[u]','-0.18','1000';'EX_met_L[u]','-0.18','1000';'EX_gln_L[u]','-0.18','1000';'EX_pro_L[u]','-0.18','1000';'EX_val_L[u]','-0.18','1000';'EX_phe_L[u]','-1','1000';'EX_tyr_L[u]','-1','1000';'EX_gly[u]','-0.45','1000';'EX_trp_L[u]','-0.08182','1000';'EX_12dgr180[u]','-1','1000';'EX_26dap_M[u]','-1','1000';'EX_2dmmq8[u]','-1','1000';'EX_2obut[u]','-1','1000';'EX_3mop[u]','-1','1000';'EX_4abz[u]','-1','1000';'EX_4hbz[u]','-1','1000';'EX_5aop[u]','-1','1000';'EX_ac[u]','-1','1000';'EX_acald[u]','-1','1000';'EX_acgam[u]','-1','1000';'EX_acmana[u]','-1','1000';'EX_acnam[u]','-1','1000';'EX_ade[u]','-1','1000';'EX_adn[u]','-1','1000';'EX_adocbl[u]','-1','1000';'EX_akg[u]','-1','1000';'EX_ala_D[u]','-1','1000';'EX_amet[u]','-1','1000';'EX_amp[u]','-1','1000';'EX_anth[u]','-1','1000';'EX_arab_D[u]','-1','1000';'EX_avite1[u]','-1','1000';'EX_btn[u]','-1','1000';'EX_ca2[u]','-1','1000';'EX_cbl1[u]','-1','1000';'EX_cgly[u]','-1','1000';'EX_chol[u]','-1','1000';'EX_chor[u]','-1','1000';'EX_cit[u]','-1','1000';'EX_cl[u]','-1','1000';'EX_cobalt2[u]','-1','1000';'EX_csn[u]','-1','1000';'EX_cu2[u]','-1','1000';'EX_cytd[u]','-1','1000';'EX_dad_2[u]','-1','1000';'EX_dcyt[u]','-1','1000';'EX_ddca[u]','-1','1000';'EX_dgsn[u]','-1','1000';'EX_etoh[u]','-1','1000';'EX_fald[u]','-1','1000';'EX_fe2[u]','-1','1000';'EX_fe3[u]','-1','1000';'EX_fe3dcit[u]','-1','1000';'EX_fol[u]','-1','1000';'EX_for[u]','-1','1000';'EX_fum[u]','-1','1000';'EX_gam[u]','-1','1000';'EX_glu_D[u]','-1','1000';'EX_glyc3p[u]','-1','1000';'EX_glyleu[u]','-2','1000';'EX_gsn[u]','-1','1000';'EX_gthox[u]','-1','1000';'EX_gthrd[u]','-1','1000';'EX_gua[u]','-1','1000';'EX_h[u]','-1','1000';'EX_h2[u]','-1','1000';'EX_h2s[u]','-1','1000';'EX_hom_L[u]','-1','1000';'EX_hxan[u]','-1','1000';'EX_indole[u]','-1','1000';'EX_ins[u]','-1','1000';'EX_k[u]','-1','1000';'EX_lac_L[u]','-1','1000';'EX_lanost[u]','-1','1000';'EX_mal_L[u]','-1','1000';'EX_metsox_S_L[u]','-1','1000';'EX_mg2[u]','-1','1000';'EX_mn2[u]','-1','1000';'EX_mobd[u]','-1','1000';'EX_mqn7[u]','-1','1000';'EX_mqn8[u]','-1','1000';'EX_na1[u]','-1','1000';'EX_nac[u]','-1','1000';'EX_ncam[u]','-1','1000';'EX_nmn[u]','-1','1000';'EX_no2[u]','-1','1000';'EX_no2[u]','-1','1000';'EX_no3[u]','-1','1000';'EX_orn[u]','-1','1000';'EX_pheme[u]','-1','1000';'EX_phyQ[u]','-1','1000';'EX_pi[u]','-1','1000';'EX_pime[u]','-1','1000';'EX_pnto_R[u]','-1','1000';'EX_ptrc[u]','-1','1000';'EX_pydam[u]','-1','1000';'EX_pydx[u]','-1','1000';'EX_pydx5p[u]','-1','1000';'EX_pydxn[u]','-1','1000';'EX_q8[u]','-1','1000';'EX_retinol[u]','-1','1000';'EX_ribflv[u]','-1','1000';'EX_sel[u]','-1','1000';'EX_sheme[u]','-1','1000';'EX_so4[u]','-1','1000';'EX_spmd[u]','-1','1000';'EX_succ[u]','-1','1000';'EX_thf[u]','-1','1000';'EX_thm[u]','-1','1000';'EX_thymd[u]','-1','1000';'EX_ura[u]','-1','1000';'EX_uri[u]','-1','1000';'EX_vitd3[u]','-1','1000';'EX_xan[u]','-1','1000';'EX_zn2[u]','-1','1000';'EX_meoh[u]','-10','1000';'EX_h2o[u]','-10','1000'    };
dietConstraints{4}={'EX_fru[u]','-0.03947','1000';'EX_glc_D[u]','-0.03947','1000';'EX_gal[u]','-0.03947','1000';'EX_man[u]','-0.03947','1000';'EX_mnl[u]','-0.03947','1000';'EX_fuc_L[u]','-0.03947','1000';'EX_glcn[u]','-0.03947','1000';'EX_rmn[u]','-0.03947','1000';'EX_arab_L[u]','-0.04737','1000';'EX_drib[u]','-0.04737','1000';'EX_rib_D[u]','-0.04737','1000';'EX_xyl_D[u]','-0.04737','1000';'EX_oxa[u]','-0.11842','1000';'EX_lcts[u]','-0.01974','1000';'EX_malt[u]','-0.01974','1000';'EX_sucr[u]','-0.01974','1000';'EX_melib[u]','-0.01974','1000';'EX_cellb[u]','-0.01974','1000';'EX_tre[u]','-0.01974','1000';'EX_strch1[u]','-0.06818','1000';'EX_amylopect900[u]','-0.00034722','1000';'EX_amylose300[u]','-0.0010417','1000';'EX_arabinan101[u]','-0.0036837','1000';'EX_arabinogal[u]','-0.0004855','1000';'EX_arabinoxyl[u]','-0.0067935','1000';'EX_bglc[u]','-1.5625e-06','1000';'EX_cellul[u]','-0.000625','1000';'EX_dextran40[u]','-0.0039062','1000';'EX_galmannan[u]','-0.0003125','1000';'EX_glcmannan[u]','-0.00072844','1000';'EX_homogal[u]','-0.0028409','1000';'EX_inulin[u]','-0.010417','1000';'EX_kestopt[u]','-0.0625','1000';'EX_levan1000[u]','-0.0003125','1000';'EX_lmn30[u]','-0.010417','1000';'EX_lichn[u]','-0.0018382','1000';'EX_pect[u]','-0.00073965','1000';'EX_pullulan1200[u]','-0.00026042','1000';'EX_raffin[u]','-0.10417','1000';'EX_rhamnogalurI[u]','-0.00032106','1000';'EX_rhamnogalurII[u]','-0.0059148','1000';'EX_starch1200[u]','-0.00026042','1000';'EX_xylan[u]','-0.00071023','1000';'EX_xyluglc[u]','-0.00029124','1000';'EX_arachd[u]','-0.001664','1000';'EX_chsterol[u]','-0.002479','1000';'EX_glyc[u]','-0.89983','1000';'EX_hdca[u]','-0.19819','1000';'EX_hdcea[u]','-0.018258','1000';'EX_lnlc[u]','-0.17955','1000';'EX_lnlnca[u]','-0.008783','1000';'EX_lnlncg[u]','-0.008783','1000';'EX_ocdca[u]','-0.084641','1000';'EX_ocdcea[u]','-0.34072','1000';'EX_octa[u]','-0.006471','1000';'EX_ttdca[u]','-0.034338','1000';'EX_ala_L[u]','-1','1000';'EX_cys_L[u]','-1','1000';'EX_ser_L[u]','-1','1000';'EX_arg_L[u]','-0.15','1000';'EX_his_L[u]','-0.15','1000';'EX_ile_L[u]','-0.15','1000';'EX_leu_L[u]','-0.15','1000';'EX_lys_L[u]','-0.15','1000';'EX_asn_L[u]','-0.225','1000';'EX_asp_L[u]','-0.225','1000';'EX_thr_L[u]','-0.225','1000';'EX_glu_L[u]','-0.18','1000';'EX_met_L[u]','-0.18','1000';'EX_gln_L[u]','-0.18','1000';'EX_pro_L[u]','-0.18','1000';'EX_val_L[u]','-0.18','1000';'EX_phe_L[u]','-1','1000';'EX_tyr_L[u]','-1','1000';'EX_gly[u]','-0.45','1000';'EX_trp_L[u]','-0.08182','1000';'EX_12dgr180[u]','-1','1000';'EX_26dap_M[u]','-1','1000';'EX_2dmmq8[u]','-1','1000';'EX_2obut[u]','-1','1000';'EX_3mop[u]','-1','1000';'EX_4abz[u]','-1','1000';'EX_4hbz[u]','-1','1000';'EX_5aop[u]','-1','1000';'EX_ac[u]','-1','1000';'EX_acald[u]','-1','1000';'EX_acgam[u]','-1','1000';'EX_acmana[u]','-1','1000';'EX_acnam[u]','-1','1000';'EX_ade[u]','-1','1000';'EX_adn[u]','-1','1000';'EX_adocbl[u]','-1','1000';'EX_akg[u]','-1','1000';'EX_ala_D[u]','-1','1000';'EX_amet[u]','-1','1000';'EX_amp[u]','-1','1000';'EX_anth[u]','-1','1000';'EX_arab_D[u]','-1','1000';'EX_avite1[u]','-1','1000';'EX_btn[u]','-1','1000';'EX_ca2[u]','-1','1000';'EX_cbl1[u]','-1','1000';'EX_cgly[u]','-1','1000';'EX_chol[u]','-1','1000';'EX_chor[u]','-1','1000';'EX_cit[u]','-1','1000';'EX_cl[u]','-1','1000';'EX_cobalt2[u]','-1','1000';'EX_csn[u]','-1','1000';'EX_cu2[u]','-1','1000';'EX_cytd[u]','-1','1000';'EX_dad_2[u]','-1','1000';'EX_dcyt[u]','-1','1000';'EX_ddca[u]','-1','1000';'EX_dgsn[u]','-1','1000';'EX_etoh[u]','-1','1000';'EX_fald[u]','-1','1000';'EX_fe2[u]','-1','1000';'EX_fe3[u]','-1','1000';'EX_fe3dcit[u]','-1','1000';'EX_fol[u]','-1','1000';'EX_for[u]','-1','1000';'EX_fum[u]','-1','1000';'EX_gam[u]','-1','1000';'EX_glu_D[u]','-1','1000';'EX_glyc3p[u]','-1','1000';'EX_glyleu[u]','-2','1000';'EX_gsn[u]','-1','1000';'EX_gthox[u]','-1','1000';'EX_gthrd[u]','-1','1000';'EX_gua[u]','-1','1000';'EX_h[u]','-1','1000';'EX_h2[u]','-1','1000';'EX_h2s[u]','-1','1000';'EX_hom_L[u]','-1','1000';'EX_hxan[u]','-1','1000';'EX_indole[u]','-1','1000';'EX_ins[u]','-1','1000';'EX_k[u]','-1','1000';'EX_lac_L[u]','-1','1000';'EX_lanost[u]','-1','1000';'EX_mal_L[u]','-1','1000';'EX_metsox_S_L[u]','-1','1000';'EX_mg2[u]','-1','1000';'EX_mn2[u]','-1','1000';'EX_mobd[u]','-1','1000';'EX_mqn7[u]','-1','1000';'EX_mqn8[u]','-1','1000';'EX_na1[u]','-1','1000';'EX_nac[u]','-1','1000';'EX_ncam[u]','-1','1000';'EX_nmn[u]','-1','1000';'EX_no2[u]','-1','1000';'EX_no2[u]','-1','1000';'EX_no3[u]','-1','1000';'EX_orn[u]','-1','1000';'EX_pheme[u]','-1','1000';'EX_phyQ[u]','-1','1000';'EX_pi[u]','-1','1000';'EX_pime[u]','-1','1000';'EX_pnto_R[u]','-1','1000';'EX_ptrc[u]','-1','1000';'EX_pydam[u]','-1','1000';'EX_pydx[u]','-1','1000';'EX_pydx5p[u]','-1','1000';'EX_pydxn[u]','-1','1000';'EX_q8[u]','-1','1000';'EX_retinol[u]','-1','1000';'EX_ribflv[u]','-1','1000';'EX_sel[u]','-1','1000';'EX_sheme[u]','-1','1000';'EX_so4[u]','-1','1000';'EX_spmd[u]','-1','1000';'EX_succ[u]','-1','1000';'EX_thf[u]','-1','1000';'EX_thm[u]','-1','1000';'EX_thymd[u]','-1','1000';'EX_ura[u]','-1','1000';'EX_uri[u]','-1','1000';'EX_vitd3[u]','-1','1000';'EX_xan[u]','-1','1000';'EX_zn2[u]','-1','1000';'EX_meoh[u]','-10','1000';'EX_h2o[u]','-10','1000';'EX_o2[u]','-10','1000'    };
%% 
% NOTE: if you design your own diet, make sure that exchange reaction abbreviations 
% correspond to the lumen exchanges in the joint models ('EX_compound[u]').
% 
% Define what counts as significant difference between single growth of the 
% microbes and growth when joined with another microbe-here we choose 10%.

sigD = 0.1;
%% 
% Simulate the pairwise interactions on the four dietary conditions.

for i = 1:length(conditions)
    % assign dietary constraints
    [pairwiseInteractions]=simulatePairwiseInteractions(resPath,'inputDiet',dietConstraints{i},'sigD',sigD,'saveSolutionsFlag', false,'numWorkers', numWorkers);
Interactions.(conditions{i})=pairwiseInteractions;
end
%% Analysis of computed pairwise interactions
% The computed microbe-microbe interactions will be plotted by type and analyzed 
% in the context of the taxonomy of the joined strains. There are six possible 
% types of interactions total that can result in increased growth (+), no change 
% in growth (=) or decreased growth (-) compared with the single condition for 
% each joined microbe.
%% 
% * Competition (-/-)
% * Parasitism (+/-)
% * Amensalism (=/-)
% * Neutralism (=/=)
% * Commensalism (+/=)
% * Mutualism (+/+)
%% 
% This results in nine different outcomes total from the perspective of each 
% joined microbe.
% 
% Plot the percentage of interactions computed.

figure('rend','painters','pos',[10 10 900 600])
typesIA=unique(pairwiseInteractions(2:end,10));
for i = 1:length(conditions)
    pairwiseInteractions=Interactions.(conditions{i});
    listIA=pairwiseInteractions(2:end,10);
    for j=1:length(typesIA)
        dat(j)=sum(strcmp(listIA(:),typesIA{j}));
    end
    subplot(2,2,i)
    pie(dat)
    set(gca,'FontSize',10)
    h=title(conditions{i});
    set(h,'interpreter','none')
    title(conditions{i})
end
legend1=legend(typesIA);
set(legend1,'Position',[0.42 0.45 0.2 0.2],'FontSize',12)
sgtitle('Percentage of computed pairwise interactions')
%% 
% Next, the percentage of interactions will be calculated on different taxon 
% levels (genus, family, order, class, phylum) using the taxon information contained 
% in AGORA_infoFile.xlsx. Here, the interactions will be considered from the perspective 
% of each joined microbe resulting in nine possible interactions total.
% 
% Calculate the percentage of interactions predicted for each taxon included 
% in the list of microbes analyzed.

for i = 1:length(conditions)
    pairwiseInteractions=Interactions.(conditions{i});
    [InteractionsByTaxon]=calculateInteractionsByTaxon(pairwiseInteractions,infoFile);
    TaxonSummaries.(conditions{i})=InteractionsByTaxon;
end
%% 
% Combine the four conditions into one structure.

InteractionsByTaxonCombined=struct;
for i = 1:length(conditions)
    InteractionsByTaxon=TaxonSummaries.(conditions{i});
    taxLevels=fieldnames(InteractionsByTaxon);
    if i==1
        for j=1:length(taxLevels)
            InteractionsByTaxonCombined.(taxLevels{j})=InteractionsByTaxon.(taxLevels{j});
            InteractionsByTaxonCombined.(taxLevels{j})(2:end,1)=strcat(InteractionsByTaxonCombined.(taxLevels{j})(2:end,1),'_',conditions{i});
        end
    else
        for j=1:length(taxLevels)
            rowLength=size(InteractionsByTaxonCombined.(taxLevels{j}),1);
            InteractionsByTaxonCombined.(taxLevels{j})=[InteractionsByTaxonCombined.(taxLevels{j});InteractionsByTaxon.(taxLevels{j})(2:end,:)];
            InteractionsByTaxonCombined.(taxLevels{j})(rowLength+1:end,1)=strcat(InteractionsByTaxonCombined.(taxLevels{j})(rowLength+1:end,1),'_',conditions{i});
        end
    end
end
%% 
% Let us plot the distributions of interactions for all dietary conditions combined 
% on the level of genera as an example. Note: The xticklabels/yticklabels function 
% is only available in MATLAB R2016b or newer. Older versions of MATLAB will be 
% unable to display the labels.

for i=5
    xlabels=InteractionsByTaxonCombined.(taxLevels{i})(1,2:end);
    ylabels=InteractionsByTaxonCombined.(taxLevels{i})(2:end,1);
    data=string(InteractionsByTaxonCombined.(taxLevels{i})(2:end,2:end));
    data=str2double(data);
    figure;
    imagesc(data)
    colormap('hot')
    colorbar
    set(gca,'xtick',1:length(xlabels));
    xticklabels(xlabels);
    set(gca,'ytick',1:length(ylabels));
    yticklabels(ylabels);
    xtickangle(90)
    set(gca,'TickLabelInterpreter', 'none');
    title(taxLevels{i})
end
%% Pareto optimality analysis
% Another way to analyze the metabolic interactions between two microbes in 
% Pareto optimality analysis. In this method, the tradeoff between two competing 
% objectives (e.g., the biomasses of two joined microbes) is calculated. The resulting 
% Pareto frontier depicts all possible outcomes of co-growth between the two microbes 
% under the given constraints.
% 
% Let us compute the Pareto frontier for five randomly chosen pairs from the 
% list of AGORA models.

modelInd = randi([2 length(infoFile)],2,5);
%% 
% The Pareto frontier will be computed on the Western diet without oxygen.

dietConstraints{1}={'EX_fru[u]','-0.14899','1000';'EX_glc_D[u]','-0.14899','1000';'EX_gal[u]','-0.14899','1000';'EX_man[u]','-0.14899','1000';'EX_mnl[u]','-0.14899','1000';'EX_fuc_L[u]','-0.14899','1000';'EX_glcn[u]','-0.14899','1000';'EX_rmn[u]','-0.14899','1000';'EX_arab_L[u]','-0.17878','1000';'EX_drib[u]','-0.17878','1000';'EX_rib_D[u]','-0.17878','1000';'EX_xyl_D[u]','-0.17878','1000';'EX_oxa[u]','-0.44696','1000';'EX_lcts[u]','-0.074493','1000';'EX_malt[u]','-0.074493','1000';'EX_sucr[u]','-0.074493','1000';'EX_melib[u]','-0.074493','1000';'EX_cellb[u]','-0.074493','1000';'EX_tre[u]','-0.074493','1000';'EX_strch1[u]','-0.25734','1000';'EX_amylopect900[u]','-1.5673e-05','1000';'EX_amylose300[u]','-4.7019e-05','1000';'EX_arabinan101[u]','-0.00016628','1000';'EX_arabinogal[u]','-2.1915e-05','1000';'EX_arabinoxyl[u]','-0.00030665','1000';'EX_bglc[u]','-7.05e-08','1000';'EX_cellul[u]','-2.8212e-05','1000';'EX_dextran40[u]','-0.00017632','1000';'EX_galmannan[u]','-1.4106e-05','1000';'EX_glcmannan[u]','-3.2881e-05','1000';'EX_homogal[u]','-0.00012823','1000';'EX_inulin[u]','-0.00047019','1000';'EX_kestopt[u]','-0.0028212','1000';'EX_levan1000[u]','-1.4106e-05','1000';'EX_lmn30[u]','-0.00047019','1000';'EX_lichn[u]','-8.2976e-05','1000';'EX_pect[u]','-3.3387e-05','1000';'EX_pullulan1200[u]','-1.1755e-05','1000';'EX_raffin[u]','-0.0047019','1000';'EX_rhamnogalurI[u]','-1.4492e-05','1000';'EX_rhamnogalurII[u]','-0.00026699','1000';'EX_starch1200[u]','-1.1755e-05','1000';'EX_xylan[u]','-3.2059e-05','1000';'EX_xyluglc[u]','-1.3146e-05','1000';'EX_arachd[u]','-0.003328','1000';'EX_chsterol[u]','-0.004958','1000';'EX_glyc[u]','-1.7997','1000';'EX_hdca[u]','-0.39637','1000';'EX_hdcea[u]','-0.036517','1000';'EX_lnlc[u]','-0.35911','1000';'EX_lnlnca[u]','-0.017565','1000';'EX_lnlncg[u]','-0.017565','1000';'EX_ocdca[u]','-0.16928','1000';'EX_ocdcea[u]','-0.68144','1000';'EX_octa[u]','-0.012943','1000';'EX_ttdca[u]','-0.068676','1000';'EX_ala_L[u]','-1','1000';'EX_cys_L[u]','-1','1000';'EX_ser_L[u]','-1','1000';'EX_arg_L[u]','-0.15','1000';'EX_his_L[u]','-0.15','1000';'EX_ile_L[u]','-0.15','1000';'EX_leu_L[u]','-0.15','1000';'EX_lys_L[u]','-0.15','1000';'EX_asn_L[u]','-0.225','1000';'EX_asp_L[u]','-0.225','1000';'EX_thr_L[u]','-0.225','1000';'EX_glu_L[u]','-0.18','1000';'EX_met_L[u]','-0.18','1000';'EX_gln_L[u]','-0.18','1000';'EX_pro_L[u]','-0.18','1000';'EX_val_L[u]','-0.18','1000';'EX_phe_L[u]','-1','1000';'EX_tyr_L[u]','-1','1000';'EX_gly[u]','-0.45','1000';'EX_trp_L[u]','-0.08182','1000';'EX_12dgr180[u]','-1','1000';'EX_26dap_M[u]','-1','1000';'EX_2dmmq8[u]','-1','1000';'EX_2obut[u]','-1','1000';'EX_3mop[u]','-1','1000';'EX_4abz[u]','-1','1000';'EX_4hbz[u]','-1','1000';'EX_5aop[u]','-1','1000';'EX_ac[u]','-1','1000';'EX_acald[u]','-1','1000';'EX_acgam[u]','-1','1000';'EX_acmana[u]','-1','1000';'EX_acnam[u]','-1','1000';'EX_ade[u]','-1','1000';'EX_adn[u]','-1','1000';'EX_adocbl[u]','-1','1000';'EX_akg[u]','-1','1000';'EX_ala_D[u]','-1','1000';'EX_amet[u]','-1','1000';'EX_amp[u]','-1','1000';'EX_anth[u]','-1','1000';'EX_arab_D[u]','-1','1000';'EX_avite1[u]','-1','1000';'EX_btn[u]','-1','1000';'EX_ca2[u]','-1','1000';'EX_cbl1[u]','-1','1000';'EX_cgly[u]','-1','1000';'EX_chol[u]','-1','1000';'EX_chor[u]','-1','1000';'EX_cit[u]','-1','1000';'EX_cl[u]','-1','1000';'EX_cobalt2[u]','-1','1000';'EX_csn[u]','-1','1000';'EX_cu2[u]','-1','1000';'EX_cytd[u]','-1','1000';'EX_dad_2[u]','-1','1000';'EX_dcyt[u]','-1','1000';'EX_ddca[u]','-1','1000';'EX_dgsn[u]','-1','1000';'EX_etoh[u]','-1','1000';'EX_fald[u]','-1','1000';'EX_fe2[u]','-1','1000';'EX_fe3[u]','-1','1000';'EX_fe3dcit[u]','-1','1000';'EX_fol[u]','-1','1000';'EX_for[u]','-1','1000';'EX_fum[u]','-1','1000';'EX_gam[u]','-1','1000';'EX_glu_D[u]','-1','1000';'EX_glyc3p[u]','-1','1000';'EX_gsn[u]','-1','1000';'EX_gthox[u]','-1','1000';'EX_gthrd[u]','-1','1000';'EX_gua[u]','-1','1000';'EX_h[u]','-1','1000';'EX_h2[u]','-1','1000';'EX_h2s[u]','-1','1000';'EX_hom_L[u]','-1','1000';'EX_hxan[u]','-1','1000';'EX_indole[u]','-1','1000';'EX_ins[u]','-1','1000';'EX_k[u]','-1','1000';'EX_lac_L[u]','-1','1000';'EX_lanost[u]','-1','1000';'EX_mal_L[u]','-1','1000';'EX_metsox_S_L[u]','-1','1000';'EX_mg2[u]','-1','1000';'EX_mn2[u]','-1','1000';'EX_mobd[u]','-1','1000';'EX_mqn7[u]','-1','1000';'EX_mqn8[u]','-1','1000';'EX_na1[u]','-1','1000';'EX_nac[u]','-1','1000';'EX_ncam[u]','-1','1000';'EX_nmn[u]','-1','1000';'EX_no2[u]','-1','1000';'EX_no2[u]','-1','1000';'EX_no3[u]','-1','1000';'EX_orn[u]','-1','1000';'EX_pheme[u]','-1','1000';'EX_phyQ[u]','-1','1000';'EX_pi[u]','-1','1000';'EX_pime[u]','-1','1000';'EX_pnto_R[u]','-1','1000';'EX_ptrc[u]','-1','1000';'EX_pydam[u]','-1','1000';'EX_pydx[u]','-1','1000';'EX_pydx5p[u]','-1','1000';'EX_pydxn[u]','-1','1000';'EX_q8[u]','-1','1000';'EX_retinol[u]','-1','1000';'EX_ribflv[u]','-1','1000';'EX_sel[u]','-1','1000';'EX_sheme[u]','-1','1000';'EX_so4[u]','-1','1000';'EX_spmd[u]','-1','1000';'EX_succ[u]','-1','1000';'EX_thf[u]','-1','1000';'EX_thm[u]','-1','1000';'EX_thymd[u]','-1','1000';'EX_ura[u]','-1','1000';'EX_uri[u]','-1','1000';'EX_vitd3[u]','-1','1000';'EX_xan[u]','-1','1000';'EX_zn2[u]','-1','1000';'EX_meoh[u]','-10','1000';'EX_h2o[u]','-10','1000'};
%% 
% By default, the points of the frontier will be generated at steps of 0.001.

dinc=0.001;
%% 
% Perform the Pareto optimality analysis for the five pairs. The shape of the 
% computed Pareto frontier, which represents all possible optimal solutions of 
% simultaneously optimized growth, depends on the metabolic networks of the two 
% joined microbes.

for i=1:size(modelInd,2)
    models={};
    model=readCbModel([modPath filesep infoFile{modelInd(1,i),1} '.mat']);
    models{1,1}=model;
    bioID{1,1}=model.rxns(find(strncmp(model.rxns,'biomass',7)));
    nameTagsModels{1,1}=strcat(infoFile{modelInd(1,i),1},'_');
    model=readCbModel([modPath filesep infoFile{modelInd(2,i),1} '.mat']);
    models{2,1}=model;
    nameTagsModels{2,1}=strcat(infoFile{modelInd(2,i),1},'_');
    bioID{2,1}=model.rxns(find(strncmp(model.rxns,'biomass',7)));
    [pairedModel] = createMultipleSpeciesModel(models,'nameTagsModels',nameTagsModels);
    [pairedModel]=coupleRxnList2Rxn(pairedModel,pairedModel.rxns(strmatch(nameTagsModels{1,1},pairedModel.rxns)),strcat(infoFile{modelInd(1,i),1},'_',bioID{1,1}));
    [pairedModel]=coupleRxnList2Rxn(pairedModel,pairedModel.rxns(strmatch(nameTagsModels{2,1},pairedModel.rxns)),strcat(infoFile{modelInd(2,i),1},'_',bioID{2,1}));
    pairedModel=useDiet(pairedModel,dietConstraints{1});
    [ParetoFrontier] = computeParetoOptimality(pairedModel,strcat(infoFile{modelInd(1,i),1},'_',bioID{1,1}),strcat(infoFile{modelInd(2,i),1},'_',bioID{2,1}),'dinc',0.001,'FVAflag',false);
end
%% 
% Can you interpret the shapes of the five Pareto frontiers that were computed? 
% Are there microbe pairs that are always competing with each other? Are there 
% pairs in which one microbe can benefit the other at certain points in the curve 
% and vice versa?