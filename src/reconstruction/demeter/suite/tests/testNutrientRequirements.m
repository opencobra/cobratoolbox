function [TruePositives, TrueNegatives, FalsePositives, FalseNegatives, Sensitivity, Specificity, Accuracy] = testNutrientRequirements(model, microbeID, biomassReaction)
% Performs an FVA and reports those nutrients (exchange reactions) that are
% essential both in vitro and in silico (true positives essential) or
% non-essential in vitro and in  silcio (true positives nonessential), and
% those nutrients that are nonessential in silico but essential in vitro
% (false negatives essential) and those that are essential in silico but
% nonessential in vitro (false negatives nonessential).
%
% INPUT
% model                         COBRA model structure
% microbeID                     Microbe ID in carbon source data file
% biomassReaction               Biomass objective functions (low flux
%                               through BOF required in analysis)
%
% OUTPUT
% TruePositives     	        Cell array of strings listing all nutrients
%                               (exchange reactions) that are essential
%                               both in vitro and in silco.
% TrueNegatives                 Cell array of strings listing all nutrients
%                               (exchange reactions) that are nonessential
%                               both in vitro and in silco.
% FalseNegatives                Cell array of strings listing all nutrients
%                               (exchange reactions) that should be
%                               essential for the microbe according to
%                               in vitro data but are nonessential in silico.
% FalsePositives                Cell array of strings listing all nutrients
%                               (exchange reactions) that should be
%                               non-essential for the microbe according to
%                               in vitro data but are essential in silico.
% Sensitivity                   # true positives/(# true positives + #
%                               false negatives
% Specificity                   # true negatives/(# true negatives + #
%                               false positives
% Accuracy                      # true positives + # true negatives/
%                               (# true positives + # true negatives + #
%                               false positives + # false negatives
%
% Stefania Magnusdottir, Nov 2017
% Almut Heinken-July 2018-adapted nomenclature

tol=0.0000001;

% read nutrient requirement tables
nutrientTable = readtable('NutrientRequirementsTable.txt', 'Delimiter', '\t');
% remove the reference columns
for i=1:11
    if ismember(['Ref' num2str(i)],nutrientTable.Properties.VariableNames)
nutrientTable.(['Ref' num2str(i)])=[];
    end
end
growthExchanges = {'4-aminobenzoic acid','EX_4abz(e)';'Acetate','EX_ac(e)';'Adenine','EX_ade(e)';'Adenosine','EX_adn(e)';'Biotin','EX_btn(e)';'Cholesterol','EX_chsterol(e)';'Citrate','EX_cit(e)';'CO2','EX_co2(e)';'Cobalamin','EX_adocbl(e)';'D-Glucose','EX_glc_D(e)';'Folate','EX_fol(e)';'Formate','EX_for(e)';'Fumarate','EX_fum(e)';'Glycerol','EX_glyc(e)';'Glycine','EX_gly(e)';'Guanine','EX_gua(e)';'H2S','EX_h2s(e)';'Hemin','EX_pheme(e)';'Hypoxanthine','EX_hxan(e)';'Inosine','EX_ins(e)';'L-alanine','EX_ala_L(e)';'L-arginine','EX_arg_L(e)';'L-asparagine','EX_asn_L(e)';'L-aspartate','EX_asp_L(e)';'L-cysteine','EX_cys_L(e)';'L-glutamate','EX_glu_L(e)';'L-glutamine','EX_gln_L(e)';'L-histidine','EX_his_L(e)';'L-isoleucine','EX_ile_L(e)';'L-Lactate','EX_lac_L(e)';'L-leucine','EX_leu_L(e)';'L-lysine','EX_lys_L(e)';'L-methionine','EX_met_L(e)';'L-phenylalanine','EX_phe_L(e)';'L-proline','EX_pro_L(e)';'L-serine','EX_ser_L(e)';'L-threonine','EX_thr_L(e)';'L-tryptophan','EX_trp_L(e)';'L-tyrosine','EX_tyr_L(e)';'L-valine','EX_val_L(e)';'Maltose','EX_malt(e)';'Menaquinone 8','EX_mqn8(e)';'N-Acetyl-D-glucosamine','EX_acgam(e)';'NH4','EX_nh4(e)';'Nicotinamide','EX_ncam(e)';'Nicotinic acid','EX_nac(e)';'Nitrate','EX_no3(e)';'Ornithine','EX_orn(e)';'Orotate','EX_orot(e)';'Pantothenate','EX_pnto_R(e)';'Putrescine','EX_ptrc(e)';'Pyridoxal','EX_pydx(e)';'Pyridoxal 5-phosphate','EX_pydx5p(e)';'Pyridoxamine','EX_pydam(e)';'Pyridoxine','EX_pydxn(e)';'Pyruvate','EX_pyr(e)';'Riboflavin','EX_ribflv(e)';'SO4','EX_so4(e)';'Spermidine','EX_spmd(e)';'Succinate','EX_succ(e)';'Thiamin','EX_thm(e)';'Thymidine','EX_thymd(e)';'Uracil','EX_ura(e)';'Xanthine','EX_xan(e)';'1,2-Diacyl-sn-glycerol (dioctadecanoyl, n-C18:0)','EX_12dgr180(e)';'2-deoxyadenosine','EX_dad_2(e)';'2-Oxobutanoate','EX_2obut(e)';'2-Oxoglutarate','EX_akg(e)';'3-methyl-2-oxopentanoate','EX_3mop(e)';'4-Hydroxybenzoate','EX_4hbz(e)';'5-Aminolevulinic acid','EX_5aop(e)';'Acetaldehyde','EX_acald(e)';'Anthranilic acid','EX_anth(e)';'Chorismate','EX_chor(e)';'Cys-Gly','EX_cgly(e)';'Cytidine','EX_cytd(e)';'Cytosine','EX_csn(e)';'D-Alanine','EX_ala_D(e)';'D-Arabinose','EX_arab_D(e)';'Deoxycytidine','EX_dcyt(e)';'Deoxyguanosine','EX_dgsn(e)';'Deoxyribose','EX_drib(e)';'Deoxyuridine','EX_duri(e)';'D-Galactose','EX_gal(e)';'D-glucuronate','EX_glcur(e)';'D-Mannose','EX_man(e)';'D-Xylose','EX_xyl_D(e)';'Ethanol','EX_etoh(e)';'Glycerol 3-phosphate','EX_glyc3p(e)';'Guanosine','EX_gsn(e)';'Indole','EX_indole(e)';'Lanosterol','EX_lanost(e)';'L-Arabinose','EX_arab_L(e)';'Laurate','EX_ddca(e)';'L-Homoserine','EX_hom_L(e)';'Linoleic acid','EX_lnlc(e)';'L-malate','EX_mal_L(e)';'L-Methionine S-oxide','EX_metsox_S_L(e)';'Menaquinone 7','EX_mqn7(e)';'meso-2,6-Diaminoheptanedioate','EX_26dap_M(e)';'N-acetyl-D-mannosamine','EX_acmana(e)';'N-Acetylneuraminate','EX_acnam(e)';'NMN','EX_nmn(e)';'Octadecanoate (n-C18:0)','EX_ocdca(e)';'Octadecenoate (n-C18:1)','EX_ocdcea(e)';'Oxidized glutathione','EX_gthox(e)';'Phenylacetic acid','EX_pac(e)';'Ribose','EX_rib_D(e)';'S-Adenosyl-L-methionine','EX_amet(e)';'Siroheme','EX_sheme(e)';'Tetradecanoate (n-C14:0)','EX_ttdca(e)';'Ubiquinone-8','EX_q8(e)';'Uridine','EX_uri(e)';'Thiosulfate','EX_tsul(e)';'Reduced glutathione','EX_gthrd(e)'};
growthExchanges=cell2table(growthExchanges);

% find microbe index in nutrient requirement table
mInd = find(ismember(nutrientTable.MicrobeID, microbeID));
if isempty(mInd)
    warning(['Microbe "', microbeID, '" not found in nutrient requirement data file.'])
    
    TruePositives = {};
    TrueNegatives = {};
    FalseNegatives = {};
    FalsePositives = {};
else
    % perform FVA to identify uptake metabolites
    % set BOF
    if ~any(ismember(model.rxns, biomassReaction)) || nargin < 3
        error(['Biomass reaction "', biomassReaction, '" not found in model.'])
    end
    model = changeObjective(model, biomassReaction);
    % set a low lower bound for biomass
    model = changeRxnBounds(model, biomassReaction, 1e-3, 'l');
    % remove positive values on lower bounds
    model.lb(find(model.lb>0))=0;
    % list exchange reactions
    exchanges = model.rxns(strncmp('EX_', model.rxns, 3));
    % set to the Western diet to avoid the dipeptides etc. interfering with
    % the computations.
    dietConstraints=readtable('WesternDietAGORA.txt');
    dietConstraints=table2cell(dietConstraints);
    dietConstraints(:,2)=cellstr(num2str(cell2mat(dietConstraints(:,2))));
    model=useDiet(model,dietConstraints);
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    % compute reaction essentiality
    % add demand reactions to make sure essential secretion is not counted
    modelOri=model;
    addDemand=model.mets(find(contains(model.mets,'[e]')));
    for i=1:length(addDemand)
        model=addDemandReaction(model,addDemand{i});
    end
    [grRatio, grRateKO, grRateWT, hasEffect, delRxn, fluxSolution] = singleRxnDeletion(model, 'FBA', exchanges);
    % identify essential nutrients
    essentialNutrients = exchanges(grRateKO==0);
    essentialNutrients(strcmp(essentialNutrients,'EX_biomass(e)'))=[];
    nonessentialNutrients = setdiff(exchanges, essentialNutrients);
    
    % which nutrients are essential according to in vitro data
    essentialData = find(table2array(nutrientTable(mInd, 2:end)) == 1);
    nonessentialData = find(table2array(nutrientTable(mInd, 2:end)) == -1);
    
    % essential nutrients
    TruePositives = intersect(table2cell(growthExchanges(essentialData, 2)), ...
        essentialNutrients);  % true positives (essential in vitro and in silico)
    FalseNegatives = intersect(table2cell(growthExchanges(essentialData, 2)), ...
        nonessentialNutrients);  % false negatives (essential in vitro not in silico)
    
    % nonessential nutrients
    TrueNegatives = intersect(table2cell(growthExchanges(nonessentialData, 2)), ...
        nonessentialNutrients);  % true positives (nonessential in vitro and in silico)
    % also consider exchanges that are not in model at all-clearly true
    % positives for nonessential nutrients
    cnt = size(TrueNegatives, 1) + 1;
    nonEssMets = table2cell(growthExchanges(nonessentialData, 2));
    for i = 1:length(nonEssMets)
        if isempty(find(ismember(model.rxns, nonEssMets{i})))
            TrueNegatives{cnt, 1} = nonEssMets{i};
            cnt = cnt + 1;
        end
    end
    FalsePositives = intersect(table2cell(growthExchanges(nonessentialData, 2)), ...
        essentialNutrients);  % false negatives (nonessential in vitro, essential in silico)
    model=modelOri;
end

% some false negatives can be replaced by certain metabolites-need to be
% tested again to ensure they are really false negatives
FNTested={
    'EX_acgam(e)'
    'EX_cys_L(e)'
    'EX_arg_L(e)'
    'EX_h2s(e)'
    'EX_met_L(e)'
    'EX_4abz(e)'
    'EX_adocbl(e)'
    'EX_nac(e)'
    'EX_ncam(e)'
    'EX_pydx(e)'
    'EX_pydxn(e)'
    'EX_pydam(e)'
    'EX_ptrc(e)'
    'EX_ins(e)'
    'EX_ura(e)'
    'EX_gua(e)'
    };
ReplFN={
    'EX_gam(e)','EX_acnam(e)','EX_acmana(e)','','','',''
    'EX_h2s(e)','EX_cgly(e)','EX_met_L(e)','','','',''
    'EX_orn(e)','','','','','',''
    'EX_cgly(e)','EX_cys_L(e)','EX_met_L(e)','','','',''
    'EX_metsox_S_L(e)','','','','','',''
    'EX_fol(e)','','','','','',''
    'EX_cbl1(e)','','','','','',''
    'EX_nmn(e)','EX_ncam(e)','','','','',''
    'EX_nmn(e)','EX_nac(e)','','','','',''
    'EX_pydam(e)','EX_pydx5p(e)','EX_pydxn(e)','','','',''
    'EX_pydam(e)','EX_pydx5p(e)','EX_pydx(e)','','','',''
    'EX_pydxn(e)','EX_pydx5p(e)','EX_pydx(e)','','','',''
    'EX_orn(e)','','','','','',''
    'EX_adn(e)','EX_ade(e)','EX_gua(e)','EX_uri(e)','EX_ura(e)','EX_hxan(e)','EX_xan(e)'
    'EX_adn(e)','EX_ade(e)','EX_gua(e)','EX_uri(e)','EX_ins(e)','EX_hxan(e)','EX_xan(e)'
    'EX_adn(e)','EX_ade(e)','EX_ura(e)','EX_uri(e)','EX_ins(e)','EX_hxan(e)','EX_xan(e)'
    };
for i=1:length(FNTested)
    if ~isempty(find(ismember(FalseNegatives, FNTested{i})))
        modelOri=model;
        model = changeRxnBounds(model, FNTested{i}, 0, 'l');
        model = changeRxnBounds(model, ReplFN(i,1:end), 0, 'l');
        FBA=optimizeCbModel(model,'max');
        if FBA.f<tol
            FalseNegatives(find(strcmp(FalseNegatives(:,1),FNTested{i})))=[];
        end
        model=modelOri;
    end
end

% warn about false negatives
if ~isempty(FalseNegatives)
    for i = 1:length(FalseNegatives)
        warning(['Nutrient "', FalseNegatives{i}, '" is non-essential in microbe "', microbeID, '" but should be essential.'])
    end
end
% replace reaction IDs with metabolite names
metaboliteDatabase = readtable('MetaboliteDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
metaboliteDatabase=table2cell(metaboliteDatabase);

% prepare output
if exist('TruePositives','var')
    TruePositives = TruePositives(~cellfun(@isempty, TruePositives));
    TruePositives=strrep(TruePositives,'EX_','');
    TruePositives=strrep(TruePositives,'(e)','');
    for i=1:length(TruePositives)
        TruePositives{i}=metaboliteDatabase{find(strcmp(metaboliteDatabase(:,1),TruePositives{i})),2};
    end
else
    TruePositives = {};
end

if exist('TrueNegatives','var')
    TrueNegatives = TrueNegatives(~cellfun(@isempty, TrueNegatives));
    TrueNegatives=strrep(TrueNegatives,'EX_','');
    TrueNegatives=strrep(TrueNegatives,'(e)','');
    for i=1:length(TrueNegatives)
        TrueNegatives{i}=metaboliteDatabase{find(strcmp(metaboliteDatabase(:,1),TrueNegatives{i})),2};
    end
else
    TrueNegatives = {};
end

if exist('FalsePositives','var')
    FalsePositives = FalsePositives(~cellfun(@isempty, FalsePositives));
    FalsePositives=strrep(FalsePositives,'EX_','');
    FalsePositives=strrep(FalsePositives,'(e)','');
    for i=1:length(FalsePositives)
        FalsePositives{i}=metaboliteDatabase{find(strcmp(metaboliteDatabase(:,1),FalsePositives{i})),2};
    end
else
    FalsePositives = {};
end

if exist('FalseNegatives','var')
    FalseNegatives = FalseNegatives(~cellfun(@isempty, FalseNegatives));
    FalseNegatives=strrep(FalseNegatives,'EX_','');
    FalseNegatives=strrep(FalseNegatives,'(e)','');
    for i=1:length(FalseNegatives)
        FalseNegatives{i}=metaboliteDatabase{find(strcmp(metaboliteDatabase(:,1),FalseNegatives{i})),2};
    end
else
    FalseNegatives = {};
end

% warn about false positives
if ~isempty(FalsePositives)
    for i = 1:length(FalsePositives)
        warning(['Nutrient "', FalsePositives{i}, '" is essential in microbe "', microbeID, '" but should be nonessential.'])
    end
end

Sensitivity=(length(TruePositives))/(length(TruePositives)+length(FalseNegatives));
Specificity=(length(TrueNegatives))/(length(TrueNegatives)+length(FalsePositives));
Accuracy=(length(TruePositives)+length(TrueNegatives))/((length(TruePositives)+length(FalseNegatives)+length(TrueNegatives)+length(FalsePositives)));
end
