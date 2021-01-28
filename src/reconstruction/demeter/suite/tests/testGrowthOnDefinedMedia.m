function [growsOnDefinedMedium,constrainedModel,growthOnKnownCarbonSources] = testGrowthOnDefinedMedia(model, microbeID, biomassReaction, inputDataFolder)
% Tests growth on a minimal medium retrieved from the experimental data on
% growth requirements. The output is the calculated growth rates.
% If the model can grow on the defined medium, a minimal medium is also
% computed and the list of essential exchanges as well as a model
% constrained with these exchanges are returned.
%
% INPUT
% model                         COBRA model structure
% biomassReaction               String listing the biomass reaction
% inputDataFolder               Folder with experimental data and database files
%                               to load
%
% OUTPUT
% growsOnDefinedMedium          Bool if growth on defined medium yes or no
% essentialExchanges            Exchanges that need to be open to enable growth
% constrainedModel              Model constrained with essential exchanges (anaerobic)
% growthOnKnownCarbonSources
%
% Almut Heinken, November 2018

% Test if model can grow
% set "unlimited" constraints
model = changeRxnBounds(model, model.rxns(strncmp('EX_', model.rxns, 3)), -1000, 'l');
model = changeRxnBounds(model, model.rxns(strncmp('EX_', model.rxns, 3)), 1000, 'u');

% remove positive values on lower bounds
model.lb(find(model.lb>0))=0;

