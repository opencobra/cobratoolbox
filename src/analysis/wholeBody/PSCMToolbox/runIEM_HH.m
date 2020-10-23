% This script predicts known biomarker metabolites in
% different biofluid compartments (urine, blood, csf) of the whole-body
% model for 57 inborn-errors of metabolism (IEMs).
% The meaning of the abbreviations for metabolites and IEMs used in this
% script can be found at www.vmh.life.
% The supported model options are 'male', 'female', and 'Recon3D'. Please
% define those using the variable 'sex' (e.g., sex = 'male').
%
% Ines Thiele 2018 - 2019

if ~exist('useSolveCobraLPCPLEX','var')
    global useSolveCobraLPCPLEX
    useSolveCobraLPCPLEX = 0;
end

if ~exist('resultsPath','var')
    global resultsPath
    resultsPath = which('MethodSection3.mlx');
    resultsPath = strrep(resultsPath,'MethodSection3.mlx',['Results' filesep]);
end

if strcmp(modelName,'Harvey')
    %load file corresponding to fileName
    male = loadPSCMfile(modelName);
    
    %standardPhysiolDefaultParameters needs to know what sex it is dealing
    %with
    sex  = male.sex;
    standardPhysiolDefaultParameters;
    
    male = physiologicalConstraintsHMDBbased(male,IndividualParameters);
    EUAverageDietNew;
    male = setDietConstraints(male, Diet);
    model = male;
    modelO = model;
elseif strcmp(modelName,'Harvetta')
    %load file corresponding to fileName
    female = loadPSCMfile(modelName);
    
    %standardPhysiolDefaultParameters needs to know what sex it is dealing
    %with
    sex  = female.sex;
    standardPhysiolDefaultParameters;
    
    female = physiologicalConstraintsHMDBbased(female,IndividualParameters);
    EUAverageDietNew;
    female = setDietConstraints(female, Diet);
    model = female;
    modelO = model;
elseif strcmp(modelName,'Recon3D')
    if useSolveCobraLPCPLEX
        % load Recon3D* and
        load Recon3D_Harvey_Used_in_Script_120502
    else
        modelConsistent = model;
    end
    %makes modifications necessary to adjust Recon3D* for this script
    model = modelConsistent;
    model.rxns = regexprep(model.rxns,'\(e\)','[e]');
    model.rxns = strcat('_',model.rxns);
    model.rxns = regexprep(model.rxns,'_EX_','EX_');
    % add new compartment to Recon
    [model] = createModelNewCompartment(model,'e','u','urine');
    model.rxns = regexprep(model.rxns,'\[e\]_\[u\]','_tr_\[u\]');
    % add exchange reactions for the new [u] metabolites
    U = model.mets(~cellfun(@isempty,strfind(model.mets,'[u]')));
    for i = 1 : length(U)
        model = addExchangeRxn(model,U(i),0,1000);
    end
    
    % create diet reactions
    model.rxns = regexprep(model.rxns,'\[e\]','[d]');
    model.mets = regexprep(model.mets,'\[e\]','[d]');
    EX = model.rxns(~cellfun(@isempty,strfind(model.rxns,'EX_')));
    D = model.rxns(~cellfun(@isempty,strfind(model.rxns,'[d]')));
    EX_D = intersect(EX,D);
    model.rxns(ismember(model.rxns,EX_D)) = strcat('Diet_', model.rxns(ismember(model.rxns,EX_D)));
    % apply diet constraints
    model = setDietConstraints(model);
    % only force lower constraints of diet as no fecal outlet
    EX_D = model.rxns(strmatch('Diet_',model.rxns));
    model.ub(ismember(model.rxns,EX_D)) = 0;
    model.lb(ismember(model.rxns,'Diet_EX_o2[d]')) = -1000;
    
    if useSolveCobraLPCPLEX
        model.A = model.S;
    else
        if isfield(model,'A')
            model = rmfield(model,'A');
        end
    end
    model.rxns(ismember(model.rxns,'_biomass_maintenance')) = {'Whole_body_objective_rxn'};
    model.lb(ismember(model.rxns,'Whole_body_objective_rxn')) = 1;
    model.ub(ismember(model.rxns,'Whole_body_objective_rxn')) = 1;
    modelO = model;
end
cnt = 1;
minRxnsFluxHealthy = 1;%0.9;

%% integrate microbes into the whole-body reconstructions
% load microbe model
microbiome = 0;
set = 0;
if microbiome == 1
    files = {'SRS011239'};
    if set == 1
        S= load(strcat('/microbiota_model_samp_',files{1},'.mat'));
    end
    microbiota_model = S.microbiota_model;
    microbiota_model.rxns = strcat('Micro_',microbiota_model.rxns);
    modelHM = combineHarveyMicrotiota(model,microbiota_model,400);
    
    modelHM = changeRxnBounds(modelHM,'Whole_body_objective_rxn',1,'b');
    modelHMO = modelHM;
    % now set all strains to 0 but 1
    %Bacteroides_thetaiotaomicron_VPI_5482_biomass[c]
    % modelHM.S = modelHM.A;
    % modelHM.S(:,strmatch('communityBiomass',modelHM.rxns))=0;
    % modelHM.S(strmatch('Bacteroides_thetaiotaomicron_VPI_5482_biomass[c]',modelHM.mets),strmatch('communityBiomass',modelHM.rxns))=-1;
    
    % modelHM.S(strmatch('microbiota_LI_biomass[luM]',modelHM.mets),strmatch('communityBiomass',modelHM.rxns))=1;
    % modelHM.A = modelHM.S;
    
    modelHM.lb(ismember(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]'))=0.1; %
    modelHM.ub(ismember(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]'))=1; %
    
    model = modelHM;
end

%% set unified reaction constraints -- they are duplicated again in individual scripts

R = {'_ARGSL';'_GACMTRc';'_FUM';'_FUMm';'_HMR_7698';'_UAG4E';'_UDPG4E';'_GALT'; '_G6PDH2c';'_G6PDH2r';'_G6PDH2rer';...
    '_GLUTCOADHm';'_r0541'; '_ACOAD8m';'_RE2410C';'_RE2410N'};
RxnsAll2 = '';
for i = 1: length(R)
    RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{i})));
    RxnsAll2 =[RxnsAll2;RxnsAll];
end

%excluded reactions
R2 = {'_FUMt';'_FUMAC';'_FUMS';'BBB'};
RxnsAll4 = '';
for i = 1: length(R2)
    RxnsAll3 = model.rxns(~cellfun(@isempty,strfind(model.rxns,R2{i})));
    RxnsAll4 =[RxnsAll4;RxnsAll3];
end
RxnsAll4 = unique(RxnsAll4);
IEMRxns = setdiff(RxnsAll2,RxnsAll4);
RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_')));
if ~isempty(RxnMic)
    RxnMic
end
IEMRxns = setdiff(IEMRxns,RxnMic);
% set ARGSL to be irreversible
model.lb(ismember(model.rxns,IEMRxns)) = 0;

R2 = {'_r0784';'_r0463'};
RxnsAll2 = '';
for i = 1: length(R2)
    RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R2{i})));
    RxnsAll2 =[RxnsAll2;RxnsAll];
end
X = unique(RxnsAll2);
RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_')));
if ~isempty(RxnMic)
    RxnMic
end
X = setdiff(X,RxnMic);
model.lb(ismember(model.rxns,X)) = 0;
model.ub(ismember(model.rxns,X)) = 0;

%%%
Rnew = {'BileDuct_EX_12dhchol[bd]_[luSI]';'BileDuct_EX_3dhcdchol[bd]_[luSI]';'BileDuct_EX_3dhchol[bd]_[luSI]';'BileDuct_EX_3dhdchol[bd]_[luSI]';'BileDuct_EX_3dhlchol[bd]_[luSI]';'BileDuct_EX_7dhcdchol[bd]_[luSI]';'BileDuct_EX_7dhchol[bd]_[luSI]';'BileDuct_EX_cdca24g[bd]_[luSI]';'BileDuct_EX_cdca3g[bd]_[luSI]';'BileDuct_EX_cholate[bd]_[luSI]';'BileDuct_EX_dca24g[bd]_[luSI]';'BileDuct_EX_dca3g[bd]_[luSI]';'BileDuct_EX_dchac[bd]_[luSI]';'BileDuct_EX_dgchol[bd]_[luSI]';'BileDuct_EX_gchola[bd]_[luSI]';'BileDuct_EX_hca24g[bd]_[luSI]';'BileDuct_EX_hca6g[bd]_[luSI]';'BileDuct_EX_hdca24g[bd]_[luSI]';'BileDuct_EX_hdca6g[bd]_[luSI]';'BileDuct_EX_hyochol[bd]_[luSI]';'BileDuct_EX_icdchol[bd]_[luSI]';'BileDuct_EX_isochol[bd]_[luSI]';'BileDuct_EX_lca24g[bd]_[luSI]';'BileDuct_EX_tchola[bd]_[luSI]';'BileDuct_EX_tdchola[bd]_[luSI]';'BileDuct_EX_tdechola[bd]_[luSI]';'BileDuct_EX_thyochol[bd]_[luSI]';'BileDuct_EX_uchol[bd]_[luSI]'};
model.ub(ismember(model.rxns,Rnew)) = 100;

