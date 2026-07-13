%% Computation and analysis of rescued lethal gene deletions in a host-microbe model
%% Author: Almut Heinken, Molecular Systems Physiology Group, University of Luxembourg.
% Constraint-based modeling has useful applications for predicting the metabolic 
% interactions between a mammalian host and its commensal gut microbes. For example, 
% the potential of a human gut microbe to rescue lethal gene defects in the mouse 
% has been predicted. Some of these rescued gene defects correspond to human inborn 
% errors of metabolism (IEMs) (Heinken et al., Gut Microbes (2013) 4(1):28-40). 
% A variety of IEMs are documented in human and can be browsed at <https://www.vmh.life/#diseases 
% https://www.vmh.life/#diseases>.
% 
% This tutorial demonstrates how to predict the potential of a commensal 
% gut microbe to rescue lethal gene deletions in a mammalian host. For this purpose, 
% a microbe is joined with a mouse host.
% 
% We will use the AGORA resource (Magnusdottir et al., Nat Biotechnol. 2017 
% Jan;35(1):81-89) in this tutorial. AGORA can be downloaded from <https://www.vmh.life/#downloadview 
% https://www.vmh.life/#downloadview>.
% 
% As the host model, the global mouse reconstruction (Sigurdsson et al., 
% BMC Systems Biology (2010) 4:140) will be used. The mouse reconstruction can 
% be downloaded from <https://wwwen.uni.lu/content/download/72950/917509/file/Mus_musculus_iSS1393.zip 
% https://wwwen.uni.lu/content/download/72950/917509/file/Mus_musculus_iSS1393.zip>.
%% Initialize the COBRA Toolbox
%%
initCobraToolbox(false) %don't update the toolbox
%% 
% change directory to where the tutorial is located
%%
tutorialPath = fileparts(which('tutorial_hostMicrobeInteractions'));
cd(tutorialPath);
%% Prepare the models
% Download the mouse reconstruction.
%%
system('curl -O https://wwwen.uni.lu/content/download/72950/917509/file/Mus_musculus_iSS1393.zip')
currentDir=pwd;
unzip('Mus_musculus_iSS1393.zip',currentDir)
iSS1393=readCbModel('iSS1393.mat');
iSS1393=changeObjective(iSS1393,'biomass_mm_1_no_glygln');
% Define an AGORA model that can grow on the reduced diet and will be joined 
% with the mouse. 
system('curl -O https://www.vmh.life/files/reconstructions/AGORA/1.02/reconstructions/sbml/Escherichia_coli_str_K_12_substr_MG1655.xml')
model=readCbModel('Escherichia_coli_str_K_12_substr_MG1655.xml');
%% 
% NOTE: Since dietary nutrients can also rescue many lethal gene defects, 
% a diet reduced in nutrients will be used in this simulation to identify the 
% effect of the microbes. Not all AGORA models are be able to grow on the given 
% diet. Due to this, only microbes that can grow on the reduced diet can be used. 
% 
% Define the reduced diet.
%%
reducedDietConstraints={'EX_12dgr180[u]','-1','1000';'EX_26dap_M[u]','-1','1000';'EX_2dmmq8[u]','-1','1000';'EX_2obut[u]','-1','1000';'EX_3mop[u]','-1','1000';'EX_4abz[u]','-1','1000';'EX_4hbz[u]','-1','1000';'EX_5aop[u]','-1','1000';'EX_acmana[u]','-1','1000';'EX_adpcbl[u]','-1','1000';'EX_ala_L[u]','-0.3','1000';'EX_amet[u]','-1','1000';'EX_amylose300[u]','-0.001667','1000';'EX_anth[u]','-1','1000';'EX_arab_D[u]','-1','1000';'EX_arabinogal[u]','-0.00078','1000';'EX_arach[u]','-0.1743','1000';'EX_arachd[u]','-0.1743','1000';'EX_arg_L[u]','-0.15','1000';'EX_asn_L[u]','-0.225','1000';'EX_asp_L[u]','-0.225','1000';'EX_ca2[u]','-1','1000';'EX_cbl1[u]','-1','1000';'EX_chor[u]','-1','1000';'EX_chsterol[u]','-0.12908','1000';'EX_cl[u]','-1','1000';'EX_cobalt2[u]','-1','1000';'EX_cu2[u]','-1','1000';'EX_cys_L[u]','-0.3','1000';'EX_ddca[u]','-1','1000';'EX_dextran40[u]','-0.0063','1000';'EX_fald[u]','-1','1000';'EX_fe2[u]','-1','1000';'EX_fe3[u]','-1','1000';'EX_fru[u]','-1','1000';'EX_fum[u]','-1','1000';'EX_glc_D[u]','-1','1000';'EX_glcn[u]','-1','1000';'EX_gln_L[u]','-0.18','1000';'EX_glu_D[u]','-1','1000';'EX_glu_L[u]','-0.18','1000';'EX_gly[u]','-0.45','1000';'EX_glyc[u]','-1.162','1000';'EX_glyc3p[u]','-1','1000';'EX_h2[u]','-1','1000';'EX_h2s[u]','-1','1000';'EX_hdca[u]','-0.21788','1000';'EX_hdcea[u]','-0.21788','1000';'EX_his_L[u]','-0.15','1000';'EX_ile_L[u]','-0.15','1000';'EX_indole[u]','-1','1000';'EX_k[u]','-1','1000';'EX_lanost[u]','-1','1000';'EX_lcts[u]','-0.5','1000';'EX_leu_L[u]','-0.15','1000';'EX_levan1000[u]','-0.0005','1000';'EX_lnlc[u]','-0.19367','1000';'EX_lnlnca[u]','-0.19367','1000';'EX_lys_L[u]','-0.15','1000';'EX_mal_L[u]','-1','1000';'EX_malt[u]','-0.5','1000';'EX_met_L[u]','-0.18','1000';'EX_metsox_S_L[u]','-1','1000';'EX_mg2[u]','-1','1000';'EX_mn2[u]','-1','1000';'EX_mnl[u]','-1','1000';'EX_mqn7[u]','-1','1000';'EX_mqn8[u]','-1','1000';'EX_na1[u]','-1','1000';'EX_nh4[u]','-100','1000';'EX_nmn[u]','-1','1000';'EX_no2[u]','-1','1000';'EX_no3[u]','-1','1000';'EX_ocdca[u]','-0.19367','1000';'EX_ocdcea[u]','-0.19367','1000';'EX_octa[u]','-0.43575','1000';'EX_phe_L[u]','-0.099','1000';'EX_pheme[u]','-1','1000';'EX_pi[u]','-100','1000';'EX_pime[u]','-1','1000';'EX_pro_L[u]','-0.18','1000';'EX_ptrc[u]','-1','1000';'EX_pullulan1200[u]','-0.00042','1000';'EX_pydx5p[u]','-1','1000';'EX_q8[u]','-1','1000';'EX_raffin[u]','-0.1667','1000';'EX_rmn[u]','-1','1000';'EX_ser_L[u]','-0.3','1000';'EX_sheme[u]','-1','1000';'EX_so4[u]','-1','1000';'EX_spmd[u]','-1','1000';'EX_sucr[u]','-0.5','1000';'EX_thr_L[u]','-0.225','1000';'EX_trp_L[u]','-0.081','1000';'EX_ttdca[u]','-0.24899','1000';'EX_tyr_L[u]','-0.099','1000';'EX_val_L[u]','-0.18','1000';'EX_xan[u]','-1','1000';'EX_zn2[u]','-1','1000'};
%% 
% 
%%
models={};
nameTagsModels={};
bioID={};
models{1,1}=model;
bioID{1,1}=model.rxns(find(strncmp(model.rxns,'biomass',7)));
nameTagsModels{1,1}=strcat('Escherichia_coli_str_K_12_substr_MG1655_');
modelHost=iSS1393;
nameTagHost='Mouse_';
%% 
% Join the microbe with the mouse.
%%
[modelJoint] = createMultipleSpeciesModel(models,'nameTagsModels',nameTagsModels,'modelHost',modelHost,'nameTagHost',nameTagHost,'mergeGenesFlag',false);
%% 
% Define the coupling parameters.
%%
c=400;
u=0;
[modelJoint]=coupleRxnList2Rxn(modelJoint,modelJoint.rxns(strmatch(nameTagsModels{1,1},modelJoint.rxns)),strcat(nameTagsModels{1,1},bioID{1,1}),c,u);
[modelJoint]=coupleRxnList2Rxn(modelJoint,modelJoint.rxns(strmatch('Mouse_',modelJoint.rxns)),'Mouse_biomass_mm_1_no_glygln',c,u);
%% 
% Some changes need to be made to the host model to constrain the body fluids 
% compartment and the simulated intestinal barrier. This code needs to be adapted 
% to each host since the IDs of created body fluid reactions may differ.
%%
modelJoint = changeRxnBounds(modelJoint,modelJoint.rxns(strmatch('Mouse_EX_',modelJoint.rxns)),0,'l');
modelJoint=changeRxnBounds(modelJoint,'Mouse_EX_o2(e)b',-100,'l');
%% 
% Make unidirectional transport lumen -> host extracellular space
%%
modelJoint = changeRxnBounds(modelJoint,modelJoint.rxns(strmatch('Mouse_IEX',modelJoint.rxns)),0,'u');
%% 
% Exception for metabolites host secretes into mucus/ lumen
%%
modelJoint=changeRxnBounds(modelJoint,{'Mouse_IEX_chol[u]tr';'Mouse_IEX_galam[u]tr';'Mouse_IEX_fuc_L[u]tr';'Mouse_IEX_etha[u]tr';'Mouse_IEX_drib[u]tr';'Mouse_IEX_na1[u]tr';'Mouse_IEX_h[u]tr';'Mouse_IEX_tag_hs[u]tr';'Mouse_IEX_mag_hs[u]tr';'Mouse_IEX_lpchol_hs[u]tr';'Mouse_IEX_Rtotal3[u]tr';'Mouse_IEX_Rtotal2[u]tr';'Mouse_IEX_Rtotal[u]tr';'Mouse_IEX_dag_hs[u]tr';'Mouse_IEX_chsterol[u]tr';'Mouse_IEX_ha_pre1[u]tr';'Mouse_IEX_ha[u]tr';'Mouse_IEX_cspg_a[u]tr';'Mouse_IEX_cspg_b[u]tr';'Mouse_IEX_cspg_c[u]tr';'Mouse_IEX_cspg_d[u]tr';'Mouse_IEX_cspg_e[u]tr';'Mouse_IEX_hspg[u]tr';'Mouse_IEX_gchola[u]tr';'Mouse_IEX_tdchola[u]tr';'Mouse_IEX_tchola[u]tr';'Mouse_IEX_tdechola[u]tr'},1000,'u');
modelJoint=changeRxnBounds(modelJoint,{'Mouse_IEX_no[u]tr';'Mouse_IEX_n2m2nmasn[u]tr';'Mouse_IEX_n2m2nmasn[u]tr';'Mouse_IEX_s2l2n2m2m[u]tr';'Mouse_IEX_s2l2fn2m2masn[u]tr';'Mouse_IEX_s2l2n2m2masn[u]tr';'Mouse_IEX_f1a[u]tr';'Mouse_IEX_gncore1[u]tr';'Mouse_IEX_gncore2[u]tr';'Mouse_IEX_dsT_antigen[u]tr';'Mouse_IEX_sTn_antigen[u]tr';'Mouse_IEX_core8[u]tr';'Mouse_IEX_core7[u]tr';'Mouse_IEX_core5[u]tr';'Mouse_IEX_core4[u]tr';'Mouse_IEX_s2l2n2m2m[u]tr';'Mouse_IEX_oh1[u]tr';'Mouse_IEX_co2[u]tr';'Mouse_IEX_hco3[u]tr';'Mouse_IEX_ca2[u]tr';'Mouse_IEX_cl[u]tr';'Mouse_IEX_k[u]tr'},1000,'u');
%% 
% Implement the reduced diet.
%%
modelJoint=useDiet(modelJoint,reducedDietConstraints);
%% 
% Run the prediction of rescued genes. This will take some time.
%%
[OptSolKO,OptSolWT,OptSolRatio,RescuedGenes,fluxesKO]=computeRescuedGenes('modelJoint',modelJoint,'Rxn1','Mouse_biomass_mm_1_no_glygln','Rxn2',char(strcat(nameTagsModels{1,1},string(bioID{1,1}))),'nameTag1','Mouse_','nameTag2',nameTagsModels{1,1},'OriModel1',iSS1393,'OriModel2',model);
%% 
% Show the mouse genes that caused a lethal phenotype when deleted in germfree 
% mouse but not in presence of the microbe:
%%
RescuedGenes.Mouse_biomass_mm_1_no_glygln.RescuedLethalGenes
%% 
% The gene identifiers are NCBI Gene IDs and can be looked up to find the 
% corresponding human genes and associated inborn errors of metabolism (IEMs). 
% The reactions associated with the IEMs can subsequently be browsed at https://www.vmh.life/#diseases. 
% For example, the gene 22247.1 encodes UMP synthase and its deletion can be resuced 
% by the presence of E. coli. The corresponding IEM in human is orotic aciduria 
% (https://www.vmh.life/#disease/OROA).
% 
% We will now identify the mechanisms of rescued KO phenotypes. Metabolites 
% secreted by each species into the lumen may be taken up by the joined species 
% and provide the metabolites that are essential due to the gene defect. To find 
% the lumen exchange reactions of E. coli:
%%
microbeExchanges=find(strncmp(modelJoint.rxns,strcat(nameTagsModels{1,1},'IEX'),length(strcat(nameTagsModels{1,1},'IEX'))));
%% 
% Now, let us find out which of the metabolites secreted by E.coli was essential 
% for rescuing the defect in mouse UMP synthase. 
%%
[model,hasEffect,constrRxnNames,deletedGenes] = deleteModelGenes(modelHost,'22247.1');
constrRxnNames = strcat(nameTagHost,constrRxnNames);
modelJoint=changeRxnBounds(modelJoint,constrRxnNames,0,'b');
modelJoint=changeObjective(modelJoint,'Mouse_biomass_mm_1_no_glygln');
modelJoint=changeRxnBounds(modelJoint,strcat(nameTagHost,'ATPM'),0,'l');
modelJoint=changeRxnBounds(modelJoint,strcat(nameTagsModels{1},'DM_atp_c_'),0,'l');
%% 
% To print out the E. coli exchange that had to carry flux to rescue the 
% orotic aciduria-like mouse phenotype, use the following code:
%%
for i=1:length(microbeExchanges)
    if isempty(strfind(modelJoint.rxns{microbeExchanges(i)},'biomass'))
        % prevent secretion flux through the exchanges one by one while predicting mouse biomass
        modelJointDel=changeRxnBounds(modelJoint,modelJoint.rxns{microbeExchanges(i)},0,'u');
        solution=solveCobraLP(modelJointDel);
        if solution.obj<0.0000000001
            fprintf('%s \n',modelJoint.rxns{microbeExchanges(i)},' is essential for rescuing orotic aciduria.')
        end
    end
end
%% 
% Can you explain what you observe? You can look up the metabolite ID of 
% the respective exchange at <https://www.vmh.life. https://www.vmh.life.> Hint: 
% Check the description of orotic aciduria at <https://www.vmh.life/#disease/OROA. 
% https://www.vmh.life/#disease/OROA.> Follow the external link to OMIM (Online 
% Mendelian Inheritance in Man) to find more information.