% read nutrient requirement tables
growthExchanges = {'Nutrient','ExchangeReaction';'4-aminobenzoic acid','EX_4abz(e)';'Acetate','EX_ac(e)';'Adenine','EX_ade(e)';'Adenosine','EX_adn(e)';'Biotin','EX_btn(e)';'Cholesterol','EX_chsterol(e)';'Citrate','EX_cit(e)';'CO2','EX_co2(e)';'Cobalamin','EX_adocbl(e)';'D-Glucose','EX_glc_D(e)';'Folate','EX_fol(e)';'Formate','EX_for(e)';'Fumarate','EX_fum(e)';'Glycerol','EX_glyc(e)';'Glycine','EX_gly(e)';'Guanine','EX_gua(e)';'H2S','EX_h2s(e)';'Hemin','EX_pheme(e)';'Hypoxanthine','EX_hxan(e)';'Inosine','EX_ins(e)';'L-alanine','EX_ala_L(e)';'L-arginine','EX_arg_L(e)';'L-asparagine','EX_asn_L(e)';'L-aspartate','EX_asp_L(e)';'L-cysteine','EX_cys_L(e)';'L-glutamate','EX_glu_L(e)';'L-glutamine','EX_gln_L(e)';'L-histidine','EX_his_L(e)';'L-isoleucine','EX_ile_L(e)';'L-Lactate','EX_lac_L(e)';'L-leucine','EX_leu_L(e)';'L-lysine','EX_lys_L(e)';'L-methionine','EX_met_L(e)';'L-phenylalanine','EX_phe_L(e)';'L-proline','EX_pro_L(e)';'L-serine','EX_ser_L(e)';'L-threonine','EX_thr_L(e)';'L-tryptophan','EX_trp_L(e)';'L-tyrosine','EX_tyr_L(e)';'L-valine','EX_val_L(e)';'Maltose','EX_malt(e)';'Menaquinone 8','EX_mqn8(e)';'N-Acetyl-D-glucosamine','EX_acgam(e)';'NH4','EX_nh4(e)';'Nicotinamide','EX_ncam(e)';'Nicotinic acid','EX_nac(e)';'Nitrate','EX_no3(e)';'Ornithine','EX_orn(e)';'Orotate','EX_orot(e)';'Pantothenate','EX_pnto_R(e)';'Putrescine','EX_ptrc(e)';'Pyridoxal','EX_pydx(e)';'Pyridoxal 5-phosphate','EX_pydx5p(e)';'Pyridoxamine','EX_pydam(e)';'Pyridoxine','EX_pydxn(e)';'Pyruvate','EX_pyr(e)';'Riboflavin','EX_ribflv(e)';'SO4','EX_so4(e)';'Spermidine','EX_spmd(e)';'Succinate','EX_succ(e)';'Thiamin','EX_thm(e)';'Thymidine','EX_thymd(e)';'Uracil','EX_ura(e)';'Xanthine','EX_xan(e)';'1,2-Diacyl-sn-glycerol (dioctadecanoyl, n-C18:0)','EX_12dgr180(e)';'2-deoxyadenosine','EX_dad_2(e)';'2-Oxobutanoate','EX_2obut(e)';'2-Oxoglutarate','EX_akg(e)';'3-methyl-2-oxopentanoate','EX_3mop(e)';'4-Hydroxybenzoate','EX_4hbz(e)';'5-Aminolevulinic acid','EX_5aop(e)';'Acetaldehyde','EX_acald(e)';'Anthranilic acid','EX_anth(e)';'Chorismate','EX_chor(e)';'Cys-Gly','EX_cgly(e)';'Cytidine','EX_cytd(e)';'Cytosine','EX_csn(e)';'D-Alanine','EX_ala_D(e)';'D-Arabinose','EX_arab_D(e)';'Deoxycytidine','EX_dcyt(e)';'Deoxyguanosine','EX_dgsn(e)';'Deoxyribose','EX_drib(e)';'Deoxyuridine','EX_duri(e)';'D-Galactose','EX_gal(e)';'D-glucuronate','EX_glcur(e)';'D-Mannose','EX_man(e)';'D-Xylose','EX_xyl_D(e)';'Ethanol','EX_etoh(e)';'Glycerol 3-phosphate','EX_glyc3p(e)';'Guanosine','EX_gsn(e)';'Indole','EX_indole(e)';'Lanosterol','EX_lanost(e)';'L-Arabinose','EX_arab_L(e)';'Laurate','EX_ddca(e)';'L-Homoserine','EX_hom_L(e)';'Linoleic acid','EX_lnlc(e)';'L-malate','EX_mal_L(e)';'L-Methionine S-oxide','EX_metsox_S_L(e)';'Menaquinone 7','EX_mqn7(e)';'meso-2,6-Diaminoheptanedioate','EX_26dap_M(e)';'N-acetyl-D-mannosamine','EX_acmana(e)';'N-Acetylneuraminate','EX_acnam(e)';'NMN','EX_nmn(e)';'Octadecanoate (n-C18:0)','EX_ocdca(e)';'Octadecenoate (n-C18:1)','EX_ocdcea(e)';'Oxidized glutathione','EX_gthox(e)';'Phenylacetic acid','EX_pac(e)';'Ribose','EX_rib_D(e)';'S-Adenosyl-L-methionine','EX_amet(e)';'Siroheme','EX_sheme(e)';'Tetradecanoate (n-C14:0)','EX_ttdca(e)';'Ubiquinone-8','EX_q8(e)';'Uridine','EX_uri(e)';'Thiosulfate','EX_tsul(e)';'Reduced glutathione','EX_gthrd(e)'};
growthRequirements = readtable([inputDataFolder filesep 'GrowthRequirementsTable.txt'], 'ReadVariableNames', false, 'Delimiter', '\t');
growthRequirements = table2cell(growthRequirements);
% remove the reference columns
for i=1:11
    if ~isempty(find(strcmp(['Ref' num2str(i)],growthRequirements(1,:))))
        growthRequirements(:,find(strcmp(['Ref' num2str(i)],growthRequirements(1,:))))=[];
    end
end