modelO = model;
if 1
    %% gene ID: 3034.1 - Histidinemia HIS
    model = modelO;
    R = '_HISD';
    RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R)));
    % exclude _HISDC reactions
    RxnsAll2 = model.rxns(~cellfun(@isempty,strfind(model.rxns,'_HISDC')));
    IEMRxns = setdiff(RxnsAll,RxnsAll2);
    RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_')));
    IEMRxns = setdiff(IEMRxns,RxnMic);
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'hista[bc]');
        model = addDemandReaction(model, 'his_L[bc]');
        
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        
        BiomarkerRxns ={'EX_hista[u]'	'Increased (blood/urine)'
            'DM_hista[bc]'	'Increased (blood/urine)'
            'EX_im4ac[u]'	'Increased (urine)'
            'EX_his_L[u]'	'Increased (blood/urine)'
            'DM_his_L[bc]'	'Increased (blood/urine)'
            };
    else
        BiomarkerRxns ={'EX_hista[u]'	'Increased (blood/urine)'
            'EX_im4ac[u]'	'Increased (urine)'
            'EX_his_L[u]'	'Increased (blood/urine)'
            };
    end
    [IEMSol_HIS] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% %% gene ID: 2628.1 % AGAT def
    model = modelO;
    
    R = '_GLYAMDTRc';
    IEMRxns = model.rxns(~cellfun(@isempty,strfind(model.rxns,R)));
    RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    % set GACMTRc reaction, which converts gudac into creat to irreversible
    X = model.rxns(~cellfun(@isempty,strfind(model.rxns,'_GACMTRc')));
    model.lb(ismember(model.rxns,X)) = 0;
    
    
    BiomarkerRxns = {'EX_creat[u]' 'Decreased (urine)'
        'EX_gudac[u]' 'Decreased (urine)' %
        };
    
    [IEMSol_AGAT] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% %% gene ID: 383.1 % Arginase def ARG
    if 1
        model = modelO;
        
        R = '_ARGN';
        IEMRxns = model.rxns(~cellfun(@isempty,strfind(model.rxns,R)));
        RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
        IEMRxns = setdiff(IEMRxns,RxnMic);
        % set GACMTRc reaction, which converts gudac into creat to irreversible
        X = model.rxns(~cellfun(@isempty,strfind(model.rxns,'_GACMTRc')));
        RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
        X = setdiff(X,RxnMic);
        model.lb(ismember(model.rxns,X)) = 0;
        
        if ~strcmp(modelName,'Recon3D')
            % add demand reactions to blood compartment for those biomarkers reported for blood
            model = addDemandReaction(model, 'arg_L[bc]');
            model = addDemandReaction(model, 'creat[bc]');
            model = addDemandReaction(model, 'gudac[bc]');
            if useSolveCobraLPCPLEX
                model.A = model.S;
            else
                if isfield(model,'A')
                    model = rmfield(model,'A');
                end
            end
            BiomarkerRxns = {
                'EX_argsuc[u]' 'Increased (urine)'
                'EX_orot[u]' 'Increased (urine)'
                'EX_ura[u]' 'Increased  (urine)'
                'DM_creat[bc]' 'Increased (blood)'
                'DM_arg_L[bc]' 'Increased (blood)'
                'DM_gudac[bc]' 'Increased (blood)'
                };
        else
            BiomarkerRxns = {
                'EX_argsuc[u]' 'Increased (urine)'
                'EX_orot[u]' 'Increased (urine)'
                'EX_ura[u]' 'Increased  (urine)'
                'EX_creat[u]' 'Increased (blood)'
                'EX_arg_L[u]' 'Increased (blood)'
                'EX_gudac[u]' 'Increased (blood)'
                };
        end
        [IEMSol_ARG] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    end
    
    %% %% gene ID: 1373.1 % CPS1 'Carbamoyl phosphate synthetase I deficiency'
    model = modelO;
    
    R = {'_CBPSam';'_r0034'};
    RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{1})));
    RxnsAll2 = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{2})));
    IEMRxns = union(RxnsAll,RxnsAll2);
    RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'gln_L[bc]');
        model = addDemandReaction(model, 'citr_L[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {'EX_lys_L[u]' 'Increased (urine)'
            'EX_gly[u]' 'Increased (urine)'
            'EX_ura[u]' 'Increased (urine)'
            'EX_5oxpro[u]' 'Increased (urine)'
            'DM_citr_L[bc]' 'Decreased (blood)'
            'DM_gln_L[bc]' 'Increased (blood)'
            };
    else
        
        BiomarkerRxns = {'EX_lys_L[u]' 'Increased (urine)'
            'EX_gly[u]' 'Increased (urine)'
            'EX_ura[u]' 'Increased (urine)'
            'EX_5oxpro[u]' 'Increased (urine)'
            'EX_citr_L[u]' 'Decreased (blood)'
            'EX_gln_L[u]' 'Increased (blood)'
            };
    end
    [IEMSol_CPS1] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% gene ID: 549,1 % 3MGA 3-Methylglutaconic Aciduria Type I
    model = modelO;
    
    R = {'_MGCHrm'};
    IEMRxns = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{1})));
    RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    BiomarkerRxns = {'EX_3ivcrn[u]' 'Increased (urine)'
        % 'EX_3mglutac[u]' 'Increased (urine)'
        % 'EX_3mglutr[u]' 'Increased (urine)' % cannot be produced in healthy
        % stae
        };
    [IEMSol_3MGA] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% 95.1 AMA1 Aminoacylase 1 Deficiency
    model = modelO;
    
    R = {'_ACODA';'_RE2640C'};
    RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{1})));
    RxnsAll2 = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{2})));
    IEMRxns = union(RxnsAll,RxnsAll2);
    RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    BiomarkerRxns = {
        'EX_acglu[u]'	'Increased (urine)'
        'EX_acgly[u]'	'Increased (urine)'
        };
    [IEMSol_AMA1] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% 1644.1 Aromatic L-amino acid decarboxylase deficiency
    model = modelO;
    
    R = {'_3HLYTCL';'_3HXKYNDCL';'_5HLTDL';'_5HXKYNDCL';'_LTDCL';'_PHYCBOXL';'_TYRCBOX'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{i})));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, '34dhphe[bc]');
        model = addDemandReaction(model, '5htrp[bc]');
        model = addDemandReaction(model, 'adrnl[bc]');
        model = addDemandReaction(model, 'CE2176[bc]');
        model = addDemandReaction(model, 'nrpphr[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {'EX_34dhphe[u]'	'Increased (urine/blood)'
            'DM_34dhphe[bc]'	'Increased (urine/blood)'
            'EX_5htrp[u]'	'Increased (urine/blood)'
            'DM_5htrp[bc]'	'Increased (urine/blood)'
            'DM_adrnl[bc]'	'Decreased (blood)'
            'EX_dopa[u]'	'Increased (urine)'
            'EX_CE2176[u]'	'Increased (urine/blood)'
            'DM_CE2176[bc]'	'Increased (urine/blood)'
            'DM_nrpphr[bc]'	'Decreased (blood)'
            'EX_3moxtyr[u]'	'Increased (urine)'
            };
    else
        
        BiomarkerRxns = {'EX_34dhphe[u]'	'Increased (urine/blood)'
            'EX_5htrp[u]'	'Increased (urine/blood)'
            'EX_adrnl[u]'	'Decreased (blood)'
            'EX_dopa[u]'	'Increased (urine)'
            'EX_CE2176[u]'	'Increased (urine/blood)'
            'EX_nrpphr[u]'	'Decreased (blood)'
            'EX_3moxtyr[u]'	'Increased (urine)'
            };
    end
    
    [IEMSol_AADC] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '56922.1' '3-methylcrotonyl coA carboxylase deficiency'
    model = modelO;
    
    R = {'_MCCCrm';'_RE2453M';'_RE2454M'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{i})));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    BiomarkerRxns = {'EX_3ivcrn[u]'	'Increased (urine)'
        %   'EX_acac[u]'	'Increased (urine)' % ketone bodies were not mentioned
        %   here: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC1182108/
        %  'EX_acetone[u]'	'Increased (urine)'
        % 'EX_bhb[u]'	'Increased (urine)'
        'EX_CE2026[u]'	'Increased (urine)' % 3-methylcrotonylglycine
        'EX_3hivac[u]'	'Increased (urine)'
        };
    [IEMSol_3MCC] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '1589.1' CYP21D	'21-hydroxylase deficiency'
    if 1
        model = modelO;
        
        R = {'_P45021A1r';'_P45021A2r';'_RE2155R';'_21HPRGNLONE';'_HMR_1940';'_HMR_1948';'_HMR_1988';'_HMR_1990';'_HMR_1992';'_HMR_2007'};
        RxnsAll2 = '';
        for i = 1: length(R)
            RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{i})));
            RxnsAll2 =[RxnsAll2;RxnsAll];
        end
        IEMRxns = unique(RxnsAll2);
        RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
        IEMRxns = setdiff(IEMRxns,RxnMic);
        
        if ~strcmp(modelName,'Recon3D')
            % add demand reactions to blood compartment for those biomarkers reported for blood
            model = addDemandReaction(model, 'aldstrn[bc]');
            model = addDemandReaction(model, 'crtsl[bc]');
            model = addDemandReaction(model, 'prgstrn[bc]');
            model = addDemandReaction(model, '17ahprgnlone[bc]');
            model = addDemandReaction(model, '17ahprgstrn[bc]');
            model = addDemandReaction(model, 'M00603[bc]');
            model = addDemandReaction(model, 'andrstndn[bc]');
            model = addDemandReaction(model, 'andrstrn[bc]');
            model = addDemandReaction(model, 'dhea[bc]');
            model = addDemandReaction(model, 'C05284[bc]');
            model = addDemandReaction(model, 'CE2211[bc]');
            if useSolveCobraLPCPLEX
                model.A = model.S;
            else
                if isfield(model,'A')
                    model = rmfield(model,'A');
                end
            end
            BiomarkerRxns = {'DM_aldstrn[bc]'	'Increased (blood)'%17-Ketotestosterone
                'DM_crtsl[bc]'	'Decreased (blood)' %cortisol
                'DM_prgstrn[bc]'	'Increased (blood)'  %Progesterone
                'DM_andrstndn[bc]'	'Increased (blood)' %17-Ketotestosterone
                'DM_andrstrn[bc]' 'Increased (blood)' % Androsterone,in male
                'DM_dhea[bc]'	'Increased (blood)' %Dehydroepiandrosterone unchanged in this study: PMID: 28472487
                };
        else
            BiomarkerRxns = {'EX_aldstrn[u]'	'Increased (blood)'%17-Ketotestosterone
                'EX_crtsl[u]'	'Decreased (blood)' %cortisol
                'EX_prgstrn[u]'	'Increased (blood)'  %Progesterone
                'EX_andrstndn[u]'	'Increased (blood)' %17-Ketotestosterone
                'EX_andrstrn[u]' 'Increased (blood)' % Androsterone,in male
                'EX_dhea[u]'	'Increased (blood)' %Dehydroepiandrosterone unchanged in this study: PMID: 28472487
                };
        end
        [IEMSol_CYP21D] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    end
    %% '53630.1' Autosomal Dominant Hypercarotenemia And Vitamin A Deficiency
    model = modelO;
    
    R = {'_BCDO'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{i})));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'caro[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {'DM_caro[bc]'	'Increased (blood)'
            };
    else
        BiomarkerRxns = {'EX_caro[u]'	'Increased (blood)'
            };
    end
    [IEMSol_HYCARO] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '686.1' BTD Biotinidase Deficiency
    if 1
        model = modelO;
        
        % https://www.nature.com/articles/gim201784: Biochemically, untreated individuals may exhibit
        % metabolic ketoacidosis, lactic acidosis, and/or hyperammonemia.(PMID: 3930841)
        % Other metabolic abnormalities are more variable and may include elevated excretion
        % of 3-hydroxyisovaleric, lactic, and 3-hydroxypropionic acids and 3-methylcrotonylglycine
        % by urine organic acid analysis, as well as mildly elevated 3-hydroxyisovalerylcarnitine
        % (C5-OH) by plasma acylcarnitine analysis.(PMID: 6441143) These metabolic abnormalities are variable,
        % and affected children, whether symptomatic or asymptomatic, do not always
        % exhibit ketoacidosis or organic aciduria.(PMID: 3930841)
        
        R = {'_BTND1';'_BTND1n';'_BTNDe';'_BTNDm';...
            '_ACCOACm';'_ACCOAC';'_PCm';'_MCCCrm';'_RE2453M';'_RE2454M';'_PPCOACm'
            };
        RxnsAll2 = '';
        for i = 1: length(R)
            RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{i})));
            RxnsAll2 =[RxnsAll2;RxnsAll];
        end
        IEMRxns = unique(RxnsAll2);
        RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
        IEMRxns = setdiff(IEMRxns,RxnMic);
        
        if ~strcmp(modelName,'Recon3D')
            % add demand reactions to blood compartment for those biomarkers reported for blood
            model = addDemandReaction(model, 'acac[bc]');
            model = addDemandReaction(model, 'acetone[bc]');
            model = addDemandReaction(model, 'bhb[bc]');
            model = addDemandReaction(model, '3ivcrn[bc]');
            if useSolveCobraLPCPLEX
                model.A = model.S;
            else
                if isfield(model,'A')
                    model = rmfield(model,'A');
                end
            end
            BiomarkerRxns = {%'DM_3ivcrn[bc]'	'Increased (blood)' %https://www.nature.com/articles/gim201784
               'DM_acac[bc]'	'Increased (blood)'
               'DM_acetone[bc]'	'Increased (blood)'
                'DM_bhb[bc]'	'Increased (blood)'
                'EX_lac_L[u]'	'Increased (urine)'
                'EX_nh4[u]'	'Increased (urine)'
                'EX_3hpp[u]'	'Increased (urine)'
                'EX_CE2026[u]'	'Increased (urine)'
                'EX_2mcit[u]'	'Increased (urine)'
                };
        else
            BiomarkerRxns = {'EX_3ivcrn[u]'	'Increased (urine)'
                'EX_acac[u]'	'Increased (blood)'
                'EX_acetone[u]'	'Increased (blood)'
                'EX_bhb[u]'	'Increased (blood)'
                'EX_lac_L[u]'	'Increased (urine)'
                'EX_nh4[u]'	'Increased (urine)'
                'EX_3hpp[u]'	'Increased (urine)'
                'EX_CE2026[u]'	'Increased (urine)'
                'EX_2mcit[u]'	'Increased (urine)'
                };
        end
        
        [IEMSol_BTD] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy,[],0.25);
        
    end
    %% '5264.1' CRFD Classic Refsum Disease
    if 0
        model = modelO;
        R = {'_PHYHx';'_RE3066X'};
        RxnsAll2 = '';
        for i = 1: length(R)
            RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
            RxnsAll2 =[RxnsAll2;RxnsAll];
        end
        IEMRxns = unique(RxnsAll2);
        RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;
        IEMRxns = setdiff(IEMRxns,RxnMic);
        if ~strcmp(modelName,'Recon3D')
            % add demand reactions to blood compartment for those biomarkers reported for blood
            model = addDemandReaction(model, 'phyt[bc]');
            model = addDemandReaction(model, 'prist[bc]');
            if useSolveCobraLPCPLEX
                model.A = model.S;
            else
                if isfield(model,'A')
                    model = rmfield(model,'A');
                end
            end
            BiomarkerRxns = {'DM_phyt[bc]'   'Increased (blood)'
                'DM_prist[bc]'   'Decreased (blood)'
                };
        else
            BiomarkerRxns = {'EX_phyt[u]'   'Increased (blood)'
                'EX_prist[u]'   'Decreased (blood)'
                };
        end
        [IEMSol_CRFD] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    end
    
    %% '1538.1' STAR Congenital Lipoid Adrenal Hyperplasia (Clah)/ Star Deficiency
    model = modelO;
    
    R = {'_P45011A1m';'_HMR_1928';'_HMR_1929';'_HMR_1932';'_HMR_1934';'_HMR_1935'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{i})));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'crtsl[bc]');
        model = addDemandReaction(model, 'crtstrn[bc]');
        model = addDemandReaction(model, '17ahprgstrn[bc]');
        model = addDemandReaction(model, 'andrstndn[bc]');
        model = addDemandReaction(model, 'dhea[bc]');
        model = addDemandReaction(model, '11docrtstrn[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {'DM_crtsl[bc]'	'Decreased (blood)'
            'DM_crtstrn[bc]'	'Decreased (blood)'
            'DM_andrstndn[bc]'	'Decreased (blood)'
            'DM_dhea[bc]'	'Decreased (blood)'
            'DM_11docrtstrn[bc]'	'Decreased (blood)'
            };
    else
        BiomarkerRxns = {'EX_crtsl[u]'	'Decreased (blood)'
            'EX_crtstrn[u]'	'Decreased (blood)'
            'EX_andrstndn[u]'	'Decreased (blood)'
            'EX_dhea[u]'	'Decreased (blood)'
            'EX_11docrtstrn[u]'	'Decreased (blood)'
            };
    end
    
    [IEMSol_STAR] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '1585.1' CMO1 Corticosterone Methyloxidase Type I Deficiency
    model = modelO;
    
    R = {'_P45011B21m'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{i})));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'aldstrn[bc]');
        model = addDemandReaction(model, 'M00429[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {'DM_aldstrn[bc]'	'Decreased (Not detectable, blood)'
            };
    else
        BiomarkerRxns = {'EX_aldstrn[u]'	'Decreased (Not detectable, blood)'
            };
    end
    [IEMSol_CMO1] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '1716.1' DGK Deoxyguanosine Kinase Deficiency
    if 1
        model = modelO;
        
        R = {'_r0456'};
        RxnsAll2 = '';
        for i = 1: length(R)
            RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{i})));
            RxnsAll2 =[RxnsAll2;RxnsAll];
        end
        IEMRxns = unique(RxnsAll2);
        RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
        IEMRxns = setdiff(IEMRxns,RxnMic);
        
        if ~strcmp(modelName,'Recon3D')
            % add demand reactions to blood compartment for those biomarkers reported for blood
            model = addDemandReaction(model, 'lac_L[bc]');
            if useSolveCobraLPCPLEX
                model.A = model.S;
            else
                if isfield(model,'A')
                    model = rmfield(model,'A');
                end
            end
            BiomarkerRxns = {
                'DM_lac_L[bc]'	'Increased (blood)'
                };
        else
            BiomarkerRxns = {
                'EX_lac_L[u]'	'Increased (blood)'
                };
        end
        [IEMSol_DGK] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    end
    %% '1807.1 'DPYR Dihydropyrimidinuria
    model = modelO;
    
    R = {'_DHPM2'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{i})));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    BiomarkerRxns = {
        'EX_thym[u]'	'Increased (urine)'
        'EX_ura[u]'	'Increased (urine)'
        'EX_56dura[u]'	'Increased (urine)'
        'EX_56dthm[u]'	'Increased (urine)'
        };
    [IEMSol_DPYR] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '3931.1' FED Fish-Eye Disease/ Lcat Deficiency
    if 1
        model = modelO;
        
        R = {'_HMR_0634';'_LCAT1e';'_LCAT10e';'_LCAT11e';'_LCAT12e';'_LCAT13e';'_LCAT14e';'_LCAT15e';'_LCAT16e';'_LCAT17e';'_LCAT18e';'_LCAT19e';...
            '_LCAT2e';'_LCAT20e';'_LCAT21e';'_LCAT22e';'_LCAT23e';'_LCAT24e';'_LCAT25e';'_LCAT26e';'_LCAT27e';'_LCAT28e';'_LCAT29e';...
            '_LCAT3e';'_LCAT30e';'_LCAT31e';'_LCAT32e';'_LCAT33e';'_LCAT34e';'_LCAT35e';'_LCAT36e';'_LCAT37e';'_LCAT38e';'_LCAT39e';...
            '_LCAT4e';'_LCAT40e';'_LCAT41e';'_LCAT42e';'_LCAT43e';'_LCAT44e';'_LCAT45e';'_LCAT46e';'_LCAT47e';'_LCAT48e';'_LCAT49e';...
            '_LCAT5e';'_LCAT50e';'_LCAT51e';'_LCAT52e';'_LCAT53e';'_LCAT54e';'_LCAT55e';'_LCAT56e';'_LCAT57e';'_LCAT58e';'_LCAT59e'
            };
        RxnsAll2 = '';
        for i = 1: length(R)
            RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{i})));
            RxnsAll2 =[RxnsAll2;RxnsAll];
        end
        IEMRxns = unique(RxnsAll2);
        RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
        IEMRxns = setdiff(IEMRxns,RxnMic);
        if ~strcmp(modelName,'Recon3D')
            % add demand reactions to blood compartment for those biomarkers reported for blood
            model = addDemandReaction(model, 'chsterol[bc]');
            model = addDemandReaction(model, 'tag_hs[bc]');
            if useSolveCobraLPCPLEX
                model.A = model.S;
            else
                if isfield(model,'A')
                    model = rmfield(model,'A');
                end
            end
            BiomarkerRxns = {
                'DM_chsterol[bc]'	'Decreased (blood)' %PMID: 8675648: "showed a highly significant reduction of HDL-cholesterol"
                'DM_tag_hs[bc]'	'Increased (blood)' % PMID: 3141686: "They had fasting hypertriglyceridaemia." We are not modeling fasting condition
                };
        else
            BiomarkerRxns = {
                'EX_chsterol[u]'	'Decreased (blood)' %PMID: 8675648: "showed a highly significant reduction of HDL-cholesterol"
                'EX_tag_hs[u]'	'Increased (blood)' % PMID: 3141686: "They had fasting hypertriglyceridaemia." We are not modeling fasting condition
                };
        end
        [IEMSol_FED] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    end
    %% '3795.1' EF Fructosuria(Essential Fructosuria)
    model = modelO;
    
    R = {'_HMR_8761';'_HMR_9800';'_KHK';'_KHK2';'_KHK3'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{i})));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    BiomarkerRxns = {
        'EX_fru[u]'	'Increased (urine)'
        };
    [IEMSol_EF] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '10841.1' FIGLU Glutamate Formiminotransferase Deficiency
    model = modelO;
    
    R = {'_FORTHFC';'_GluForTx';'_HMR_9726'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{i})));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    BiomarkerRxns = {
        'EX_forglu[u]'  'Increased (urine)'
        };
    [IEMSol_FIGLU] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '2639.1' GA1 Glutaric Acidemia Type I.
    model = modelO;
    
    R = {'_GLUTCOADHm';'_r0541'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{i})));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    model.lb(ismember(model.rxns,IEMRxns)) = 0;
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'c5dc[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_c5dc[u]'	'Increased (blood/urine)'
            'DM_c5dc[bc]'	'Increased (blood/urine)'
            };
    else
        BiomarkerRxns = {
            'EX_c5dc[u]'	'Increased (blood/urine)'
            };
    end
    [IEMSol_GA1] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '2108.1' GA2 Glutaric Acidemia Type II
    model = modelO;
    
    R = {'_ETF';'_FADH2ETC'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{i})));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'c10crn[bc]');
        model = addDemandReaction(model, 'c4crn[bc]');
        model = addDemandReaction(model, 'ddeccrn[bc]');
        model = addDemandReaction(model, 'ttdcrn[bc]');
        model = addDemandReaction(model, 'pmtcrn[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'DM_c10crn[bc]'	'Increased (blood)'
            'DM_c4crn[bc]'	'Increased (blood)'
            'DM_ddeccrn[bc]'	'Increased (blood)'
            'DM_ttdcrn[bc]'	'Increased (blood)'
            'DM_pmtcrn[bc]'	'Increased (blood)'
            'EX_4hpro_LT[u]'	'Increased (urine)'
            'EX_3hivac[u]'	'Increased (urine)'
            'EX_CE4970[u]'	'Increased (urine)'
            'EX_CE4969[u]'	'Increased (urine)'
            'EX_CE4968[u]'	'Increased (urine)'
            'EX_ethmalac[u]'	'Increased (urine)'
            'EX_adpac[u]'	'Increased (urine)'
            'EX_subeac[u]'	'Increased (urine)'
            'EX_sebacid[u]'	'Increased (urine)'
            'EX_pro_L[u]'	'Increased (urine)'
            };
    else
        BiomarkerRxns = {
            'EX_c10crn[u]'	'Increased (blood)'
            'EX_c4crn[u]'	'Increased (blood)'
            'EX_ddeccrn[u]'	'Increased (blood)'
            'EX_ttdcrn[u]'	'Increased (blood)'
            'EX_pmtcrn[u]'	'Increased (blood)'
            'EX_4hpro_LT[u]'	'Increased (urine)'
            'EX_pro_L[u]'	'Increased (urine)'
            'EX_3hivac[u]'	'Increased (urine)'
            'EX_CE4970[u]'	'Increased (urine)'
            'EX_CE4969[u]'	'Increased (urine)'
            'EX_CE4968[u]'	'Increased (urine)'
            'EX_ethmalac[u]'	'Increased (urine)'
            'EX_adpac[u]'	'Increased (urine)'
            'EX_subeac[u]'	'Increased (urine)'
            'EX_sebacid[u]'	'Increased (urine)'
            };
    end
    [IEMSol_GA2] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '2937.1' OXOP Glutathione Synthetase Deficiency And 5-Oxoprolinuria
    model = modelO;
    
    R = {'_GTHS'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(~cellfun(@isempty,strfind(model.rxns,R{i})));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(~cellfun(@isempty,strfind(model.rxns,'Micro_'))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, '5oxpro[bc]');
        model = addDemandReaction(model, 'leuktrE4[bc]');
        model = addDemandReaction(model, 'leuktrC4[bc]');
        model = addDemandReaction(model, 'leuktrD4[bc]');
        model = addDemandReaction(model, 'pro_L[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_5oxpro[u]'	'Increased (urine)'
            'EX_leuktrE4[u]'	'Increased (urine/blood)'
            'EX_leuktrC4[u]'	'Increased (urine/blood)'
            'DM_5oxpro[bc]'	'Decreased (blood)'
            'DM_leuktrE4[bc]'	'Increased (urine/blood)'
            'DM_leuktrC4[bc]'	'Increased (urine/blood)'
            'DM_leuktrD4[bc]'	'Increased (urine/blood)'
            'DM_pro_L[bc]'	'Increased (blood)'
            };
    else
        
        BiomarkerRxns = {
            'EX_5oxpro[u]'	'Increased (urine)/ Decreased (blood)'
            'EX_leuktrE4[u]'	'Increased (urine/blood)'
            'EX_leuktrC4[u]'	'Increased (urine/blood)'
            'EX_leuktrD4[u]'	'Increased (urine/blood)'
            'EX_pro_L[u]'	'Increased (blood)'
            };
    end
    [IEMSol_OXOP] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '178.1'GSD6 Glycogen Storage Disease Type 6/Hers Disease
    if 0
        model = modelO;
        
        R = {'_r1393'};
        RxnsAll2 = '';
        for i = 1: length(R)
            RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
            RxnsAll2 =[RxnsAll2;RxnsAll];
        end
        IEMRxns = unique(RxnsAll2);
        RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;
        IEMRxns = setdiff(IEMRxns,RxnMic);
        
        if ~strcmp(modelName,'Recon3D')
            % add demand reactions to blood compartment for those biomarkers reported for blood
            model = addDemandReaction(model, 'chsterol[bc]');
            model = addDemandReaction(model, 'glc_D[bc]');
            model = addDemandReaction(model, 'lac_L[bc]');
            if useSolveCobraLPCPLEX
                model.A = model.S;
            else
                if isfield(model,'A')
                    model = rmfield(model,'A');
                end
            end
            BiomarkerRxns = {
                'EX_acac[u]'	'Increased (urine)'
                'EX_acetone[u]'	'Increased (urine)'
                'EX_bhb[u]'	'Increased (urine)'
                'DM_chsterol[bc]'	'Increased (blood)'
                'DM_glc_D[bc]'	'Increased (blood)'
                'DM_lac_L[bc]'	'Increased (blood)'
                };
        else
            BiomarkerRxns = {
                'EX_acac[u]'	'Increased (urine)'
                'EX_acetone[u]'	'Increased (urine)'
                'EX_bhb[u]'	'Increased (urine)'
                'EX_chsterol[u]'	'Increased (blood)'
                'EX_glc_D[u]'	'Increased (blood)'
                'EX_lac_L[u]'	'Increased (blood)'
                };
        end
        [IEMSol_GSD6] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    end
    
    %% '2593.1' GMT Guanidinoacetate Methyltransferase Deficiency
    model = modelO;
    
    R = {'_GACMTRc'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'creat[bc]');
        model = addDemandReaction(model, 'crtn[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_creat[u]'	'Decreased (urine/blood)'
            'DM_creat[bc]'	'Decreased (urine/blood)'
            'DM_crtn[bc]'	'Increased (blood)'
            'EX_urate[u]'	'Increased (urine)'
            'EX_gudac[u]'	'Increased (urine)'
            };
    else
        BiomarkerRxns = {
            'EX_creat[u]'	'Decreased (urine/blood)'
            'EX_crtn[u]'	'Increased (blood)'
            'EX_urate[u]'	'Increased (urine)'
            'EX_gudac[u]'	'Increased (urine)'
            };
    end
    [IEMSol_GMT] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    %% '4942.1' GACR Gyrate Atrophy Of The Choroid And Retina
    model = modelO;
    
    R = {'_ORNTArm'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'gln_L[bc]');
        model = addDemandReaction(model, 'lys_L[bc]');
        model = addDemandReaction(model, 'orn[bc]');
        model = addDemandReaction(model, 'orn[csf]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_arg_L[u]'	'Increased (urine)'
            'DM_gln_L[bc]'	'Decreased (blood)'
            'EX_glu_L[u]'	'Decreased (blood)'
            'EX_lys_L[u]'	'Decreased (urine/blood)'
            'DM_lys_L[bc]'	'Decreased (urine/blood)'
            'EX_orn[u]'	'Increased (urine/blood/CSF)'
            'DM_orn[bc]'	'Increased (urine/blood/CSF)'
            'DM_orn[csf]'	'Increased (CSF)'
            };
    else
        BiomarkerRxns = {
            'EX_arg_L[u]'	'Increased'
            'EX_gln_L[u]'	'Decreased (blood)'
            'EX_glu_L[u]'	'Decreased (blood)'
            'EX_lys_L[u]'	'Decreased (urine/blood)'
            'EX_orn[u]'	'Increased (urine/blood/CSF)'
            };
    end
    [IEMSol_GACR] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '229.1' HFI Hereditary Fructose Intolerance
    if 0
        model = modelO;
        
        R = {'_FBA5'};
        RxnsAll2 = '';
        for i = 1: length(R)
            RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
            RxnsAll2 =[RxnsAll2;RxnsAll];
        end
        IEMRxns = unique(RxnsAll2);
        RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;
        IEMRxns = setdiff(IEMRxns,RxnMic);
        
        if ~strcmp(modelName,'Recon3D')
            % add demand reactions to blood compartment for those biomarkers reported for blood
            model = addDemandReaction(model, 'fru[bc]');
            if useSolveCobraLPCPLEX
                model.A = model.S;
            else
                if isfield(model,'A')
                    model = rmfield(model,'A');
                end
            end
            BiomarkerRxns = {
                'EX_fru[u]'	'Increased (urine/blood)'
                'DM_fru[bc]'	'Increased (urine/blood)'
                };
        else
            BiomarkerRxns = {
                'EX_fru[u]'	'Increased (urine/blood)'
                };
        end
        [IEMSol_HFI] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    end
    %% '3155.1 'HMG Hmg-Coa Lyase Deficiency
    model = modelO;
    
    R = {'_HMGLx'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'c6dc[bc]');
        model = addDemandReaction(model, 'CE5068[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'DM_c6dc[bc]'	'Increased (blood)'
            'EX_adpac[u]'	'Increased (urine)'
            };
    else
        BiomarkerRxns = {
            'EX_c6dc[u]'	'Increased (blood)'
            'EX_adpac[u]'	'Increased (urine)'
            };
    end
    [IEMSol_HMG] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '875.1 HCYS Homocystinuria
    % https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5203861/: Patients with CBS deficiency have low to low normal cystathionine (reference range typically between 0.05-0.08 and 0.35-0.5 ?mol/L) and high to high normal methionine concentrations (reference range typically between 12-15 and 40-45 ?mol/L) with a grossly abnormal ratio of these two metabolites.
    % https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5203861/: The major confounder that may mask the biochemical hallmarks of CBS deficiency is the intake of pyridoxine. Decreases in the tHcy concentration occur after pharmacological doses of pyridoxine in a substantial proportion of CBS deficient patients (Mudd et al 1985; Wilcken and Wilcken 1997; Magner et al 2011). In pyridoxine-responsive patients with some specific mutations (e.g. p.P49L), physiological doses of pyridoxine as low as 2 mg per day in an adult may decrease the tHcy concentrations into the reference range (Stabler et al 2013). Since pyridoxine is contained in many vitamin supplements as well as in fortified foods and drinks, it is important to avoid intake of any pyridoxine supplements for at least 2 weeks before sampling plasma for tHcy measurement, although occasionally a wash-out period of up to 1-2 months may be needed (Orendac et al 2003; Stabler et al 2013).
    
    model = modelO;
    
    R = {'_CYSTS';'_SELCYSTS'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'met_L[bc]');
        model = addDemandReaction(model, 'orn[bc]');
        model = addDemandReaction(model, 'Lhcystin[bc]');
        model = addDemandReaction(model, 'hcys_L[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'DM_met_L[bc]'	'Increased (blood)'%
            'DM_orn[bc]'	'Increased (blood)' % % not mentioned in 27778219
            'EX_Lhcystin[u]'	'Increased (urine/blood)' % difficult to detect - only in higher concentrations
            'DM_Lhcystin[bc]'	'Increased (urine/blood)' % difficult to detect - only in higher concentrations
            'EX_hcys_L[u]'	'Increased (urine/blood)' % only total hcys (not necessarily free hcys) is Increased
            'DM_hcys_L[bc]'	'Increased (urine/blood)' % only total hcys (not necessarily free hcys) is Increased
            'EX_cyst_L[u]'	'Decreased (urine)' % PMID: 27778219
            };
    else
        BiomarkerRxns = {
            'EX_met_L[u]'	'Increased (blood)'%
            'EX_orn[u]'	'Increased (blood)' % not mentioned in 27778219
            'EX_Lhcystin[u]'	'Increased (urine/blood)' % difficult to detect - only in higher concentrations
            'EX_hcys_L[u]'	'Increased (urine/blood)' % only total hcys (not necessarily free hcys) is Increased
            'EX_cyst_L[u]'	'Decreased (urine)' % PMID: 27778219
            };
    end
    [IEMSol_HCYS] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    %% '10157.1 HLYS1 Hyperlysinemia I, Familial
    model = modelO;
    
    R = {'_SACCD3m';'_SACCD4m';'_r0525'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'lys_L[bc]');
        model = addDemandReaction(model, 'Lpipecol[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_lys_L[u]'	'Increased (urine/blood)'
            'DM_lys_L[bc]'	'Increased (urine/blood)'
            'DM_Lpipecol[bc]'	'Increased (blood)'
            };
    else
        BiomarkerRxns = {
            'EX_lys_L[u]'	'Increased (urine/blood)'
            'EX_Lpipecol[u]'	'Increased (blood)'
            };
    end
    [IEMSol_HLYS1] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '10157.1 HLYS2 Hyperlysinemia II Or Saccharopinuria
    model = modelO;
    
    R = {'_SACCD3m';'_SACCD4m';'_r0525'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'lys_L[bc]');
        model = addDemandReaction(model, 'citr_L[bc]');
        model = addDemandReaction(model, 'saccrp_L[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_citr_L[u]'	'Increased (urine/blood)'
            'EX_lys_L[u]'	'Increased (urine/blood)'
            'DM_citr_L[bc]'	'Increased (urine/blood)'
            'DM_lys_L[bc]'	'Increased (urine/blood)'
            };
    else
        
        BiomarkerRxns = {
            'EX_citr_L[u]'	'Increased (urine/blood)'
            'EX_lys_L[u]'	'Increased (urine/blood)'
            };
    end
    [IEMSol_HLYS2] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '5625.1 HYPRO1 Hyperprolinemia Type I
    model = modelO;
    
    R = {'_r1453';'_PROD2m';'_PRO1xm'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'pro_L[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_4hpro_LT[u]'	'Increased (urine)'
            'EX_gly[u]'	'Increased (urine)'
            'EX_pro_L[u]'	'Increased (urine/blood)'
            'DM_pro_L[bc]'	'Increased (urine/blood)'
            };
    else
        BiomarkerRxns = {
            'EX_4hpro_LT[u]'	'Increased (urine)'
            'EX_gly[u]'	'Increased (urine)'
            'EX_pro_L[u]'	'Increased (urine/blood)'
            };
    end
    
    [IEMSol_HYPRO1] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '8659.1 HPII Hyperprolinemia Type Ii
    model = modelO;
    
    R = {'_P5CDm';'_PHCDm';'_r0686';'_4HGLSDm';'_r0074'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'pro_L[bc]');
        model = addDemandReaction(model, 'orn[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_4hpro_LT[u]'	'Increased (urine)'
            'EX_gly[u]'	'Increased (urine)'
            'EX_orn[u]'	'Increased (urine/blood)'
            'EX_pro_L[u]'	'Increased (urine/blood)'
            'DM_orn[bc]'	'Increased (urine/blood)'
            'DM_pro_L[bc]'	'Increased (urine/blood)'
            };
    else
        BiomarkerRxns = {
            'EX_4hpro_LT[u]'	'Increased'
            'EX_gly[u]'	'Increased (urine)'
            'EX_orn[u]'	'Increased (urine/blood)'
            'EX_pro_L[u]'	'Increased (urine/blood)'
            };
    end
    [IEMSol_HPII] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '3712.1 IVA Isovaleric Acidemia
    model = modelO;
    
    R = {'_ACOAD8m'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    model.lb(find(ismember(model.rxns,IEMRxns))) = 0;
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'ivcrn[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_3bcrn[u]'	'Increased (urine)'%
            'EX_3ivcrn[u]'	'Increased (urine)'
            'DM_ivcrn[bc]'	'Increased (blood)'
            };
    else
        
        BiomarkerRxns = {
            'EX_3bcrn[u]'	'Increased (urine)'
            'EX_3ivcrn[u]'	'Increased (urine)'
            'EX_ivcrn[u]'	'Increased (blood)'
            };
    end
    [IEMSol_IVA] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '3251.1 LNS Lesch-Nyhan Syndrome
    model = modelO;
    
    R = {'_GUAPRT';'_HXPRT'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'fol[bc]');
        model = addDemandReaction(model, 'urate[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'DM_fol[bc]'	'Decreased (blood)'
            'EX_urate[u]'	'Increased (urine/blood)'
            'DM_urate[bc]'	'Increased (urine/blood)'
            };
    else
        BiomarkerRxns = {
            'EX_fol[u]'	'Decreased (blood)'
            'EX_urate[u]'	'Increased (urine/blood)'
            };
    end
    [IEMSol_LNS] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '4056.1 LTC4S Leukotriene C4 Synthase Deficiency (Ltc4 Synthase Deficiency)
    model = modelO;
    
    R = {'_HMR_1081';'_LTC4Sr'}; % there is another reaction in [r] that has a more complex GPR
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'leuktrE4[bc]');
        model = addDemandReaction(model, 'leuktrC4[bc]');
        model = addDemandReaction(model, 'leuktrD4[bc]');
        model = addDemandReaction(model, 'leuktrE4[csf]');
        model = addDemandReaction(model, 'leuktrC4[csf]');
        model = addDemandReaction(model, 'leuktrD4[csf]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_leuktrE4[u]'	'Decreased (urine/blood/CSF)'
            'EX_leuktrC4[u]'	'Decreased (urine/blood/CSF)'
            'DM_leuktrE4[bc]'	'Decreased (urine/blood/CSF)'
            'DM_leuktrC4[bc]'	'Decreased (urine/blood/CSF)'
            'DM_leuktrD4[bc]'	'Decreased (urine/blood/CSF)'
            'DM_leuktrE4[csf]'	'Decreased (urine/blood/CSF)'
            };
    else
        BiomarkerRxns = {
            'EX_leuktrE4[u]'	'Decreased (urine/blood/CSF)'
            'EX_leuktrC4[u]'	'Decreased (urine/blood/CSF)'
            'EX_leuktrD4[u]'	'Decreased (urine/blood/CSF)'
            };
    end
    
    [IEMSol_LTC4S] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '593.1 MSUD Maple Syrup Urine Disease
    model = modelO;
    
    R = {'_r0670';'_OIVD1m';'_OIVD2m';'_OIVD3m';'_r0385';'_r0386';'_r1154'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'ile_L[bc]');
        model = addDemandReaction(model, 'leu_L[bc]');
        model = addDemandReaction(model, 'val_L[bc]');
        model = addDemandReaction(model, '3mop[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_ile_L[u]'	'Increased (urine/blood)'
            'EX_3mop[u]'	'Increased (urine/blood)'
            'DM_ile_L[bc]'	'Increased (urine/blood)'
            'DM_leu_L[bc]'	'Increased (blood)'
            'DM_val_L[bc]'	'Increased (blood)'
            'DM_3mop[bc]'	'Increased (urine/blood)'
            };
    else
        BiomarkerRxns = {
            'EX_ile_L[u]'	'Increased (urine/blood)'
            'EX_leu_L[u]'	'Increased (blood)'
            'EX_val_L[u]'	'Increased (blood)'
            'EX_3mop[u]'	'Increased (urine/blood)'
            };
    end
    [IEMSol_MSUD] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '4594.1 MMA Methylmalonic Acidemia (Mma)
    if 1
        model = modelO;
        
        R = {'_MMMm'};
        RxnsAll2 = '';
        for i = 1: length(R)
            RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
            RxnsAll2 =[RxnsAll2;RxnsAll];
        end
        IEMRxns = unique(RxnsAll2);
        RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
        IEMRxns = setdiff(IEMRxns,RxnMic);
        if ~strcmp(modelName,'Recon3D')
            % add demand reactions to blood compartment for those biomarkers reported for blood
            model = addDemandReaction(model, 'c4dc[bc]');
            model = addDemandReaction(model, 'crn[bc]');
            model = addDemandReaction(model, 'HC00900[bc]');
            model = addDemandReaction(model, '3hpp[bc]');
            model = addDemandReaction(model, 'pcrn[bc]');
            model = addDemandReaction(model, '3hdececrn[bc]');
            if useSolveCobraLPCPLEX
                model.A = model.S;
            else
                if isfield(model,'A')
                    model = rmfield(model,'A');
                end
            end
            BiomarkerRxns = {
                'EX_3aib[u]'	'Increased (urine)' %
                'DM_c4dc[bc]'	'Increased (blood)' %
                'DM_crn[bc]'	'Decreased (blood)' %
                'DM_HC00900[bc]'	'Increased (blood)' %
                'DM_3hpp[bc]'	'Increased (blood)' %
                'DM_pcrn[bc]'	'Increased (blood)'
                'DM_3hdececrn[bc]'	'Increased (blood)'
                };
        else
            BiomarkerRxns = {
                'EX_3aib[u]'	'Increased (urine)' %
                'EX_c4dc[u]'	'Increased (blood)' %
                'EX_crn[u]'	'Decreased (blood)' %
                'EX_HC00900[u]'	'Increased (blood)' %
                'EX_3hpp[u]'	'Increased (blood)' %
                'EX_pcrn[u]'	'Increased (blood)'
                'EX_3hdececrn[u]'	'Increased (blood)'
                
                };
        end
        [IEMSol_MMA] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    end
    %% '162417.1 NAGS N-Acetylglutamate Synthase Deficiency
    model = modelO;
    
    R = {'_RE2030M';'_RE2031M';'_RE2032M';'_RE2156M';'_RE2223M';'_ACGSm'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'ala_L[bc]');
        model = addDemandReaction(model, 'citr_L[bc]');
        model = addDemandReaction(model, 'gln_L[bc]');
        model = addDemandReaction(model, 'nh4[bc]');
        model = addDemandReaction(model, 'orn[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'DM_ala_L[bc]'	'Increased (blood)'
            'DM_citr_L[bc]'	'Decreased (blood)'
            'DM_gln_L[bc]'	'Increased (blood)'
            'DM_nh4[bc]'	'Increased (blood)'
            'DM_orn[bc]'	'Increased (blood)'
            'EX_orot[u]'	'Decreased (urine)'
            };
    else
        BiomarkerRxns = {
            'EX_ala_L[u]'	'Increased (blood)'
            'EX_citr_L[u]'	'Decreased (blood)'
            'EX_gln_L[u]'	'Increased (blood)'
            'EX_nh4[u]'	'Increased (blood)'
            'EX_orn[u]'	'Increased (blood)'
            'EX_orot[u]'	'Decreased (urine)'
            };
    end
    [IEMSol_NAGS] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    %% '5009.1 OTC Ornithine Transcarbamylase Deficiency
    model = modelO;
    
    R = {'_OCBTm'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'ura[bc]');
        model = addDemandReaction(model, 'citr_L[bc]');
        model = addDemandReaction(model, 'gln_L[bc]');
        model = addDemandReaction(model, 'nh4[bc]');
        model = addDemandReaction(model, 'orn[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_5oxpro[u]'	'Increased (transient, urine)'
            'EX_gly[u]'	'Increased (urine)'
            'EX_lys_L[u]'	'Increased (urine)'
            'EX_orot[u]'	'Increased (urine)'
            'DM_citr_L[bc]'	'Decreased (blood)'
            'DM_gln_L[bc]'	'Increased (blood)'
            'DM_ura[bc]'	'Increased (urine)'
            'DM_nh4[bc]'	'Increased (blood)'
            'DM_orn[bc]'	'Increased (blood)'
            };
    else
        BiomarkerRxns = {
            'EX_5oxpro[u]'	'Increased (transient, urine)'
            'EX_citr_L[u]'	'Decreased (blood)'
            'EX_gln_L[u]'	'Increased (blood)'
            'EX_gly[u]'	'Increased (urine)'
            'EX_lys_L[u]'	'Increased (urine)'
            'EX_orot[u]'	'Increased (urine)'
            'EX_ura[u]'	'Increased (urine)'
            'EX_nh4[u]'	'Increased (blood)'
            'EX_orn[u]'	'Increased (blood)'
            'EX_cyst_L[u]'	'Unknown (urine)'
            'EX_23dhmb[u]'	'Unknown (urine)'
            'EX_3hanthrn[u]'	'Unknown (urine)'
            'EX_3mob[u]'	'Unknown (urine)'
            'EX_3mop[u]'	'Unknown (urine)'
            'EX_im4ac[u]'	'Unknown (urine)'
            'EX_anth[u]'	'Unknown (urine)'
            'EX_3hivac[u]'	'Unknown (urine)'
            'EX_dopa[u]'	'Unknown (urine)'
            'EX_peamn[u]'	'Unknown (urine)'
            'EX_saccrp_L[u]'	'Unknown (urine)'
            'EX_trypta[u]'	'Unknown (urine)'
            'EX_tyr_L[u]'	'Unknown (urine)'
            'EX_val_L[u]'	'Unknown (urine)'
            'EX_cgly[u]'	'Unknown (urine)'
            'EX_Lcystin[u]'	'Unknown (urine)'
            'EX_hmcr[u]'	'Unknown (urine)'
            'EX_ddeccrn[u]'	'Unknown (urine)'
            'EX_CE1310[u]'	'Unknown (urine)'
            'EX_pheacgly[u]'	'Unknown (urine)'
            'EX_phacgly[u]'	'Unknown (urine)'
            'EX_M02723[u]'	'Unknown (urine)'
            'EX_leuval[u]'	'Unknown (urine)'
            };
    end
    [IEMSol_OTC] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '7372.1 OROA Orotic Aciduria
    if 0
        model = modelO;
        
        R = {'_ORPT';'_OMPDC'};
        RxnsAll2 = '';
        for i = 1: length(R)
            RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
            RxnsAll2 =[RxnsAll2;RxnsAll];
        end
        IEMRxns = unique(RxnsAll2);
        RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
        IEMRxns = setdiff(IEMRxns,RxnMic);
        
        if ~strcmp(modelName,'Recon3D')
            % add demand reactions to blood compartment for those biomarkers reported for blood
            model = addDemandReaction(model, 'orot[bc]');
            if useSolveCobraLPCPLEX
                model.A = model.S;
            else
                if isfield(model,'A')
                    model = rmfield(model,'A');
                end
            end
            BiomarkerRxns = {
                'EX_orot[u]'	'Increased (urine/blood)'
                'DM_orot[bc]'	'Increased (urine/blood)'
                };
        else
            BiomarkerRxns = {
                'EX_orot[u]'	'Increased (urine/blood)'
                };
        end
        [IEMSol_OROA] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    end
    %% '5053.1 PKU Phenylketonuria
    model = modelO;
    
    R = {'_PHETHPTOX2';'_r0399'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'phe_L[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'DM_phe_L[bc]'	'Increased (blood)'
            'EX_2hyoxplac[u]'	'Increased (urine)'
            'EX_phpyr[u]'	'Increased (urine)'
            };
    else
        BiomarkerRxns = {
            'EX_phe_L[u]'	'Increased (blood)'
            'EX_2hyoxplac[u]'	'Increased (urine)'
            'EX_phpyr[u]'	'Increased (urine)'
            };
    end
    [IEMSol_PKU] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '1890.1 MNGIE Mitochondrial Neurogastrointestinal Encephalopathy (Mngie) Disease
    model = modelO;
    if 0
        R = {'_TMDPP'};
        RxnsAll2 = '';
        for i = 1: length(R)
            RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
            RxnsAll2 =[RxnsAll2;RxnsAll];
        end
        IEMRxns = unique(RxnsAll2);
        RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
        IEMRxns = setdiff(IEMRxns,RxnMic);
        
        if ~strcmp(modelName,'Recon3D')
            % add demand reactions to blood compartment for those biomarkers reported for blood
            model = addDemandReaction(model, 'duri[bc]');
            model = addDemandReaction(model, 'thymd[bc]');
            if useSolveCobraLPCPLEX
                model.A = model.S;
            else
                if isfield(model,'A')
                    model = rmfield(model,'A');
                end
            end
            BiomarkerRxns = {
                'DM_duri[bc]'	'Increased (blood)'
                'DM_thymd[bc]'	'Increased (blood)'
                };
        else
            BiomarkerRxns = {
                'EX_duri[u]'	'Increased (blood)'
                'EX_thymd[u]'	'Increased (blood)'
                };
        end
        [IEMSol_MNGIE] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    end
    %% '8803.1 SUCLA Succinate-Coenzyme A (Coa) Ligase Deficiency/Lactic Acidosis, Fatal Infantile
    model = modelO;
    
    R = {'_ITCOALm';'_MECOALm';'_SUCOASm';'_ITCOAL1m';'_MECOAS1m';'_SUCOAS1m'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'lac_L[bc]');
        model = addDemandReaction(model, 'pyr[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'DM_lac_L[bc]'	'Increased (blood)'
            'DM_pyr[bc]'	'Increased (blood)'
            };
    else
        BiomarkerRxns = {
            'EX_lac_L[u]'	'Increased (blood)'
            'EX_pyr[u]'	'Increased (blood)'
            };
    end
    [IEMSol_SUCLA] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '7915.1 SSADHD Succinic Semialdehyde Dehydrogenase Deficiency
    model = modelO;
    
    R = {'_r0178'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'gly[bc]');
        model = addDemandReaction(model, '4hdxbutn[bc]');
        model = addDemandReaction(model, 'sucsal[bc]');
        model = addDemandReaction(model, '4abut[csf]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_gly[u]'	'Increased (urine/blood)'
            'EX_sucsal[u]'	'Increased (urine/blood)'
            'DM_gly[bc]'	'Increased (urine/blood)'
            'DM_sucsal[bc]'	'Increased (urine/blood)'
            'DM_4abut[csf]'	'Increased (CSF)'
            };
    else
        BiomarkerRxns = {
            'EX_gly[u]'	'Increased (urine/blood)'
            'EX_sucsal[u]'	'Increased (urine/blood)'
            'EX_4abut[u]'	'Increased (CSF)'
            };
    end
    [IEMSol_SSADHD] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '2643.1 TETB Tetrahydrobiopterin Deficiency
    %  is a naturally occurring essential cofactor of the three aromatic amino
    %  acid hydroxylase enzymes, used in the degradation of amino acid
    %  phenylalanine and in the biosynthesis of the neurotransmitters serotonin
    %  (5-hydroxytryptamine, 5-HT), melatonin, dopamine,...
    model = modelO;
    
    R = {'_GTPCIn';'_r0120';'_r0121';'_r0708';'_r0775';'_r0777';'_GTPCI';...
        '_TYR3MO2';'_PHETHPTOX2';'_Tetrahydrobiopterin'
        };
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'phe_L[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'DM_phe_L[bc]'	'Increased (blood)'
            };
    else
        BiomarkerRxns = {
            'EX_phe_L[u]'	'Increased (blood)'
            };
    end
    [IEMSol_TETB] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '445.1 CIT1 Type I Citrullinemia
    model = modelO;
    
    R = {'_ARGSS' };
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'citr_L[bc]');
        model = addDemandReaction(model, 'gly[bc]');
        model = addDemandReaction(model, 'nh4[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'DM_citr_L[bc]'	'Increased (urine/blood)'
            'DM_gly[bc]'	'Increased (urine/blood)'
            'DM_nh4[bc]'	'Increased (blood)'
            'EX_orot[u]'	'Increased (urine)'
            'EX_citr_L[u]'	'Increased (urine/blood)'
            'EX_gly[u]'	'Increased (urine/blood)'
            };
    else
        
        BiomarkerRxns = {
            'EX_citr_L[u]'	'Increased (urine/blood)'
            'EX_gly[u]'	'Increased (urine/blood)'
            'EX_nh4[u]'	'Increased (blood)'
            'EX_orot[u]'	'Increased (urine)'
            };
    end
    [IEMSol_CIT1] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '2184.1 TYR1 Tyrosinemia Type I
    model = modelO;
    
    R = {'_FUMAC' };
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'met_L[bc]');
        model = addDemandReaction(model, 'tyr_L[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'DM_met_L[bc]'	'Increased (blood)'
            'DM_tyr_L[bc]'	'Increased (blood)'
            'EX_34hpl[u]'	'Increased (urine)'
            'EX_34hpp[u]'	'Increased (urine)'
            };
    else
        BiomarkerRxns = {
            'EX_met_L[u]'	'Increased (blood)'
            'EX_tyr_L[u]'	'Increased (blood)'
            'EX_34hpl[u]'	'Increased (urine)'
            'EX_34hpp[u]'	'Increased (urine)'
            };
    end
    [IEMSol_TYR1] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '3242.1 TYR3 Tyrosinemia Type III
    model = modelO;
    
    R = {'_34HPPOR';'_PPOR' };
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'tyr_L[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'DM_tyr_L[bc]'	'Increased (blood)'
            'EX_34hpl[u]'	'Increased (urine)'
            'EX_34hpp[u]'	'Increased (urine)'
            };
    else
        BiomarkerRxns = {
            'EX_tyr_L[u]'	'Increased (blood)'
            'EX_34hpl[u]'	'Increased (urine)'
            'EX_34hpp[u]'	'Increased (urine)'
            };
    end
    [IEMSol_TYR3] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '7498.1 XAN1 Xanthinuria Type 1
    model = modelO;
    
    R = {'_r0395';'_XANDp';'_XAO2x';'_XAOx';'_r0394';'_r0502';'_r0504' };
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'xan[bc]');
        model = addDemandReaction(model, 'urate[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_hxan[u]'	'Increased (urine)'
            'EX_xan[u]'	'Increased (blood/urine)'
            'EX_urate[u]'	'Decreased (blood/urine)'
            'DM_xan[bc]'	'Increased (blood/urine)'
            'DM_urate[bc]'	'Decreased (blood/urine)'
            };
    else
        BiomarkerRxns = {
            'EX_hxan[u]'	'Increased (urine)'
            'EX_xan[u]'	'Increased (blood/urine)'
            'EX_urate[u]'	'Decreased (blood/urine)'
            };
    end
    [IEMSol_XAN1] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% '4967.1 AKGD Alpha-Ketoglutarate Dehydrogenase Deficiency
    model = modelO;
    
    R = {'_AKGDm';'_2OXOADOXm';'_r0163';'_r0384';'_r0451';'_r0620' };
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'lac_L[bc]');
        model = addDemandReaction(model, 'glu_L[bc]');
        model = addDemandReaction(model, 'gln_L[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_akg[u]'	'Increased (urine)'
            'EX_lac_L[u]'	'Increased (blood/urine)'
            'DM_lac_L[bc]'	'Increased (blood/urine)'
            'DM_glu_L[bc]'	'Increased (blood)'
            'DM_gln_L[bc]'	'Increased (blood)'
            };
    else
        BiomarkerRxns = {
            'EX_akg[u]'	'Increased (urine)'
            'EX_lac_L[u]'	'Increased (blood/urine)'
            'EX_glu_L[u]'	'Increased (blood)'
            'EX_gln_L[u]'	'Increased (blood)'
            };
    end
    [IEMSol_AKGD] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    
    %% 1181.1 EP Essential Pentosuria
    if 1
        model = modelO;
        
        R = {'_XYLUR'};
        RxnsAll2 = '';
        for i = 1: length(R)
            RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
            RxnsAll2 =[RxnsAll2;RxnsAll];
        end
        IEMRxns = unique(RxnsAll2);
        RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
        IEMRxns = setdiff(IEMRxns,RxnMic);
        
        model.lb(find(ismember(model.rxns,IEMRxns))) = 0;
        
        R2 = {'_r0784'};
        RxnsAll2 = '';
        for i = 1: length(R2)
            RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R2{i}))));
            RxnsAll2 =[RxnsAll2;RxnsAll];
        end
        X = unique(RxnsAll2);
        RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
        X = setdiff(X,RxnMic);
        model.lb(find(ismember(model.rxns,X))) = 0;
        model.ub(find(ismember(model.rxns,X))) = 0;
        
        if ~strcmp(modelName,'Recon3D')
            % add demand reactions to blood compartment for those biomarkers reported for blood
            
            if useSolveCobraLPCPLEX
                model.A = model.S;
            else
                if isfield(model,'A')
                    model = rmfield(model,'A');
                end
            end
            BiomarkerRxns = {
                'EX_xylu_L[u]'	'Increased (urine)'
                };
        else
            BiomarkerRxns = {
                'EX_xylu_L[u]'	'Increased (urine)'
                };
        end
        [IEMSol_EP] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    end
    
    %% 587.1 HYPVLI Hypervalinemia And Hyperleucine-Isoleucinemia
    if 1
        model = modelO;
        
        R = {'_ILETAm';'_LEUTAm';'_VALTAm'};
        RxnsAll2 = '';
        for i = 1: length(R)
            RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
            RxnsAll2 =[RxnsAll2;RxnsAll];
        end
        IEMRxns = unique(RxnsAll2);
        RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
        IEMRxns = setdiff(IEMRxns,RxnMic);
        
        if ~strcmp(modelName,'Recon3D')
            % add demand reactions to blood compartment for those biomarkers reported for blood
            model = addDemandReaction(model, 'val_L[bc]');
            model = addDemandReaction(model, 'leu_L[bc]');
            if useSolveCobraLPCPLEX
                model.A = model.S;
            else
                if isfield(model,'A')
                    model = rmfield(model,'A');
                end
            end
            BiomarkerRxns = {
                'DM_val_L[bc]'	'Increased (blood/urine)'
                'EX_val_L[u]'	'Increased (blood/urine)'
                'EX_leu_L[u]'	'Increased (blood/urine)'
                };
        else
            BiomarkerRxns = {
                'EX_val_L[u]'	'Increased (blood/urine)'
                'EX_leu_L[u]'	'Increased (blood/urine)'
                };
        end
        [IEMSol_HYPVLI] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    end
    
    
    %% 440.1 ASNSD Asparagine Synthetase Deficiency
    if 1
        model = modelO;
        
        R = {'_ASNS1'};
        RxnsAll2 = '';
        for i = 1: length(R)
            RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
            RxnsAll2 =[RxnsAll2;RxnsAll];
        end
        IEMRxns = unique(RxnsAll2);
        RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
        IEMRxns = setdiff(IEMRxns,RxnMic);
        
        if ~strcmp(modelName,'Recon3D') %&& ~strcmp(modelName,'Harvey') %somehow it gets stuck here
            % add demand reactions to blood compartment for those biomarkers reported for blood
            % biomarker based on https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4486270/
            model = addDemandReaction(model, 'asn_L[bc]');
            model = addDemandReaction(model, 'asn_L[csf]');
            model = addDemandReaction(model, 'gln_L[bc]');
            model = addDemandReaction(model, 'gln_L[csf]');
            if useSolveCobraLPCPLEX
                model.A = model.S;
            else
                if isfield(model,'A')
                    model = rmfield(model,'A');
                end
            end
            BiomarkerRxns = {
                'DM_asn_L[bc]'	'Decreased (blood/csf)'
                'DM_asn_L[csf]'	'Decreased (blood/csf)'
                'DM_gln_L[bc]'	'Increased (blood/csf)'
                'DM_gln_L[csf]'	'Increased (blood/csf)'
                };
        else
            BiomarkerRxns = {
                'EX_asn_L[u]'	'Decreased (blood/urine)'
                'EX_gln_L[u]'	'Increased (blood/urine)'
                };
        end
        [IEMSol_ASNSD] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    end