% Define the list of metabolites required by at least one AGORA model for
% growth
essentialMetabolites = {'EX_12dgr180(e)'; 'EX_26dap_M(e)'; 'EX_2dmmq8(e)'; 'EX_2obut(e)'; 'EX_3mop(e)'; 'EX_4abz(e)'; 'EX_4hbz(e)'; 'EX_ac(e)'; 'EX_acgam(e)'; 'EX_acmana(e)'; 'EX_acnam(e)'; 'EX_ade(e)'; 'EX_adn(e)'; 'EX_adocbl(e)'; 'EX_ala_D(e)'; 'EX_ala_L(e)'; 'EX_amet(e)'; 'EX_amp(e)'; 'EX_arab_D(e)'; 'EX_arab_L(e)'; 'EX_arg_L(e)'; 'EX_asn_L(e)'; 'EX_btn(e)'; 'EX_ca2(e)'; 'EX_cbl1(e)'; 'EX_cgly(e)'; 'EX_chor(e)'; 'EX_chsterol(e)'; 'EX_cit(e)'; 'EX_cl(e)'; 'EX_cobalt2(e)'; 'EX_csn(e)'; 'EX_cu2(e)'; 'EX_cys_L(e)'; 'EX_cytd(e)'; 'EX_dad_2(e)'; 'EX_dcyt(e)'; 'EX_ddca(e)'; 'EX_dgsn(e)'; 'EX_fald(e)'; 'EX_fe2(e)'; 'EX_fe3(e)'; 'EX_fol(e)'; 'EX_for(e)'; 'EX_gal(e)'; 'EX_glc_D(e)'; 'EX_gln_L(e)'; 'EX_glu_L(e)'; 'EX_gly(e)'; 'EX_glyc(e)'; 'EX_glyc3p(e)'; 'EX_gsn(e)'; 'EX_gthox(e)'; 'EX_gthrd(e)'; 'EX_gua(e)'; 'EX_h(e)'; 'EX_h2o(e)'; 'EX_h2s(e)'; 'EX_his_L(e)'; 'EX_hxan(e)'; 'EX_ile_L(e)'; 'EX_k(e)'; 'EX_lanost(e)'; 'EX_leu_L(e)'; 'EX_lys_L(e)'; 'EX_malt(e)'; 'EX_met_L(e)'; 'EX_mg2(e)'; 'EX_mn2(e)'; 'EX_mqn7(e)'; 'EX_mqn8(e)'; 'EX_nac(e)'; 'EX_ncam(e)'; 'EX_nmn(e)'; 'EX_no2(e)'; 'EX_ocdca(e)'; 'EX_ocdcea(e)'; 'EX_orn(e)'; 'EX_phe_L(e)'; 'EX_pheme(e)'; 'EX_pi(e)'; 'EX_pnto_R(e)'; 'EX_pro_L(e)'; 'EX_ptrc(e)'; 'EX_pydx(e)'; 'EX_pydxn(e)'; 'EX_q8(e)'; 'EX_rib_D(e)'; 'EX_ribflv(e)'; 'EX_ser_L(e)'; 'EX_sheme(e)'; 'EX_so4(e)'; 'EX_spmd(e)'; 'EX_thm(e)'; 'EX_thr_L(e)'; 'EX_thymd(e)'; 'EX_trp_L(e)'; 'EX_ttdca(e)'; 'EX_tyr_L(e)'; 'EX_ura(e)'; 'EX_val_L(e)'; 'EX_xan(e)'; 'EX_xyl_D(e)'; 'EX_zn2(e)'};

% Get essential metabolites that are not in the growth requirements table
MissingUptakes = setdiff(essentialMetabolites, growthExchanges(2:end,2));

% find microbe index in nutrient requirement table
mInd = find(ismember(growthRequirements(:,1), microbeID));

% check if experimental data for the organism is available
if any(find(strcmp(growthRequirements(mInd, :),'-1'))) || any(find(strcmp(growthRequirements(mInd, :),'1')))
    experimentalDataExists=1;
else
    experimentalDataExists=0;
end