end


%% 435.1: Argininosuccinic Aciduria
if 1
    model = modelO;
    
    R = '_ARGSL';
    IEMRxns = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R))));
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    % set ARGSL to be irreversible
    model.lb(find(ismember(model.rxns,IEMRxns))) = 0;
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'gln_L[bc]');
        model = addDemandReaction(model, 'citr_L[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_argsuc[u]'	'Increased (urine)'
            'EX_gly[u]'	'Increased (urine)'
            'EX_orot[u]'	'Increased (urine)'
            'EX_lys_L[u]'	'Increased (urine)'
            'EX_ura[u]'	'Increased (urine)'
            'DM_gln_L[bc]'	'Increased (blood)'
            'DM_citr_L[bc]'	'Increased (blood)'
            };
    else
        BiomarkerRxns = {
            'EX_argsuc[u]'	'Increased (urine)'
            'EX_gly[u]'	'Increased (urine)'
            'EX_orot[u]'	'Increased (urine)'
            'EX_lys_L[u]'	'Increased (urine)'
            'EX_ura[u]'	'Increased (urine)'
            'EX_gln_L[u]'	'Increased (blood)'
            'EX_citr_L[u]'	'Increased (blood)'
            };
    end
    [IEMSol_ASA] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
end

%% '166785.1 MMA Methylmalonic Acidemia (Mma)
if 0
    model = modelO;
    
    R = {'_CBLATm'};%;'_CBL2tm' % lethal in HH
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'c4dc[bc]');
        model = addDemandReaction(model, 'crn[bc]');
        model = addDemandReaction(model, 'HC00900[bc]');
        model = addDemandReaction(model, '3hpp[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_3aib[u]'	'Increased (urine)'
            'DM_c4dc[bc]'	'Increased (blood)'
            'DM_crn[bc]'	'Decreased (blood)'
            'DM_HC00900[bc]'	'Increased (blood)'
            'DM_3hpp[bc]'	'Increased (blood)'
            };
    else
        BiomarkerRxns = {
            'EX_3aib[u]'	'Increased (urine)'
            'EX_c4dc[u]'	'Increased (blood)'
            'EX_crn[u]'	'Decreased (blood)'
            'EX_HC00900[u]'	'Increased (blood)'
            'EX_3hpp[u]'	'Increased (blood)'
            };
    end
    [IEMSol_MMA] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
end
%% '5091.1 PC Pyruvate Carboxylase Deficiency
if 1
    model = modelO;
    
    R = {'_PCm'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'acac[bc]');
        model = addDemandReaction(model, 'ala_L[bc]');
        model = addDemandReaction(model, 'bhb[bc]');
        model = addDemandReaction(model, 'citr_L[bc]');
        model = addDemandReaction(model, 'lys_L[bc]');
        model = addDemandReaction(model, 'pro_L[bc]');
        model = addDemandReaction(model, 'lac_L[bc]');
        model = addDemandReaction(model, 'nh4[bc]');
        model = addDemandReaction(model, 'glc_D[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'DM_acac[bc]'	'Increased (urine/blood)'
            'DM_ala_L[bc]'	'Increased (blood)'
            'DM_bhb[bc]'	'Increased (urine/blood)'
            'DM_citr_L[bc]'	'Increased (blood)'
            'DM_lys_L[bc]'	'Increased (blood)'
            'DM_pro_L[bc]'	'Increased (blood)'
            'DM_lac_L[bc]'	'Increased (blood)' % after 12hrs of fasting,
            'DM_nh4[bc]'	'Increased (blood)' % after 12hrs of fasting,
            'DM_glc_D[bc]'	'Decreased (blood)' % after 12hrs of fasting,
            'EX_fum[u]'	'Increased (urine)'
            'EX_succ[u]'	'Increased (urine)'
            'EX_acetone[u]'	'Increased (urine)'
            'EX_akg[u]'	'Increased (urine)'
            'EX_acac[u]'	'Increased (urine/blood)'
            'EX_bhb[u]'	'Increased (urine/blood)'
            };
    else
        
        BiomarkerRxns = {
            'EX_acac[u]'	'Increased (urine/blood)'
            'EX_acetone[u]'	'Increased (urine)'
            'EX_akg[u]'	'Increased (urine)'
            'EX_ala_L[u]'	'Increased (blood)'
            'EX_bhb[u]'	'Increased (urine/blood)'
            'EX_citr_L[u]'	'Increased (blood)'
            'EX_lys_L[u]'	'Increased (blood)'
            'EX_pro_L[u]'	'Increased (blood)'
            'EX_succ[u]'	'Increased (urine)'
            'EX_lac_L[u]'	'Increased (blood)' % after 12hrs of fasting,
            'EX_nh4[u]'	'Increased (blood)' % after 12hrs of fasting,
            'EX_glc_D[u]'	'Decreased (blood)' % after 12hrs of fasting,
            'EX_fum[u]'	'Increased (urine)'
            };
    end
    [IEMSol_PC] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