% so test is not run without any experimental data available
if experimentalDataExists
    
    % delete metabolites that are not essential according to experimental data
    nonessentialData = growthRequirements(1,find(strcmp(growthRequirements(mInd, :),'-1')));
    [C,IA,IB] = intersect(growthExchanges,nonessentialData,'stable');
    growthExchanges(IA,:)=[];
    
    % take all remaining diet exchanges and assume uptake rate of 1 mmol*gDW-1*hr-1
    diet(:,1)=growthExchanges(2:end,2);
    diet(:,2)= {'-1'};
    % Add compounds that are essential but not in the growth requirements table
    % to the simulated defined medium
    CLength = size(diet, 1);
    for i = 1:length(MissingUptakes)
        diet{CLength + i, 1} = MissingUptakes{i};
        diet{CLength + i, 2} = {'-1'};
    end
    % remove the ones not in the model
    [notInModel,IA] = setdiff(diet(:,1),model.rxns,'stable');
    diet(IA,:)=[];
    model=useDiet(model,diet,'AGORA');
    
    % also set a carbon source to allow growth
    carbonSourcesTable = readtable('CarbonSourcesTable.txt', 'Delimiter', '\t');
    % remove the reference columns
    for i=1:11
        if ismember(['Ref' num2str(i)],carbonSourcesTable.Properties.VariableNames)
            carbonSourcesTable.(['Ref' num2str(i)])=[];
        end
    end
    carbonSourcesExchanges = {'2-oxobutyrate','EX_2obut(e)','','','','','','','','','','','','','','';'2-oxoglutarate','EX_akg(e)','','','','','','','','','','','','','','';'4-Hydroxyproline','EX_4hpro_LT(e)','','','','','','','','','','','','','','';'Acetate','EX_ac(e)','','','','','','','','','','','','','','';'Alginate','EX_algin(e)','','','','','','','','','','','','','','';'alpha-Mannan','EX_mannan(e)','','','','','','','','','','','','','','';'Amylopectin','EX_amylopect900(e)','','','','','','','','','','','','','','';'Amylose','EX_amylose300(e)','','','','','','','','','','','','','','';'Arabinan','EX_arabinan101(e)','','','','','','','','','','','','','','';'Arabinogalactan','EX_arabinogal(e)','','','','','','','','','','','','','','';'Arabinoxylan','EX_arabinoxyl(e)','','','','','','','','','','','','','','';'Arbutin','EX_arbt(e)','','','','','','','','','','','','','','';'beta-Glucan','EX_bglc(e)','','','','','','','','','','','','','','';'Butanol','EX_btoh(e)','','','','','','','','','','','','','','';'Butyrate','EX_but(e)','','','','','','','','','','','','','','';'Cellobiose','EX_cellb(e)','','','','','','','','','','','','','','';'Cellotetrose','EX_cellttr(e)','','','','','','','','','','','','','','';'Cellulose','EX_cellul(e)','','','','','','','','','','','','','','';'Chitin','EX_chitin(e)','','','','','','','','','','','','','','';'Choline','EX_chol(e)','','','','','','','','','','','','','','';'Chondroitin sulfate','EX_cspg_a(e)','EX_cspg_b(e)','EX_cspg_c(e)','','','','','','','','','','','','';'cis-Aconitate','EX_acon_C(e)','','','','','','','','','','','','','','';'Citrate','EX_cit(e)','','','','','','','','','','','','','','';'CO2','EX_co2(e)','','','','','','','','','','','','','','';'D-arabinose','EX_arab_D(e)','','','','','','','','','','','','','','';'Deoxyribose','EX_drib(e)','','','','','','','','','','','','','','';'Dextran','EX_dextran40(e)','','','','','','','','','','','','','','';'Dextrin','EX_dextrin(e)','','','','','','','','','','','','','','';'D-Fructuronate','EX_fruur(e)','','','','','','','','','','','','','','';'D-galacturonic acid','EX_galur(e)','','','','','','','','','','','','','','';'D-gluconate (Entner-Doudoroff pathway)','EX_glcn(e)','','','','','','','','','','','','','','';'D-glucosamine','EX_gam(e)','','','','','','','','','','','','','','';'D-glucose','EX_glc_D(e)','','','','','','','','','','','','','','';'D-glucuronic acid','EX_glcur(e)','','','','','','','','','','','','','','';'D-maltose','EX_malt(e)','','','','','','','','','','','','','','';'D-Psicose','EX_psics_D(e)','','','','','','','','','','','','','','';'D-ribose','EX_rib_D(e)','','','','','','','','','','','','','','';'D-Sorbitol','EX_sbt_D(e)','','','','','','','','','','','','','','';'D-Tagatose','EX_tagat_D(e)','','','','','','','','','','','','','','';'D-Tagaturonate','EX_tagur(e)','','','','','','','','','','','','','','';'D-Turanose','EX_turan_D(e)','','','','','','','','','','','','','','';'D-xylose','EX_xyl_D(e)','','','','','','','','','','','','','','';'Erythritol','EX_ethrtl(e)','','','','','','','','','','','','','','';'Ethanolamine','EX_etha(e)','','','','','','','','','','','','','','';'Fructooligosaccharides','EX_kesto(e)','EX_kestopt(e)','EX_kestottr(e)','','','','','','','','','','','','';'Fructose','EX_fru(e)','','','','','','','','','','','','','','';'Fumarate','EX_fum(e)','','','','','','','','','','','','','','';'Galactan','EX_galactan(e)','','','','','','','','','','','','','','';'Galactomannan','EX_galmannan(e)','','','','','','','','','','','','','','';'Galactosamine','EX_galam(e)','','','','','','','','','','','','','','';'Galactose','EX_gal(e)','','','','','','','','','','','','','','';'Glucomannan','EX_glcmannan(e)','','','','','','','','','','','','','','';'Glycerol','EX_glyc(e)','','','','','','','','','','','','','','';'Glycine','EX_gly(e)','','','','','','','','','','','','','','';'Glycogen','EX_glygn2(e)','','','','','','','','','','','','','','';'Heparin','EX_hspg(e)','','','','','','','','','','','','','','';'Homogalacturonan','EX_homogal(e)','','','','','','','','','','','','','','';'Hyaluronan','EX_ha(e)','','','','','','','','','','','','','','';'Indole','EX_indole(e)','','','','','','','','','','','','','','';'Inosine','EX_ins(e)','','','','','','','','','','','','','','';'Inositol','EX_inost(e)','','','','','','','','','','','','','','';'Inulin','EX_inulin(e)','','','','','','','','','','','','','','';'Isobutyrate','EX_isobut(e)','','','','','','','','','','','','','','';'Isomaltose','EX_isomal(e)','','','','','','','','','','','','','','';'Isovalerate','EX_isoval(e)','','','','','','','','','','','','','','';'Lactose','EX_lcts(e)','','','','','','','','','','','','','','';'L-alanine','EX_ala_L(e)','','','','','','','','','','','','','','';'Laminarin','EX_lmn30(e)','','','','','','','','','','','','','','';'L-arabinose','EX_arab_L(e)','','','','','','','','','','','','','','';'L-arabitol','EX_abt(e)','','','','','','','','','','','','','','';'L-arginine','EX_arg_L(e)','','','','','','','','','','','','','','';'L-asparagine','EX_asn_L(e)','','','','','','','','','','','','','','';'L-aspartate','EX_asp_L(e)','','','','','','','','','','','','','','';'L-cysteine','EX_cys_L(e)','','','','','','','','','','','','','','';'Levan','EX_levan1000(e)','','','','','','','','','','','','','','';'L-fucose','EX_fuc_L(e)','','','','','','','','','','','','','','';'L-glutamate','EX_glu_L(e)','','','','','','','','','','','','','','';'L-glutamine','EX_gln_L(e)','','','','','','','','','','','','','','';'L-histidine','EX_his_L(e)','','','','','','','','','','','','','','';'Lichenin','EX_lichn(e)','','','','','','','','','','','','','','';'L-Idonate','EX_idon_L(e)','','','','','','','','','','','','','','';'L-isoleucine','EX_ile_L(e)','','','','','','','','','','','','','','';'L-leucine','EX_leu_L(e)','','','','','','','','','','','','','','';'L-lysine','EX_lys_L(e)','','','','','','','','','','','','','','';'L-lyxose','EX_lyx_L(e)','','','','','','','','','','','','','','';'L-malate','EX_mal_L(e)','','','','','','','','','','','','','','';'L-methionine','EX_met_L(e)','','','','','','','','','','','','','','';'L-ornithine','EX_orn(e)','','','','','','','','','','','','','','';'L-phenylalanine','EX_phe_L(e)','','','','','','','','','','','','','','';'L-proline','EX_pro_L(e)','','','','','','','','','','','','','','';'L-rhamnose','EX_rmn(e)','','','','','','','','','','','','','','';'L-serine','EX_ser_L(e)','','','','','','','','','','','','','','';'L-Sorbose','EX_srb_L(e)','','','','','','','','','','','','','','';'L-threonine','EX_thr_L(e)','','','','','','','','','','','','','','';'L-tryptophan','EX_trp_L(e)','','','','','','','','','','','','','','';'L-tyrosine','EX_tyr_L(e)','','','','','','','','','','','','','','';'L-valine','EX_val_L(e)','','','','','','','','','','','','','','';'Mannitol','EX_mnl(e)','','','','','','','','','','','','','','';'Mannose','EX_man(e)','','','','','','','','','','','','','','';'Melibiose','EX_melib(e)','','','','','','','','','','','','','','';'Mucin','EX_T_antigen(e)','EX_Tn_antigen(e)','EX_core2(e)','EX_core3(e)','EX_core4(e)','EX_core5(e)','EX_core6(e)','EX_core7(e)','EX_core8(e)','EX_dsT_antigen(e)','EX_dsT_antigen(e)','EX_gncore1(e)','EX_gncore2(e)','EX_sT_antigen(e)','EX_sTn_antigen(e)';'N-acetylgalactosamine','EX_acgal(e)','','','','','','','','','','','','','','';'N-acetylglucosamine','EX_acgam(e)','','','','','','','','','','','','','','';'N-Acetylmannosamine','EX_acmana(e)','','','','','','','','','','','','','','';'N-acetylneuraminic acid','EX_acnam(e)','','','','','','','','','','','','','','';'Orotate','EX_orot(e)','','','','','','','','','','','','','','';'Oxalate','EX_oxa(e)','','','','','','','','','','','','','','';'Oxaloacetate','EX_oaa(e)','','','','','','','','','','','','','','';'Pectic galactan','EX_pecticgal(e)','','','','','','','','','','','','','','';'Pectin','EX_pect(e)','','','','','','','','','','','','','','';'Phenylacetate','EX_pac(e)','','','','','','','','','','','','','','';'Propionate','EX_ppa(e)','','','','','','','','','','','','','','';'Pullulan','EX_pullulan1200(e)','','','','','','','','','','','','','','';'Pyruvate','EX_pyr(e)','','','','','','','','','','','','','','';'Raffinose','EX_raffin(e)','','','','','','','','','','','','','','';'Resistant starch','EX_starch1200(e)','','','','','','','','','','','','','','';'Rhamnogalacturonan I','EX_rhamnogalurI(e)','','','','','','','','','','','','','','';'Rhamnogalacturonan II','EX_rhamnogalurII(e)','','','','','','','','','','','','','','';'Salicin','EX_salcn(e)','','','','','','','','','','','','','','';'Stachyose','EX_stys(e)','','','','','','','','','','','','','','';'Starch','EX_strch1(e)','','','','','','','','','','','','','','';'Stickland reaction','EX_pro_L(e)','EX_gly(e)','EX_ala_L(e)','EX_ile_L(e)','EX_leu_L(e)','EX_tyr_L(e)','EX_trp_L(e)','EX_val_L(e)','EX_glyb(e)','','','','','','';'Succinate','EX_succ(e)','','','','','','','','','','','','','','';'Sucrose','EX_sucr(e)','','','','','','','','','','','','','','';'Trehalose','EX_tre(e)','','','','','','','','','','','','','','';'Urea','EX_urea(e)','','','','','','','','','','','','','','';'Xylan','EX_xylan(e)','','','','','','','','','','','','','','';'Xylitol','EX_xylt(e)','','','','','','','','','','','','','','';'Xyloglucan','EX_xyluglc(e)','','','','','','','','','','','','','','';'Xylooligosaccharides','EX_xylottr(e)','','','','','','','','','','','','','',''};
    carbonSourcesExchanges=cell2table(carbonSourcesExchanges);
    
    % find microbe index in CS table
    mInd = find(ismember(carbonSourcesTable.MicrobeID, microbeID));
    rxns = carbonSourcesExchanges(table2array(carbonSourcesTable(mInd, 2:end)) == 1, 2:end);
    rxns=table2cell(rxns);
    
    % provide a sulfur, a phosphate, and a nitrogen source, otherwise no growth even for
    % species without requirements
    model=changeRxnBounds(model,'EX_nh4(e)',-10,'l');
    model=changeRxnBounds(model,'EX_pi(e)',-10,'l');
    model=changeRxnBounds(model,'EX_so4(e)',-10,'l');
    
    % set objective
    if nargin < 2
        error('Please provide biomass reaction')
    end
    if ~any(ismember(model.rxns, biomassReaction))
        error(['Biomass reaction "', biomassReaction, '" not found in model.'])
    else
        model = changeObjective(model, biomassReaction);
    end
    
    % add carbon source
    if ~isempty(rxns)
        CS=rxns;
    else
        if any(strcmp(model.rxns,'EX_glc_D(e)'))
            CS={'EX_glc_D(e)'};
        else
            % try aspartate..may work
            CS={'EX_asp_L(e)'};
        end
    end
    
    tol=1e-6;
    % test growth on aerobic environment on different carbon sources
    model = changeRxnBounds(model, 'EX_o2(e)', -10, 'l');
    % simulate
    for i=1:size(CS,1)
        modelTest=changeRxnBounds(model,CS{i,1},-10,'l');
        FBA = optimizeCbModel(modelTest, 'max');
        solutions(i,1)=FBA.f;
    end
    if any(solutions > tol)
        fprintf('Model grows on at least one carbon source on defined medium for the organism (aerobic), flux through BOF: %d mmol/gDW/h\n', FBA.f)
        growsOnDefinedMedium=1;
        [m,index]=max(solutions(:,1));
        constrainedModel=changeRxnBounds(model,CS{index,1},-1,'l');
        growthOnKnownCarbonSources(:,1)=CS(:,1);
        growthOnKnownCarbonSources(:,2)=cellstr(num2str(solutions(:,1)));
    else
        warning('Model cannot grow on defined medium for the organism (aerobic)')
        growsOnDefinedMedium=0;
        growthOnKnownCarbonSources = {};
        constrainedModel=changeRxnBounds(model,CS{1,1},-10,'l');
    end
    
    % test growth on anaerobic environment
    model = changeRxnBounds(model, 'EX_o2(e)', 0, 'l');
    % simulate
    for i=1:size(CS,1)
        modelTest=changeRxnBounds(model,CS{i,1},-10,'l');
        FBA = optimizeCbModel(modelTest, 'max');
        solutions(i,1)=FBA.f;
    end
    if any(solutions > tol)
        fprintf('Model grows on at least one carbon source on defined medium for the organism (anaerobic), flux through BOF: %d mmol/gDW/h\n', FBA.f)
        growthOnKnownCarbonSources(:,3)=cellstr(num2str(solutions(:,1)));
        [m,index]=max(solutions);
        constrainedModel=changeRxnBounds(model,CS{index,1},-1,'l');
    else
        warning('Model cannot grow on defined medium for the organism (anaerobic)')
        growthOnKnownCarbonSources(:,3)={'0'};
    end
else
    fprintf('No experimental data on growth requirements available for the organism.\n')
    growsOnDefinedMedium='NA';
    constrainedModel = {};
    growthOnKnownCarbonSources = {};
end

end