end
%% '189.1 PHOX1 Primary Hyperoxaluria-Type 1
if 1
    model = modelO;
    
    R = {'_AGTix';'_SPTix';'_r0160'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    BiomarkerRxns = {
        'EX_oxa[u]'	'Increased (urine)'
        'EX_glyclt[u]'	'Increased (urine)'
        'EX_glx[u]'	'Increased (urine)'
        };
    [IEMSol_PHOX1] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
end

%% '4967.1 ADSL Adenylosuccinase Deficiency
if 1
    model = modelO;
    
    R = {'_ADSL1';'_ADSL2'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'Brain_25aics[c]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            % 'EX_25aics[u]'	'Increased (urine/csf)' % not in HH
            'DM_Brain_25aics[c]'	'Increased (urine/csf)' % cannot be produced by HH
            };
    else
        BiomarkerRxns = {
            %    'EX_25aics[u]'	'Increased (urine/csf)'
            };
    end
    [IEMSol_ADSL] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
end


%% 443.1 CD Canavan Disease - only milder forms of this disease have been reported (there is an isozyme in Recon -- due to mild form report I included this IEM anyway)
if 1
    model = modelO;
    
    R = {'_NACASPAH'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'Nacasp[bc]');
        model = addDemandReaction(model, 'Nacasp[csf]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            % 'EX_25aics[u]'	'Increased (urine/csf)' % not in HH
            'EX_Nacasp[u]'	'Increased (urine/csf/blood)' % cannot be produced by HH
            'DM_Nacasp[bc]'	'Increased (urine/csf/blood)'
            'DM_Nacasp[csf]'	'Increased (urine/csf/blood)'
            };
    else
        BiomarkerRxns = {
            'EX_Nacasp[u]'	'Increased (urine/csf/blood)'
            };
    end
    [IEMSol_CD] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
end
%% 1371.1 HPC Hereditary Coproporphyria
if 1 %Rxn obj is 0
    model = modelO;
    
    R = {'_CPPPGO'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'C05770[bc]');
        model = addDemandReaction(model, 'C05770[csf]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_25aics[u]'	'Increased (urine/csf)' % not in HH
            'EX_C05770[u]'	'Increased (urine/csf/blood)'
            'DM_C05770[bc]'	'Increased (urine/csf/blood)'
            'DM_C05770[csf]'	'Increased (urine/csf/blood)'
            };
    else
        BiomarkerRxns = {
            'EX_C05770[u]'	'Increased (urine/csf/blood)'
            };
    end
    [IEMSol_HPC] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
end

%% 191.1 HMET Hypermethioninemia
if 1
    model = modelO;
    
    R = {'_GNMT'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'hcys_L[bc]');
        model = addDemandReaction(model, 'met_L[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'EX_met_L[u]'	'Increased (urine/blood)' %
            'EX_hcys_L[u]'	'Increased (urine/blood)'
            'DM_hcys_L[bc]'	'Increased (urine/blood)'
            'DM_met_L[bc]'	'Increased (urine/blood)'
            };
    else
        BiomarkerRxns = {
            'EX_met_L[u]'	'Increased (urine/blood)'
            'EX_hcys_L[u]'	'Increased (urine/blood)'
            };
    end
    [IEMSol_HMET] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
end

%% 1718.1 DESMO Desmosterolosis
if 1
    model = modelO;
    
    R = {'_DHCR241r';'_DHCR243r';'_r0783';'_r1380';'_DSREDUCr';'_HMR_1526';'_RE3129N'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    R2 = {'_RE2410C';'_RE2410N'};
    RxnsAll2 = '';
    for i = 1: length(R2)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R2{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    X = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;;
    X = setdiff(X,RxnMic);
    model.lb(find(ismember(model.rxns,X))) = 0;
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        model = addDemandReaction(model, 'dsmsterol[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'DM_dsmsterol[bc]'	'Increased (blood)'
            };
    else
        BiomarkerRxns = {
            'EX_dsmsterol[u]'	'Increased (blood)'
            };
    end
    [IEMSol_DESMO] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
end


%% 89874.1 2OAA 2-Oxoadipate Acidemia
if 1 % not well studied - inconsistent biomarkers between reports
    model = modelO;
    
    R = {'_2OXOADPTm';'_2AMADPTm';'_r0879'};
    RxnsAll2 = '';
    for i = 1: length(R)
        RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
        RxnsAll2 =[RxnsAll2;RxnsAll];
    end
    IEMRxns = unique(RxnsAll2);
    RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;
    IEMRxns = setdiff(IEMRxns,RxnMic);
    
    if ~strcmp(modelName,'Recon3D')
        % add demand reactions to blood compartment for those biomarkers reported for blood
        % biomarker based on https://www.omim.org/entry/204750
        model = addDemandReaction(model, 'L2aadp[bc]');
        if useSolveCobraLPCPLEX
            model.A = model.S;
        else
            if isfield(model,'A')
                model = rmfield(model,'A');
            end
        end
        BiomarkerRxns = {
            'DM_L2aadp[bc]'	'Increased (blood)'
            'EX_2oxoadp[u]'	'Increased (urine)'
            'EX_adpoh[u]'	'Increased (urine)'
            };
    else
        BiomarkerRxns = {
            'EX_2oxoadp[u]'	'Increased (urine)'
            'EX_adpoh[u]'	'Increased (urine)'
            };
    end
    [IEMSol_2OAA] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
end


%% Parse IEM results

vars = who;
vars_IEM = strmatch('IEMSol_',vars);
% count results (in vivo vs in silico
UpUp =0;
DoDo = 0;
UpDo = 0;
DoUp = 0;
UpUn = 0; %up in vivo, unchanged in silico
DoUn = 0; %down in vivo, unchanged in silico
UnUp = 0; %unchanged in vivo, up in silico
UnDo = 0; %unchanged in vivo, down in silico
UnUn =0;
cnt = 1;

clear Table_IEM
for i = 1 : length(vars_IEM)
    % read in IEM solutions
    clear IEM
    IEM = evalin('base',vars{vars_IEM(i)});
    % get change of direction
    for j = 5 : 2 : size(IEM,1)
        H_D = str2num(char(IEM(j,2))) -  str2num(char(IEM(j+1,2))); % healthy minus disease
        if H_D < -1e-6 %Increased
            H_D_in_sil =1;
        elseif  H_D > 1e-6 %Increased
            H_D_in_sil =-1;
        else % unchanged
            H_D_in_sil =0;
        end
        % is the marker Increased or decreased in vivo?
        if ~isempty(strfind(IEM{j,3},'Incre'))
            H_D_in_vivo = 1;
        elseif  ~isempty(strfind(IEM{j,3},'Decre'))
            H_D_in_vivo = -1;
        else % unchanged
            H_D_in_vivo = 0;
        end
        % create new table with all results
        Table_IEM{cnt,1} = regexprep(vars{vars_IEM(i)},'IEMSol_',''); % IEM abbr
        Table_IEM{cnt,2} = regexprep(IEM{j,1},'Healthy:',''); % biomaker
        Table_IEM{cnt,3} = (IEM(j,2)); % healthy original values
        Table_IEM{cnt,4} = (IEM(j+1,2)); % disease original values
        Table_IEM{cnt,5} = num2str(H_D_in_sil); % in silico
        Table_IEM{cnt,6} = num2str(H_D_in_vivo); % in vivo
        Table_IEM{cnt,7} = IEM{j,3}; % original in vivo message (for biofluid info)
        Table_IEM{cnt,8} = (IEM(1,2));
        cnt = cnt +1;
        if H_D_in_vivo == 1 && H_D_in_sil == 1
            UpUp =  UpUp + 1;
        elseif H_D_in_vivo == -1 && H_D_in_sil == -1
            DoDo = DoDo + 1;
        elseif H_D_in_vivo == 1 && H_D_in_sil == -1
            UpDo =  UpDo +1;
        elseif H_D_in_vivo == -1 && H_D_in_sil == 1
            DoUp = DoUp + 1;
        elseif H_D_in_vivo == 0 && H_D_in_sil == 1
            UnUp = UnUp + 1;
        elseif H_D_in_vivo == 1 && H_D_in_sil == 0
            UpUn = UpUn + 1;
        elseif H_D_in_vivo == -1 && H_D_in_sil == 0
            DoUn = DoUn + 1;
        elseif H_D_in_vivo == 0 && H_D_in_sil == -1
            UnDo = UnDo + 1;
        elseif H_D_in_vivo == 0 && H_D_in_sil == 0
            UnUn = UnUn + 1;
        end
    end
end

clear Table_IEM_Grid
Diseases = unique(Table_IEM(:,1));
BioMU = unique(Table_IEM(find(~cellfun(@isempty,strfind(Table_IEM(:,2),'[u]'))),2));
BioMCSF = unique(Table_IEM(find(~cellfun(@isempty,strfind(Table_IEM(:,2),'[csf]'))),2));
BioMBC = unique(Table_IEM(find(~cellfun(@isempty,strfind(Table_IEM(:,2),'[bc]'))),2));
BioM = [BioMBC; BioMU; BioMCSF];

cnt=1;
for i = 1 : length(vars_IEM)
    % read in IEM solutions
    clear IEM
    IEM = evalin('base',vars{vars_IEM(i)});
    % get change of direction
    for j = 5 : 2 : size(IEM,1)
        H_D = str2num(char(IEM(j,2))) -  str2num(char(IEM(j+1,2))); % healthy minus disease
        if H_D < -1e-6 %Increased
            H_D_in_sil =1;
        elseif  H_D > 1e-6 %Increased
            H_D_in_sil =-1;
        else % unchanged
            H_D_in_sil =0;
        end
        % is the marker Increased or decreased in vivo?
        if ~isempty(strfind(IEM{j,3},'Incre'))
            H_D_in_vivo = 1;
        elseif  ~isempty(strfind(IEM{j,3},'Decre'))
            H_D_in_vivo = -1;
        else % unchanged
            H_D_in_vivo = 0;
        end
        
        cnt = cnt +1;
    end
end


% make Table with overall results
Table_sum_results{1,2} = 'up';
Table_sum_results{1,3} = 'un';
Table_sum_results{1,4} = 'down';
Table_sum_results{2,1} = 'up';
Table_sum_results{3,1} = 'un';
Table_sum_results{4,1} = 'down';
Table_sum_results{2,2} = num2str(UpUp);
Table_sum_results{2,3} = num2str(UnUp);
Table_sum_results{2,4} = num2str(DoUp);
Table_sum_results{3,2} = num2str(UpUn);
Table_sum_results{3,3} = num2str(UnUn);
Table_sum_results{3,4} = num2str(DoUn);
Table_sum_results{4,2} = num2str(UpDo);
Table_sum_results{4,3} = num2str(UnDo);
Table_sum_results{4,4} = num2str(DoDo);

Accuracy = (UpUp + DoDo)/(UpUp+UnUp+DoUp+UpUn+UnUn+DoUn+UpDo+UnDo+DoDo)
Precision = (UpUp)/(UpUp + UpDo)
FalseDiscoveryRate = (UpDo)/(UpUp + UpDo)

NumDiseases = length(unique(Table_IEM(:,1)))
NumBiomarkers = length(unique(Table_IEM(:,2)))

clear Bio* Do* H_* IEM IEMRxns R R2 RxnsA* Un* Up* X cnt i j minR* model vars*
%clearvars -except Table_sum_results Accuracy Precision FalseDiscoveryRate NumDiseases NumBiomarkers

if strcmp(modelName,'Harvey')
    % load  Harvey1_0
    if  microbiome == 1
        save([resultsPath 'Results_IEM_Harvey_1_03_Mic'])
    else
        save([resultsPath 'Results_IEM_Harvey_1_03'])
    end
    
elseif strcmp(modelName,'Harvetta')
    % load  Harvetta1_0
    if  microbiome == 1
        save([resultsPath 'Results_IEM_Harvetta_1_03_Mic'])
    else
        save([resultsPath 'Results_IEM_Harvetta_1_03'])
    end
elseif strcmp(modelName,'Recon3D')
    save([resultsPath 'Results_IEM_Recon3DStar'])
end
