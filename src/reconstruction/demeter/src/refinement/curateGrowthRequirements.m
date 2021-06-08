function [model, addedMismatchRxns, deletedMismatchRxns] = curateGrowthRequirements(model, microbeID, database, inputDataFolder)
% Takes the growth requirements of an organism (if known) as input and
% refines the reconstruction accordingly. Reactions are gap-filled and/or
% delete to reconcile mismatches between experimental and in silico
% metabolite essentiality. These curation steps were determined manually.
% The first step is printing the organism's biomass components and 
% subsequent evaluation which ones are required/ not required by the model.
% There are four possible cases:
% 1) essential in vivo and not in BOF -> add to BOF and add transporter/
% remove unannotated biosynthesis reactions
% 2) essential in vivo and in BOF -> add transporter/
% remove unannotated biosynthesis reactions
% 3) nonessential in vivo and not in BOF -> OK
% 4) nonessential in vivo and in BOF -> if pathway is mostly present:
% gapfill. If pathway is not present: remove from BOF

% USAGE
%   [model, addedMismatchRxns, deletedMismatchRxns] = curateGrowthRequirements(model, microbeID, database, inputDataFolder)
%
% INPUTS
% model                 COBRA model structure
% microbeID             ID of the reconstructed microbe that serves as the 
%                       reconstruction name and to identify it in input tables
% database              rBioNet reaction database containing min. 3 columns:
%                       Column 1: reaction abbreviation, Column 2: reaction
%                       name, Column 3: reaction formula.
% inputDataFolder       Folder with input tables with experimental data and
%                       databases that inform the refinement process
%
% OUTPUTS
% model                 COBRA model structure
% addedMismatchRxns     Reactions added to conform to growth requirements
% deletedMismatchRxns   Reactions deleted to conform to growth requirements
%
% .. Authors:
%       - Almut Heinken, 2016-2020

% read in the growth requirements data
growthExchanges = {'4-aminobenzoic acid','EX_4abz(e)';'Acetate','EX_ac(e)';'Adenine','EX_ade(e)';'Adenosine','EX_adn(e)';'Biotin','EX_btn(e)';'Cholesterol','EX_chsterol(e)';'Citrate','EX_cit(e)';'CO2','EX_co2(e)';'Cobalamin','EX_adocbl(e)';'D-Glucose','EX_glc_D(e)';'Folate','EX_fol(e)';'Formate','EX_for(e)';'Fumarate','EX_fum(e)';'Glycerol','EX_glyc(e)';'Glycine','EX_gly(e)';'Guanine','EX_gua(e)';'H2S','EX_h2s(e)';'Hemin','EX_pheme(e)';'Hypoxanthine','EX_hxan(e)';'Inosine','EX_ins(e)';'L-alanine','EX_ala_L(e)';'L-arginine','EX_arg_L(e)';'L-asparagine','EX_asn_L(e)';'L-aspartate','EX_asp_L(e)';'L-cysteine','EX_cys_L(e)';'L-glutamate','EX_glu_L(e)';'L-glutamine','EX_gln_L(e)';'L-histidine','EX_his_L(e)';'L-isoleucine','EX_ile_L(e)';'L-Lactate','EX_lac_L(e)';'L-leucine','EX_leu_L(e)';'L-lysine','EX_lys_L(e)';'L-methionine','EX_met_L(e)';'L-phenylalanine','EX_phe_L(e)';'L-proline','EX_pro_L(e)';'L-serine','EX_ser_L(e)';'L-threonine','EX_thr_L(e)';'L-tryptophan','EX_trp_L(e)';'L-tyrosine','EX_tyr_L(e)';'L-valine','EX_val_L(e)';'Maltose','EX_malt(e)';'Menaquinone 8','EX_mqn8(e)';'N-Acetyl-D-glucosamine','EX_acgam(e)';'NH4','EX_nh4(e)';'Nicotinamide','EX_ncam(e)';'Nicotinic acid','EX_nac(e)';'Nitrate','EX_no3(e)';'Ornithine','EX_orn(e)';'Orotate','EX_orot(e)';'Pantothenate','EX_pnto_R(e)';'Putrescine','EX_ptrc(e)';'Pyridoxal','EX_pydx(e)';'Pyridoxal 5-phosphate','EX_pydx5p(e)';'Pyridoxamine','EX_pydam(e)';'Pyridoxine','EX_pydxn(e)';'Pyruvate','EX_pyr(e)';'Riboflavin','EX_ribflv(e)';'SO4','EX_so4(e)';'Spermidine','EX_spmd(e)';'Succinate','EX_succ(e)';'Thiamin','EX_thm(e)';'Thymidine','EX_thymd(e)';'Uracil','EX_ura(e)';'Xanthine','EX_xan(e)';'1,2-Diacyl-sn-glycerol (dioctadecanoyl, n-C18:0)','EX_12dgr180(e)';'2-deoxyadenosine','EX_dad_2(e)';'2-Oxobutanoate','EX_2obut(e)';'2-Oxoglutarate','EX_akg(e)';'3-methyl-2-oxopentanoate','EX_3mop(e)';'4-Hydroxybenzoate','EX_4hbz(e)';'5-Aminolevulinic acid','EX_5aop(e)';'Acetaldehyde','EX_acald(e)';'Anthranilic acid','EX_anth(e)';'Chorismate','EX_chor(e)';'Cys-Gly','EX_cgly(e)';'Cytidine','EX_cytd(e)';'Cytosine','EX_csn(e)';'D-Alanine','EX_ala_D(e)';'D-Arabinose','EX_arab_D(e)';'Deoxycytidine','EX_dcyt(e)';'Deoxyguanosine','EX_dgsn(e)';'Deoxyribose','EX_drib(e)';'Deoxyuridine','EX_duri(e)';'D-Galactose','EX_gal(e)';'D-glucuronate','EX_glcur(e)';'D-Mannose','EX_man(e)';'D-Xylose','EX_xyl_D(e)';'Ethanol','EX_etoh(e)';'Glycerol 3-phosphate','EX_glyc3p(e)';'Guanosine','EX_gsn(e)';'Indole','EX_indole(e)';'Lanosterol','EX_lanost(e)';'L-Arabinose','EX_arab_L(e)';'Laurate','EX_ddca(e)';'L-Homoserine','EX_hom_L(e)';'Linoleic acid','EX_lnlc(e)';'L-malate','EX_mal_L(e)';'L-Methionine S-oxide','EX_metsox_S_L(e)';'Menaquinone 7','EX_mqn7(e)';'meso-2,6-Diaminoheptanedioate','EX_26dap_M(e)';'N-acetyl-D-mannosamine','EX_acmana(e)';'N-Acetylneuraminate','EX_acnam(e)';'NMN','EX_nmn(e)';'Octadecanoate (n-C18:0)','EX_ocdca(e)';'Octadecenoate (n-C18:1)','EX_ocdcea(e)';'Oxidized glutathione','EX_gthox(e)';'Phenylacetic acid','EX_pac(e)';'Ribose','EX_rib_D(e)';'S-Adenosyl-L-methionine','EX_amet(e)';'Siroheme','EX_sheme(e)';'Tetradecanoate (n-C14:0)','EX_ttdca(e)';'Ubiquinone-8','EX_q8(e)';'Uridine','EX_uri(e)';'Thiosulfate','EX_tsul(e)';'Reduced glutathione','EX_gthrd(e)'};
growthRequirements = readtable([inputDataFolder filesep 'GrowthRequirementsTable.txt'], 'ReadVariableNames', false, 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011']);
growthRequirements = table2cell(growthRequirements);
% remove the reference columns
for i=1:11
    if ~isempty(find(strcmp(['Ref' num2str(i)],growthRequirements(1,:))))
        growthRequirements(:,find(strcmp(['Ref' num2str(i)],growthRequirements(1,:))))=[];
    end
end
% replace the metabolite names with the exchanges
for i = 2:size(growthRequirements, 2)
    growthRequirements(1, i) = growthExchanges(find(strcmp(growthExchanges(:, 1), growthRequirements{1, i})), 2);
end

tol = 1e-8;

addedMismatchRxns = {};
deletedMismatchRxns = {};

% get species-specific requirements if existing
mRow = find(strcmp(growthRequirements(:, 1), microbeID));
if ~isempty(mRow)
    
    for i = 2:size(growthRequirements, 2)
        speciesNutrRequ{i - 1, 1} = char(growthRequirements{1, i});
        speciesNutrRequ{i - 1, 2} = char(growthRequirements{mRow, i});
    end
    %     % add exchanges for metabolites that are only present in silico
    %     rLength = size(speciesNutrRequ, 1);
    %     exchanges = model.rxns(find(strncmp(model.rxns, 'EX_', 3)));
    %     otherExch = setdiff(exchanges, mets(:, 1));
    %     for i = 1:length(otherExch)
    %         mets{rLength + i, 1} = otherExch{i};
    %         speciesNutrRequ{rLength + i, 1} = otherExch{i};
    %         speciesNutrRequ{rLength + i, 2} = -1;
    %     end
    
    % only run the rest of the script if experimental data exists
    if any(~strcmp(speciesNutrRequ(:, 2), '0'))
        % set to the anaerobic Western diet to avoid the dipeptides etc. interfering with
        % the computations.
        dietConstraints=readtable('WesternDietAGORA2.txt');
        dietConstraints=table2cell(dietConstraints);
        dietConstraints(:,2)=cellstr(num2str(cell2mat(dietConstraints(:,2))));
        model=useDiet(model,dietConstraints);
        
        % enforce demand reactions for cobalamin, biotin and heme
        dmRxns={'DM_adocbl(c)', 'DM_btn', 'DM_btn', 'DM_pheme(c)', 'DM_thmpp(c)'};
        model=changeRxnBounds(model,dmRxns,0.00001,'l');
        
        % check if this abolishes growth
        FBA = optimizeCbModel(model, 'max');
        if FBA.f < tol
            model=changeRxnBounds(model,dmRxns,0,'l');
        end
        
        % remove dipeptides if model can still grow afterwards
        dipeptides={'EX_alaasp(e)','EX_alagln(e)','EX_alaglu(e)','EX_alagly(e)','EX_alahis(e)','EX_alaleu(e)','EX_alathr(e)','EX_glygln(e)','EX_glyglu(e)','EX_glyleu(e)','EX_glymet(e)','EX_glyphe(e)','EX_glypro(e)','EX_glytyr(e)','EX_metala(e)','EX_glyleu(e)','EX_glymet(e)','EX_glyphe(e)','EX_glypro(e)','EX_glytyr(e)','EX_glyasn(e)','EX_glyasp(e)','EX_glygln(e)','EX_glyglu(e)','EX_glycys(e)','EX_cgly(e)'};
        modelTest=changeRxnBounds(model,dipeptides,0,'l');
        FBA=optimizeCbModel(modelTest,'max');
        if FBA.f>tol
            model=modelTest;
        end
        
        %% constrain glutathione sink if present
        rxnID = find(ismember(model.rxns, 'sink_gthrd(c)'));
        if ~isempty(rxnID)
            model.lb(rxnID) = -1;
        end
        % remove alternate sources of growth factors that result in false
        % negatives predictions
        alternateSources={'EX_acgam(e)','EX_acnam(e)','EX_acmana(e)','EX_gam(e)',[],[],[],[],[],[],[],[];'EX_acnam(e)','EX_acgam(e)','EX_acmana(e)','EX_gam(e)',[],[],[],[],[],[],[],[];'EX_acmana(e)','EX_acgam(e)','EX_acnam(e)','EX_gam(e)',[],[],[],[],[],[],[],[];'EX_gam(e)','EX_acgam(e)','EX_acnam(e)','EX_acmana(e)',[],[],[],[],[],[],[],[];'EX_cys_L(e)','EX_h2s(e)','EX_cgly(e)','EX_glycys(e)',[],[],[],[],[],[],[],[];'EX_cgly(e)','EX_cys_L(e)','EX_glycys(e)','EX_gthrd(e)',[],[],[],[],[],[],[],[];'EX_arg_L(e)','EX_orn(e)',[],[],[],[],[],[],[],[],[],[];'EX_h2s(e)','EX_cgly(e)','EX_cys_L(e)','EX_met_L(e)','EX_metsox_S_L(e)',[],[],[],[],[],[],[];'EX_tsul(e)','EX_h2s(e)','EX_metsox_S_L(e)','EX_metala(e)','EX_cgly(e)','EX_glycys(e)','EX_cys_L(e)','EX_met_L(e)',[],[],[],[];'EX_ala_L(e)','EX_ala_D(e)',[],[],[],[],[],[],[],[],[],[];'EX_asp_L(e)','EX_succ(e)','EX_fum(e)','EX_mal_L(e)','EX_acac(e)','EX_asn_L(e)',[],[],[],[],[],[];'EX_met_L(e)','EX_h2s(e)','EX_metsox_S_L(e)','EX_metala(e)','EX_glycys(e)','EX_tsul(e)','EX_cys_L(e)',[],[],[],[],[];'EX_gly(e)','EX_glyglu(e)',[],[],[],[],[],[],[],[],[],[];'EX_glu_L(e)','EX_gln_L(e)','EX_glyglu(e)','EX_asp_L(e)','EX_asn_L(e)','EX_cit(e)','EX_akg(e)',[],[],[],[],[];'EX_gln_L(e)','EX_glu_L(e)','EX_asp_L(e)','EX_asn_L(e)',[],[],[],[],[],[],[],[];'EX_ile_L(e)','EX_3mop(e)','EX_2obut(e)',[],[],[],[],[],[],[],[],[];'EX_leu_L(e)','EX_3mop(e)','EX_2obut(e)',[],[],[],[],[],[],[],[],[];'EX_tyr_L(e)','EX_glytyr(e)',[],[],[],[],[],[],[],[],[],[];'EX_val_L(e)','EX_3mop(e)',[],[],[],[],[],[],[],[],[],[];'EX_ser_L(e)','TRPS2r','GHMT2r',[],[],[],[],[],[],[],[],[];'EX_4abz(e)','EX_fol(e)',[],[],[],[],[],[],[],[],[],[];'EX_adocbl(e)','EX_cbl1(e)',[],[],[],[],[],[],[],[],[],[];'EX_nac(e)','EX_nmn(e)','EX_ncam(e)',[],[],[],[],[],[],[],[],[];'EX_ncam(e)','EX_nmn(e)','EX_nac(e)',[],[],[],[],[],[],[],[],[];'EX_pydx(e)','EX_pydam(e)','EX_pydx5p(e)','EX_pydxn(e)',[],[],[],[],[],[],[],[];'EX_pydxn(e)','EX_pydam(e)','EX_pydx5p(e)','EX_pydx(e)',[],[],[],[],[],[],[],[];'EX_pydam(e)','EX_pydxn(e)','EX_pydx5p(e)','EX_pydx(e)',[],[],[],[],[],[],[],[];'EX_pydx5p(e)','EX_pydx(e)','EX_pydam(e)','EX_pydxn(e)',[],[],[],[],[],[],[],[];'EX_ptrc(e)','EX_orn(e)',[],[],[],[],[],[],[],[],[],[];'EX_ins(e)','EX_adn(e)','EX_ade(e)','EX_gua(e)','EX_uri(e)','EX_ura(e)','EX_hxan(e)','EX_xan(e)',[],[],[],[];'EX_ura(e)','EX_cytd(e)','EX_dcyt(e)','EX_uri(e)','EX_ins(e)','EX_hxan(e)','EX_xan(e)','EX_duri(e)','EX_csn(e)',[],[],[];'EX_uri(e)','EX_duri(e)','EX_hxan(e)','EX_xan(e)','EX_cytd(e)','EX_dcyt(e)',[],[],[],[],[],[];'EX_gua(e)','EX_adn(e)','EX_ade(e)','EX_gsn(e)','EX_ins(e)','EX_hxan(e)','EX_xan(e)','EX_dgsn(e)','EX_dad_2(e)',[],[],[];'EX_ocdca(e)','EX_ocdcea(e)','EX_ttdca(e)','EX_12dgr180(e)','EX_hdca(e)',[],[],[],[],[],[],[];'EX_adn(e)','EX_succ(e)','EX_gua(e)','EX_ade(e)','EX_gsn(e)','EX_ins(e)','EX_hxan(e)','EX_xan(e)','EX_dgsn(e)','EX_dad_2(e)',[],[];'EX_ocdcea(e)','EX_ocdca(e)','EX_ttdca(e)','EX_12dgr180(e)','EX_hdca(e)',[],[],[],[],[],[],[];'EX_ttdca(e)','EX_ocdca(e)','EX_ocdcea(e)','EX_12dgr180(e)','EX_hdca(e)',[],[],[],[],[],[],[];'EX_12dgr180(e)','EX_ttdca(e)','EX_ocdca(e)','EX_ocdcea(e)','EX_hdca(e)',[],[],[],[],[],[],[];'EX_q8(e)','EX_4hbz(e)','EX_mqn7(e)','EX_mqn8(e)',[],[],[],[],[],[],[],[];'EX_mqn7(e)','EX_4hbz(e)','EX_mqn8(e)',[],[],[],[],[],[],[],[],[];'EX_mqn8(e)','EX_4hbz(e)','EX_mqn7(e)',[],[],[],[],[],[],[],[],[];'EX_gal(e)','EX_melib(e)',[],[],[],[],[],[],[],[],[],[];'EX_xan(e)','EX_din(e)','EX_dgsn(e)','EX_dad_2(e)','EX_ins(e','EX_uri(e)','EX_cytd(e)','EX_dcyt(e)','EX_ura(e)','EX_adn(e)','EX_gua(e)','EX_gsn(e)';'EX_arab_D(e)','EX_rib_D(e)',[],[],[],[],[],[],[],[],[],[];'EX_rib_D(e)','EX_arab_D(e)',[],[],[],[],[],[],[],[],[],[];'EX_btn(e)','EX_pime(e)',[],[],[],[],[],[],[],[],[],[];'EX_chor(e)','EX_q8(e)','EX_mqn8(e)','EX_mqn8(e)',[],[],[],[],[],[],[],[]};
        model = changeRxnBounds(model, 'EX_o2(e)', 0, 'l');
        for i = 1:length(speciesNutrRequ)
            modelTest = changeRxnBounds(model, speciesNutrRequ{i, 1}, 0, 'l');
            % remove alternate sources
            findExch=find(strcmp(alternateSources(:,1),speciesNutrRequ{i, 1}));
            if ~isempty(findExch)
                altExch=alternateSources(findExch,find(~cellfun(@isempty, alternateSources(findExch,1:end))));
                modelTest=changeRxnBounds(modelTest,altExch,0,'l');
            end
            FBA = optimizeCbModel(modelTest, 'max');
            if FBA.f < tol || FBA.stat==0
                speciesNutrRequ{i, 3} = '1';
            else
                speciesNutrRequ{i, 3} = '0';
            end
        end
        
        %% get all in vitro and in silico essentialities
        % How to read this data:
        % if requirements(i,1)==-1 and  requirements(i,2)==1 -> false
        % positive
        % if requirements(i,1)==1 and  requirements(i,2)==0 -> false
        % negative
        
        %% allow growth with oxygen
        model = changeRxnBounds(model, 'EX_o2(e)', -1, 'l');
        
        %% add metabolites with corresponding exchanges and transporters for compounds demonstratedly or probably required in vitro
        
        transpExch={'EX_4abz(e)','4ABZt2';'EX_ac(e)','ACtr';'EX_ade(e)','ADEt2';'EX_adn(e)','ADNt2';'EX_btn(e)','BTNabc';'EX_chsterol(e)','CHSTEROLup';'EX_cit(e)','r1088';'EX_co2(e)','CO2t';'EX_adocbl(e)','ADOCBLabc';'EX_glc_D(e)','GLCabc';'EX_fol(e)','FOLabc';'EX_for(e)','FORt';'EX_fum(e)','FUMt2r';'EX_glyc(e)','GLYCt';'EX_gly(e)','GLYt2r';'EX_gua(e)','GUAt2';'EX_h2s(e)','H2St';'EX_pheme(e)','HEMEti';'EX_hxan(e)','HYXNt';'EX_ins(e)','INSt2i';'EX_ala_L(e)','ALAt2r';'EX_arg_L(e)','ARGt2r';'EX_asn_L(e)','ASNt2r';'EX_asp_L(e)','ASPt2r';'EX_cys_L(e)','CYSt2r';'EX_glu_L(e)','GLUt2r';'EX_gln_L(e)','GLNt2r';'EX_his_L(e)','HISt2r';'EX_ile_L(e)','ILEt2r';'EX_lac_L(e)','L_LACt2';'EX_leu_L(e)','LEUt2r';'EX_lys_L(e)','LYSt2r';'EX_met_L(e)','METt2r';'EX_phe_L(e)','PHEt2r';'EX_pro_L(e)','PROt2r';'EX_ser_L(e)','SERt2r';'EX_thr_L(e)','THRt2r';'EX_trp_L(e)','TRPt2r';'EX_tyr_L(e)','TYRt2r';'EX_val_L(e)','VALt2r';'EX_malt(e)','MALTabc';'EX_mqn8(e)','MK8t';'EX_acgam(e)','ACGAMtr2';'EX_nh4(e)','NH4tb';'EX_ncam(e)','NCAMt2r';'EX_nac(e)','NACt2r';'EX_no3(e)','NO3abc';'EX_orn(e)','ORNt2r';'EX_orot(e)','OROte';'EX_pnto_R(e)','PNTOabc';'EX_ptrc(e)','PTRCt2';'EX_pydx(e)','PYDXabc';'EX_pydx5p(e)','r0871';'EX_pydam(e)','PYDAMabc';'EX_pydxn(e)','PYDXNabc';'EX_pyr(e)','PYRt2r';'EX_ribflv(e)','RIBFLVt2r';'EX_so4(e)','SO4t2';'EX_spmd(e)','SPMDtex2';'EX_succ(e)','SUCCt2r';'EX_thm(e)','THMabc';'EX_thymd(e)','THMDt2r';'EX_ura(e)','URAt2';'EX_xan(e)','XANt2'};
       
        % find exchanges and transporters for probably or maybe essential
        % components
        essentialComp=speciesNutrRequ(str2double(speciesNutrRequ(:,2))==1,1);
        essentialComp=union(essentialComp,speciesNutrRequ(str2double(speciesNutrRequ(:,2))==0,1));
        [~,findEssExch]=intersect(transpExch(:,1),essentialComp);
        for i=1:length(findEssExch)
            if isempty(find(strcmp(model.rxns,transpExch{findEssExch(i),1})))
            % find the formula
            formula = database.reactions{find(strcmp(database.reactions(:, 1), transpExch{findEssExch(i),1})), 3};
            model = addReaction(model, transpExch{findEssExch(i),1}, 'reactionFormula', formula, 'geneRule', 'GrowthRequirementsGapfill');
            formula = database.reactions{find(strcmp(database.reactions(:, 1), transpExch{findEssExch(i),2})), 3};
            model = addReaction(model, transpExch{findEssExch(i),2}, 'reactionFormula', formula, 'geneRule', 'GrowthRequirementsGapfill');
            addedMismatchRxns(length(addedMismatchRxns)+1:length(addedMismatchRxns)+2,1)=transpExch(findEssExch(i),:)';
            end
        end
        
        nonessentialComp=speciesNutrRequ(str2double(speciesNutrRequ(:,2))==-1,1);
        
        %% define the GPRs that indicate a reactions that is gap-filled
        gapfillGPRs={'','Unknown','0000000.0.peg.0','gapFilled'};
        %% define reactions in each biosynthesis pathways to gapfill or delete, and the necessary conditions
        conditions={
            'Metabolite','In vitro','In silico','Present','Absent','Constrain','Gapfills','Deletions','Organism'
            {'EX_gly(e)'},{'-1'},{'1'},{'THRAi'},{''},{'EX_gly(e)'},{'EX_acald(e)','ACALDt'},{''},{''}
            {'EX_gly(e)'},{'0'},{'1'},{'THRAi'},{''},{'EX_gly(e)'},{'EX_acald(e)','ACALDt'},{''},{''}
            {'EX_gly(e)'},{'-1'},{'1'},{'GHMT2r'},{''},{'EX_gly(e)'},{'EX_thymd(e)','ACALDt'},{''},{''}
            {'EX_gly(e)'},{'0'},{'1'},{'GHMT2r'},{''},{'EX_gly(e)'},{'EX_thymd(e)','ACALDt'},{''},{''}
            {'EX_gly(e)'},{'-1'},{'1'},{''},{''},{'EX_gly(e)'},{'EX_thymd(e)','FTHFD','EX_for(e)','FORt','r0792','GHMT2r','MTHFC','PNTORDe'},{''},{''}
            {'EX_gly(e)'},{'0'},{'1'},{''},{''},{'EX_gly(e)'},{'EX_thymd(e)','FTHFD','EX_for(e)','FORt','r0792','GHMT2r'},{''},{''}
            {'EX_fol(e)'},{'1'},{'0'},{''},{''},{''},{'FOLR3'},{''},{''}
            {'EX_ser_L(e)'},{'-1'},{'1'},{''},{''},{'EX_gly(e)'},{'PSERT','PSP_L','PGCDr'},{''},{''}
            {'EX_ala_D(e)'},{'-1'},{'1'},{''},{''},{'EX_ala_D(e)'},{'ALAR','EX_ala_L(e)','ALAt2r'},{''},{''}
            {'EX_ala_L(e)'},{'-1'},{'1'},{''},{''},{'EX_ala_D(e)'},{'EX_ala_L(e)','ALAt2r'},{''},{''}
            {'EX_ala_L(e)'},{'1'},{'0'},{''},{''},{''},{'EX_ala_L(e)','ALAt2r'},{'ALAD_R'},{''}
            {'EX_ala_L(e)'},{'1'},{'0'},{''},{'ALATA_L'},{''},{'ALAD_L'},{'ALAD_R'},{''}
            {'EX_ala_L(e)'},{'-1'},{'1'},{''},{''},{'EX_ala_L(e)'},{'ALATA_L','VPAMTr'},{},{''}
            {'EX_arg_L(e)'},{'1'},{'0'},{''},{''},{'EX_orn(e)'},{'EX_arg_L(e)','ARGt2r'},{'ACGS','ACGK','AGPR','ACOTA','ACODAr','OCBT','ARGSSr','ARGSL','EX_fum(e)','FUMt2r','H2CO3D'},{''}
            {'EX_arg_L(e)'},{'-1'},{'1'},{''},{''},{'EX_arg_L(e)','EX_orn(e)'},{'ACGS','ACGK','AGPR','ACOTA','ACODAr','OCBT','ARGSSr','ARGSL','EX_fum(e)','FUMt2r','H2CO3D'},{''},{''}
            {'EX_asn_L(e)'},{'-1'},{'1'},{''},{''},{'EX_asn_L(e)'},{'ASNS2','ASNS1'},{''},{''}
            {'EX_asn_L(e)'},{'-1'},{'1'},{'PPCK'},{''},{'EX_asn_L(e)'},{'PPCKr','ASPTA'},{''},{''}
            {'EX_asp_L(e)'},{'-1'},{'1'},{'PPCK'},{''},{'EX_asp_L(e)'},{'PPCKr','ASPTA'},{''},{''}
            {'EX_asp_L(e)'},{'1'},{'0'},{''},{''},{''},{'ASPTA'},{''},{''}
            {'EX_asp_L(e)'},{'-1'},{'1'},{''},{''},{'EX_asp_L(e)','EX_succ(e)','EX_fum(e)','EX_mal_L(e)','EX_acac(e)','EX_asn_L(e)'},{'ASPTA','GLUN','GLUDy','GLNS','GLUSx','GLUSy','CS','ACONT','ICDHyr','r0127'},{''},{''}
            {'EX_cys_L(e)'},{'-1'},{'1'},{''},{''},{'EX_cys_L(e)','EX_cgly(e)','EX_glycys(e)'},{'SERATi','CYSS','SULRi','EX_h2s(e)','H2St'},{''},{''}
            {'EX_cys_L(e)'},{'-1'},{'1'},{'METS'},{''},{'EX_cys_L(e)','EX_cgly(e)','EX_glycys(e)'},{'SERATi','CYSS','METSr','EX_h2s(e)','H2St','GHMT2r','MTHFC'},{''},{''}
            {'EX_cys_L(e)'},{'1'},{'0'},{''},{''},{'EX_h2s(e)','EX_cgly(e)','EX_glycys(e)'},{'EX_cys_L(e)','CYSt2r','CYSDS'},{'SERATi','CYSS','CYSTGL','CYSTS'},{''}
            {'EX_cys_L(e)'},{'0'},{'1'},{'EX_cgly(e)'},{'EX_cys_L(e)'},{'EX_h2s(e)','EX_cgly(e)','EX_glycys(e)'},{'EX_cys_L(e)','CYSt2r','CYSDS'},{'SERATi','CYSS','CYSTGL','CYSTS'},{''}
            {'EX_cys_L(e)'},{'1'},{'0'},{'SHSL1r'},{''},{'EX_h2s(e)','EX_cgly(e)','EX_glycys(e)'},{'EX_cys_L(e)','CYSt2r'},{''},{''}
            {'EX_cgly(e)'},{'-1'},{'1'},{''},{''},{'EX_cgly(e)','EX_glycys(e)','EX_gthrd(e)'},{'GLUCYS','GTHS','EX_cys_L(e)','CYSt2r','EX_gly(e)','GLYt2r'},{'GGTA'},{''}
            {'EX_cgly(e)'},{'0'},{'0'},{''},{''},{'EX_gly(e)','EX_cys_L(e)','EX_cgly(e)','EX_glycys(e)','EX_gthrd(e)'},{'SERATi','CYSS','GHMT2r','MTHFC'},{''},{''}
            {'EX_cgly(e)'},{'-1'},{'1'},{''},{''},{'EX_cys_L(e)','EX_cgly(e)','EX_glycys(e)'},{'SERATi','CYSS','EX_h2s(e)','H2St'},{''},{''}
            {'EX_gthox(e)'},{'-1'},{'1'},{''},{''},{'EX_gthox(e)'},{'sink_gthrd(c)'},{'GTHRD'},{''}
            {'EX_gln_L(e)'},{'-1'},{'1'},{''},{''},{'EX_gln_L(e)'},{'ASNS1','ASPTA','GLUN','GLUDy','GLNS','PPCKr'},{''},{''}
            {'EX_gln_L(e)'},{'1'},{'0'},{''},{''},{''},{'EX_gln_L(e)','GLNt2r'},{'ASNS1','ASPTA','GLUN','GLUDy','GLNS'},{''}
            {'EX_glu_L(e)'},{'-1'},{'1'},{''},{''},{'EX_glu_L(e)','EX_gln_L(e)'},{'ASNS1','ASPTA','GLUN','GLUDy','GLNS','GLUSx','GLUSy','CS','ACONT','ICDHyr'},{''},{''}
            {'EX_glu_L(e)'},{'1'},{'0'},{''},{''},{'EX_gln_L(e)'},{'EX_glu_L(e)','GLUt2r'},{'ASNS1','ASPTA','GLUN','GLUDy','GLNS','GLUSx','GLUSy','CS','ACONT','ICDHyr'},{''}
            {'EX_glu_L(e)'},{'0'},{'1'},{''},{'EX_glu_L(e)'},{'EX_gln_L(e)'},{'EX_glu_L(e)','GLUt2r'},{''},{''}
            {'EX_his_L(e)'},{'-1'},{'1'},{''},{''},{'EX_his_L(e)'},{'ATPPRT','PRATPP','PRAMPC','PRMICI','IG3PS','IGPDH','HSTPTr','HISTP','HISTD'},{''},{''}
            {'EX_his_L(e)'},{'1'},{'0'},{''},{''},{''},{'EX_his_L(e)','HISt2r'},{'ATPPRT','PRATPP','PRAMPC','PRMICI','IG3PS','IGPDH','HSTPTr','HISTP','HISTD'},{''}
            {'EX_lys_L(e)'},{'-1'},{'1'},{''},{''},{'EX_lys_L(e)','EX_26dap_M(e)'},{'26DAPLLAT','26DAPLLATi','ACEDIPIT','APAT','ASAD','ASPK','DAPDA','DAPDAi','DAPDC','DAPE','DHDPRy','DHDPRyr','DHDPS','SDPDS','SDPTA','THDPS'},{''},{''}
            {'EX_lys_L(e)'},{'1'},{'0'},{''},{''},{'EX_26dap_M(e)'},{'EX_lys_L(e)','LYSt2r'},{'26DAPLLAT','26DAPLLATi','ACEDIPIT','APAT','ASAD','ASPK','DAPDA','DAPDAi','DAPDC','DAPE','DHDPRy','DHDPRyr','DHDPS','SDPDS','SDPTA','THDPS'},{''}
            {'EX_ile_L(e)'},{'-1'},{'1'},{''},{''},{'EX_ile_L(e)','EX_3mop(e)'},{'THRD_L','ACHBS','KARA2','DHAD2','ILETA','2MMALD','2MMALD2'},{''},{''}
            {'EX_ile_L(e)'},{'1'},{'0'},{''},{''},{''},{'EX_ile_L(e)','ILEt2r'},{'THRD_L','ACHBS','KARA2','DHAD2','ILETA''ACHBPL','THRD_L','CYSTGL','ACLS_a','ACLS_b'},{''}
            {'EX_leu_L(e)'},{'-1'},{'1'},{''},{''},{'EX_leu_L(e)','EX_3mop(e)'},{'IPPS','IPPMIb','IPPMIa','IPMDr','OMCDC','LEUTA'},{''},{''}
            {'EX_leu_L(e)'},{'1'},{'0'},{''},{''},{''},{'EX_leu_L(e)','LEUt2r'},{'IPPS','IPPMIb','IPPMIa','IPMDr','OMCDC','LEUTA'},{''}
            %             {'EX_met_L(e)'},{'-1'},{'1'},{''},{''},{'EX_met_L(e)','EX_h2s(e)','EX_metsox_S_L(e)','EX_cgly(e)','EX_glycys(e)','EX_tsul(e)'},{'ASPK','ASAD','ASADi','AHSERL3','HSDx','HSST','SHSL2','METS','HSERTA','CYSTL','SUCD1','SULRi','SADT','AMPSO3OX','r0792','EX_h2s(e)','H2St','EX_cys_L(e)','CYSt2r'},{''},{''}
            {'EX_met_L(e)'},{'-1'},{'1'},{''},{''},{'EX_met_L(e)','EX_h2s(e)','EX_metsox_S_L(e)','EX_glycys(e)','EX_tsul(e)'},{'ASPK','ASAD','ASADi','AHSERL3','HSDx','HSST','SHSL2','METS','HSERTA','CYSTL','SUCD1','SULRi','SADT','AMPSO3OX','r0792','EX_h2s(e)','H2St','EX_cys_L(e)','CYSt2r'},{''},{''}
            {'EX_met_L(e)'},{'-1'},{'0'},{''},{''},{'EX_met_L(e)','EX_q8(e)','EX_mqn7(e)','EX_mqn8(e)'},{'ASPK','ASAD','ASADi','AHSERL3','HSDx','HSST','SHSL2','METS','HSERTA'},{''},{''}
            {'EX_met_L(e)'},{'1'},{'0'},{''},{''},{'EX_metsox_S_L(e)'},{'EX_met_L(e)','METt2r'},{'ASPK','ASAD','ASADi','AHSERL3','HSDx','HSDy','HSST','SHSL1r','SHSL2','SHSL4r','METS','HSERTA','METB1','CYSTL','SUCD1','SULRi','SADT','AMPSO3OX','r0792'},{''}
            {'EX_orn(e)'},{'-1'},{'1'},{''},{''},{'EX_orn(e)'},{'ACGS','ACGK','AGPR','ACOTA','ACODAr'},{''},{''}
            {'EX_phe_L(e)'},{'-1'},{'1'},{''},{''},{'EX_phe_L(e)'},{'DDPA','DHQS','DHQTi','SHK3Dr','SHKK','PSCVT','CHORS','CHORM','PPNDH','PHETA1'},{''},{''}
            {'EX_phe_L(e)'},{'1'},{'0'},{''},{''},{')'},{'EX_phe_L(e)','PHEt2r'},{'DDPA','DHQS','DHQTi','SHK3Dr','SHKK','PSCVT','CHORS','CHORM','PPNDH','PHETA1'},{''}
            {'EX_pro_L(e)'},{'-1'},{'1'},{''},{''},{'EX_pro_L(e)'},{'GLU5K','G5SD','ORNTA','G5SADs','P5CR'},{''},{''}
            {'EX_pro_L(e)'},{'1'},{'0'},{''},{''},{'P5CRyr'},{'EX_pro_L(e)','PROt2r','P5CRy'},{'GLU5K','G5SD','ORNTA','G5SADs','P5CR'},{''}
            {'EX_ser_L(e)'},{'-1'},{'1'},{''},{''},{'EX_ser_L(e)','TRPS2r','GHMT2r'},{'PSERT','PSP_L','PGCDr'},{''},{''}
            {'EX_ser_L(e)'},{'1'},{'0'},{''},{''},{''},{'EX_ser_L(e)','SERt2r'},{'PSERT','PSP_L','PGCDr'},{''}
            {'EX_thr_L(e)'},{'-1'},{'1'},{''},{''},{'EX_thr_L(e)'},{'ASPK','ASAD','HSDx','HSK','THRS'},{''},{''}
            {'EX_thr_L(e)'},{'1'},{'0'},{''},{''},{''},{'EX_thr_L(e)','THRt2r'},{'ASPK','ASAD','HSDx','HSK','THRS'},{''}
            {'EX_trp_L(e)'},{'-1'},{'1'},{''},{''},{'EX_trp_L(e)','EX_indole(e)'},{'DDPA','DHQS','DHQTi','SHK3Dr','SHKK','PSCVT','CHORS','ANS','ANPRT','PRAI','IGPS','TRPS1','TRPS2','TRPS3r'},{''},{''}
            {'EX_trp_L(e)'},{'1'},{'0'},{''},{''},{'EX_indole(e)'},{'EX_trp_L(e)','TRPt2r'},{'DDPA','DHQS','DHQTi','SHK3Dr','SHKK','PSCVT','CHORS','ANS','ANPRT','PRAI','IGPS','TRPS1','TRPS2','TRPS3r'},{''}
            {'EX_tyr_L(e)'},{'-1'},{'1'},{''},{''},{'EX_tyr_L(e)'},{'DDPA','DHQS','DHQTi','SHK3Dr','SHKK','PSCVT','CHORS','CHORM','PPND','TYRTA'},{''},{''}
            {'EX_tyr_L(e)'},{'1'},{'0'},{''},{''},{''},{'EX_tyr_L(e)','TYRt2r'},{'DDPA','DHQS','DHQTi','SHK3Dr','SHKK','PSCVT','CHORS','CHORM','PPND','TYRTA'},{''}
            {'EX_val_L(e)'},{'-1'},{'1'},{''},{''},{'EX_val_L(e)'},{'ACLS_a','ACLS_b','KARA1','DHAD1','VALTA'},{''},{''}
            {'EX_val_L(e)'},{'1'},{'0'},{''},{''},{''},{'EX_val_L(e)','VALt2r'},{'ACLS_a','ACLS_b','KARA1','DHAD1','VALTA'},{''}
            {'EX_h2s(e)'},{'-1'},{'1'},{''},{''},{'EX_h2s(e)'},{'SULRi','SADT','AMPSO3OX','EX_cys_L(e)','CYSt2r','EX_met_L(e)','METt2r'},{''},{''}
            {'EX_h2s(e)'},{'1'},{'0'},{''},{''},{''},{'EX_h2s(e)','H2St'},{'CYSTGL','CYSTS'},{''}
            {'EX_so4(e)'},{'-1'},{'1'},{''},{''},{'EX_so4(e)'},{'H2SO','EX_h2s(e)','H2St','sink_chols','CHOLSH'},{''},{''}
            {'EX_so4(e)'},{'-1'},{'1'},{'CHOLK'},{''},{'EX_so4(e)'},{'H2SO','EX_h2s(e)','H2St','sink_chols','CHOLSH','sink_cholp(c)'},{''},{''}
            {'EX_metsox_S_L(e)'},{'-1'},{'1'},{''},{''},{'EX_metsox_S_L(e)'},{'EX_h2s(e)','H2St','EX_met_L(e)','METt2r'},{''},{''}
            {'EX_ac(e)'},{'-1'},{'1'},{''},{''},{'EX_ac(e)'},{'PDHa','PDHbr','PDHc'},{'EX_ac(e)','ACtr'},{''}
            {'EX_ptrc(e)'},{'-1'},{'1'},{''},{''},{'EX_ptrc(e)'},{'EX_urea(e)','UREAt','AGMT','ORNDC','ARGN'},{''},{''}
            {'EX_ptrc(e)','EX_orn(e)'},{'-1'},{'1'},{''},{''},{'EX_ptrc(e)','EX_orn(e)'},{'EX_urea(e)','UREAt','AGMT','ORNDC','ARGN'},{''},{''}
            %             {'EX_ptrc(e)','EX_orn(e)'},{'0'},{''},{''},{''},{'EX_ptrc(e)','EX_orn(e)'},{'EX_urea(e)','UREAt','AGMT','ORNDC','ARGN'},{''},{''}
            {'EX_spmd(e)'},{'-1'},{'1'},{''},{''},{'EX_spmd(e)'},{'SPMS','ADMDCr','MTAN','DM_5MTR','ORNDC','EX_ade(e)','ADEt2r'},{''},{''}
            {'EX_anth(e)'},{'-1'},{'1'},{''},{''},{'EX_anth(e)'},{'EX_trp_L(e)','TRPt2r'},{'EX_anth(e)','ANTHte'},{''}
            {'EX_4hbz(e)'},{'-1'},{'1'},{''},{''},{'EX_4hbz(e)'},{'EX_trp_L(e)','TRPt2r','EX_phe_L(e)','PHEt2r','EX_tyr_L(e)','TYRt2r','EX_q8(e)','Q8abc'},{'EX_4hbz(e)','4HBZt2'},{''}
            {'EX_chor(e)'},{'-1'},{'1'},{''},{''},{'EX_chor(e)'},{'EX_trp_L(e)','TRPt2r','EX_phe_L(e)','PHEt2r','EX_tyr_L(e)','TYRt2r','EX_mqn7(e)','MK7t','EX_mqn8(e)','MK8t','DDPA','DHQS','DHQTi','SHK3Dr','SHKK','PSCVT','CHORS'},{'EX_chor(e)','CHORt'},{''}
            {'EX_chor(e)'},{'-1'},{'1'},{''},{''},{'EX_chor(e)','EX_akg(e)','EX_glu_L(e)','EX_mal_L(e)','EX_succ(e)'},{'CHORS','PC'},{'EX_chor(e)','CHORt',},{''}
            {'EX_26dap_M(e)'},{'-1'},{'1'},{''},{''},{'EX_26dap_M(e)'},{'ASAD','ASPK','DHDPS','DHDPRy','L2A6OD2s','DAPMDH'},{'EX_26dap_M(e)','26DAPt2r','DAPabc'},{''}
            {'EX_5aop(e)'},{'-1'},{'1'},{''},{''},{'EX_5aop(e)'},{'EX_sheme(e)','SHEMEabc'},{''},{''}
            {'EX_3mop(e)'},{'-1'},{'1'},{''},{''},{'EX_3mop(e)'},{'ILETA'},{''},{''}
            {'EX_arab_D(e)'},{'-1'},{'1'},{''},{''},{'EX_arab_D(e)'},{'ARABI','DRIBI','RBK_Dr'},{''},{''}
            {'EX_rib_D(e)'},{'-1'},{'1'},{''},{''},{'EX_rib_D(e)'},{'ARABI','DRIBI','RBK_Dr'},{''},{''}
            {'EX_gal(e)'},{'-1'},{'1'},{''},{''},{'EX_gal(e)','EX_melib(e)'},{'PGMT'},{''},{''}
            {'EX_gal(e)'},{'-1'},{'1'},{''},{'GALU'},{'EX_gal(e)','EX_melib(e)'},{'PGMT','GALUi'},{''},{''}
            {'EX_akg(e)'},{'-1'},{'1'},{''},{''},{'EX_akg(e)'},{'EX_mal_L(e)','MAL_Lte'},{''},{''}
            {'EX_mal_L(e)'},{'-1'},{'1'},{''},{''},{'EX_mal_L(e)'},{'EX_akg(e)','AKGte'},{''},{''}
            {'EX_acgam(e)'},{'-1'},{'1'},{''},{''},{'EX_acgam(e)','EX_acnam(e)','EX_acmana(e)','EX_gam(e)'},{'GF6PTA','PGAMT','G1PACT','UAGDP'},{''},{''}
            {'EX_acnam(e)'},{'-1'},{'1'},{''},{''},{'EX_acnam(e)','EX_acgam(e)','EX_acmana(e)','EX_gam(e)'},{'GF6PTA','PGAMT','G1PACT','UAGDP'},{''},{''}
            {'EX_acmana(e)'},{'-1'},{'1'},{''},{''},{'EX_acmana(e)','EX_acnam(e)','EX_acgam(e)','EX_gam(e)'},{'GF6PTA','PGAMT','G1PACT','UAGDP'},{''},{''}
            {'EX_gam(e)'},{'-1'},{'1'},{''},{''},{'EX_gam(e)','EX_acnam(e)','EX_acgam(e)','EX_acmana(e)'},{'GF6PTA','PGAMT','G1PACT','UAGDP'},{''},{''}
            {'EX_pyr(e)'},{'1'},{'0'},{''},{''},{''},{'EX_pyr(e)','PYRt2r'},{''},{''}
            {'EX_2obut(e)'},{'-1'},{'1'},{''},{''},{'EX_2obut(e)'},{'IPMD2','2MMALD2','2MMALD','CITRAMALS','THRD_L'},{''},{'Bacteroides'}
            {'EX_12dgr180(e)'},{'-1'},{'1'},{''},{''},{'EX_12dgr180(e)','EX_ocdca(e)','EX_ocdcea(e)','EX_ttdca(e)','EX_hdca(e)'},{'3HAD40','3HAD60','3HAD80','3HAD100','3HAD120','3HAD140','3HAD160','3HAD180','3OAR100','3OAR120','3OAR140','3OAR160','3OAR180','3OAR40','3OAR60','3OAR80','3OAS100','3OAS120','3OAS140','3OAS160','3OAS180','3OAS60','3OAS80','EAR40x','EAR60x','EAR80x','EAR100x','EAR120x','EAR140x','EAR160x','EAR180x','PAPA180','G3PAT120','G3PAT140','G3PAT160','G3PAT180','ACOATA','MCOATA','PMTCOATA','STCOATA','TDCOATA','KAS14'},{''},{''}
            {'EX_ddca(e)'},{'-1'},{'1'},{''},{''},{'EX_ddca(e)'},{'3HAD40','3HAD60','3HAD80','3HAD100','3HAD120','3HAD140','3HAD160','3HAD180','3OAR100','3OAR120','3OAR140','3OAR160','3OAR180','3OAR40','3OAR60','3OAR80','3OAS100','3OAS120','3OAS140','3OAS160','3OAS180','3OAS60','3OAS80','EAR40x','EAR60x','EAR80x','EAR100x','EAR120x','EAR140x','EAR160x','EAR180x','ACOATA','ACS','KAS14','MCOATA','ACCOAC'},{''},{''}
            {'EX_ttdca(e)'},{'-1'},{'1'},{''},{''},{'EX_ttdca(e)','EX_12dgr180(e)','EX_ocdca(e)','EX_ocdcea(e)','EX_hdca(e)'},{'3HAD40','3HAD60','3HAD80','3HAD100','3HAD120','3HAD140','3HAD160','3HAD180','3OAR100','3OAR120','3OAR140','3OAR160','3OAR180','3OAR40','3OAR60','3OAR80','3OAS100','3OAS120','3OAS140','3OAS160','3OAS180','3OAS60','3OAS80','EAR40x','EAR60x','EAR80x','EAR100x','EAR120x','EAR140x','EAR160x','EAR180x','KAS14','ACOATA','ACS','MCOATA','ACCOAC','H2CO3D'},{''},{''}
            {'EX_ocdca(e)'},{'-1'},{'1'},{''},{''},{'EX_ttdca(e)','EX_12dgr180(e)','EX_ocdca(e)','EX_ocdcea(e)','EX_hdca(e)'},{'3HAD40','3HAD60','3HAD80','3HAD100','3HAD120','3HAD140','3HAD160','3HAD180','3OAR100','3OAR120','3OAR140','3OAR160','3OAR180','3OAR40','3OAR60','3OAR80','3OAS100','3OAS120','3OAS140','3OAS160','3OAS180','3OAS60','3OAS80','EAR40x','EAR60x','EAR80x','EAR100x','EAR120x','EAR140x','EAR160x','EAR180x','ACOATA','MCOATA','PMTCOATA','STCOATA','TDCOATA','ACS','KAS14','ACCOAC','H2CO3D'},{''},{''}
            {'EX_ocdcea(e)'},{'-1'},{'1'},{''},{''},{'EX_ttdca(e)','EX_12dgr180(e)','EX_ocdca(e)','EX_ocdcea(e)','EX_hdca(e)'},{'3HAD40','3HAD60','3HAD80','3HAD100','3HAD120','3HAD140','3HAD160','3HAD180','3OAR100','3OAR120','3OAR140','3OAR160','3OAR180','3OAR40','3OAR60','3OAR80','3OAS100','3OAS120','3OAS140','3OAS160','3OAS180','3OAS60','3OAS80','EAR40x','EAR60x','EAR80x','EAR100x','EAR120x','EAR140x','EAR160x','EAR180x','ACOATA','MCOATA','PMTCOATA','STCOATA','TDCOATA','ACS','KAS14','ACCOAC','H2CO3D'},{''},{''}
            {'EX_tsul(e)'},{'-1'},{'1'},{''},{''},{'EX_tsul(e)','EX_metsox_S_L(e)','EX_metala(e)','EX_cgly(e)','EX_glycys(e)'},{'AHSERL3','TSULST','SADT','ADSK','SERATi','CYSS','SULFR','EX_h2s(e)','H2St'},{''},{''}
            {'EX_tsul(e)'},{'-1'},{'1'},{''},{''},{'EX_tsul(e)','EX_metsox_S_L(e)','EX_metala(e)','EX_cgly(e)','EX_glycys(e)','EX_cys_L(e)'},{'AHSERL3','TSULST','SADT','SADT2','ADSK','SERATi','CYSS','SULFR','EX_h2s(e)','H2St','EX_met_L(e)','METt2r'},{''},{''}
            {'EX_tsul(e)'},{'-1'},{'1'},{''},{''},{'EX_tsul(e)','EX_metsox_S_L(e)','EX_metala(e)','EX_cgly(e)','EX_glycys(e)','EX_met_L(e)'},{'AHSERL3','TSULST','SADT','SADT2','ADSK','SERATi','CYSS','SULFR','EX_h2s(e)','H2St','EX_cys_L(e)','CYSt2r'},{''},{''}
            {'EX_gthrd(e)'},{'-1'},{'1'},{''},{''},{'EX_gthrd(e)'},{'GTHS','GSPMDA','GGTA','GLUCYS'},{''},{''}
            {'EX_for(e)'},{'-1'},{'1'},{''},{''},{'EX_for(e)'},{'EX_thymd(e)','THMDt2r','EX_4abz(e)','4ABZt2'},{''},{''}
            {'EX_nmn(e)','EX_nac(e)'},{'-1'},{'1'},{''},{''},{'EX_nmn(e)','EX_nac(e)','EX_ncam(e)'},{'ASPO5','DNADDP','L_ASPR','NAMNPP','NAPRT','NICRNS','NMNDA','NNATr','NNDMBRT','NNDPR','NP1_r','NT5C','QULNS','r0391','r0527','r0584'},{''},{''}
            {'EX_nac(e)','EX_ncam(e)'},{'-1'},{'1'},{''},{''},{'EX_nmn(e)','EX_nac(e)','EX_ncam(e)'},{'ASPO5','DNADDP','L_ASPR','NAMNPP','NAPRT','NICRNS','NMNDA','NNATr','NNDMBRT','NNDPR','NP1_r','NT5C','QULNS'},{''},{''}
            {'EX_nmn(e)','EX_nac(e)','EX_ncam(e)'},{'-1'},{'1'},{''},{''},{'EX_nmn(e)','EX_nac(e)','EX_ncam(e)'},{'ASPO5','DNADDP','L_ASPR','NAMNPP','NAPRT','NICRNS','NMNDA','NNATr','NNDMBRT','NNDPR','NP1_r','NT5C','QULNS','r0391','r0527','r0584'},{''},{''}
            {'EX_nmn(e)'},{'-1'},{'1'},{''},{''},{'EX_nmn(e)'},{'EX_ncam(e)','NCAMabc','EX_nac(e)','NACabc'},{''},{''}
            {'EX_nac(e)'},{'1'},{'0'},{''},{''},{'EX_nmn(e)','EX_ncam(e)'},{'EX_nac(e)','NACabc'},{'ASPO5','DNADDP','L_ASPR','NAMNPP','NAPRT','NICRNS','NMNDA','NNATr','NNDMBRT','NNDPR','NP1_r','NT5C','QULNS','r0391','r0527','r0584'},{''}
            {'EX_nac(e)'},{'1'},{'0'},{''},{'NP1_r'},{'EX_nmn(e)','EX_ncam(e)'},{'EX_nac(e)','NACabc'},{'ASPO5','DNADDP','L_ASPR','NAMNPP','NAPRT','NICRNS','NMNDA','NNATr','NNDMBRT','NNDPR','NP1_r','NT5C','QULNS','r0391','r0527','r0584','NP1'},{''}
            {'EX_nac(e)'},{'1'},{'0'},{''},{''},{'EX_nmn(e)','EX_ncam(e)'},{'EX_nac(e)','NACabc'},{'ASPO5','DNADDP','L_ASPR','NAMNPP','NAPRT','NICRNS','NMNDA','NNATr','NNDMBRT','NNDPR','NP1_r','NT5C','QULNS','r0391','r0527','r0584'},{''}
            {'EX_nac(e)'},{'-1'},{'1'},{''},{''},{'EX_nmn(e)','EX_nac(e)','EX_ncam(e)'},{'ASPO5','DNADDP','L_ASPR','NAMNPP','NAPRT','NICRNS','NMNDA','NNATr','NNDMBRT','NNDPR','NP1_r','NT5C','QULNS','r0391','r0527','r0584'},{''},{''}
            {'EX_ncam(e)'},{'1'},{'0'},{''},{''},{'EX_nmn(e)','EX_nac(e)'},{'EX_ncam(e)','NCAMabc'},{'ASPO5','DNADDP','L_ASPR','NAMNPP','NAPRT','NICRNS','NMNDA','NNAM','NNATr','NNDMBRT','NNDPR','NP1_r','NT5C','QULNS','r0391','r0527','r0584'},{''}
            {'EX_ncam(e)'},{'-1'},{'1'},{''},{''},{'EX_nmn(e)','EX_nac(e)','EX_ncam(e)'},{'ASPO5','DNADDP','L_ASPR','NAMNPP','NAPRT','NICRNS','NMNDA','NNAM','NNATr','NNDMBRT','NNDPR','NP1_r','NT5C','QULNS','r0391','r0527','r0584'},{''},{''}
            {'EX_pydx5p(e)','EX_pydx(e)','EX_pydxn(e)','EX_pydam(e)'},{'-1'},{'1'},{''},{''},{'EX_pydx5p(e)','EX_pydx(e)','EX_pydxn(e)','EX_pydam(e)'},{'4HTHRK','4HTHRS','AMOPBHL','E4PD','OHPBAT','PDX5PO2','PDX5PSYN','PDXPP','PERD','PHTHRDH','DXPS'},{''},{''}
            {'EX_pydxn(e)'},{'1'},{'0'},{''},{''},{'EX_pydx5p(e)','EX_pydx(e)','EX_pydam(e)'},{'EX_pydxn(e)','PYDXNtr','PYDXNK','PDX5PO','PDX5PO2'},{'4HTHRK','4HTHRS','AMOPBHL','E4PD','OHPBAT','PDX5PO2','PDX5PSYN','PDXPP','PERD','PHTHRDH','DXPS','PYDXNK','r0389'},{''}
            %             {'EX_pydxn(e)'},{'0'},{''},{''},{''},{'EX_pydx5p(e)','EX_pydx(e)','EX_pydam(e)'},{'EX_pydxn(e)','PYDXNtr','PYDXNK','PDX5PO','PDX5PO2'},{''},{''}
            {'EX_pydx(e)'},{'1'},{'0'},{''},{''},{'EX_pydx5p(e)','EX_pydxn(e)','EX_pydam(e)'},{'EX_pydx(e)','PYDXtr','PYDXK'},{'4HTHRK','4HTHRS','AMOPBHL','E4PD','OHPBAT','PDX5PO2','PDX5PSYN','PDXPP','PERD','PHTHRDH','DXPS'},{''}
            %             {'EX_pydx(e)'},{'0'},{''},{''},{''},{'EX_pydx5p(e)','EX_pydxn(e)','EX_pydam(e)'},{'EX_pydx(e)','PYDXtr','PYDXK'},{''},{''}
            {'EX_pydam(e)'},{'1'},{'0'},{''},{''},{'EX_pydx5p(e)','EX_pydxn(e)','EX_pydx(e)'},{'EX_pydam(e)','PYDAMtr','PYDAMK','PYAM5POr'},{'4HTHRK','4HTHRS','AMOPBHL','E4PD','OHPBAT','PDX5PO2','PDX5PSYN','PDXPP','PERD','PHTHRDH','DXPS'},{''}
            {'EX_pydx(e)','EX_pydam(e)'},{'-1'},{'1'},{''},{''},{'EX_pydx(e)','EX_pydam(e)','EX_pydx5p(e)'},{'EX_pydxn(e)','PYDXNtr','PYDXNK','PDX5PO','PDX5PO2'},{''},{''}
            {'EX_pydx(e)','EX_pydx5p(e)'},{'-1'},{'1'},{''},{''},{'EX_pydx(e)','EX_pydam(e)','EX_pydx5p(e)'},{'EX_pydxn(e)','PYDXNtr','PYDXNK','PDX5PO','PDX5PO2'},{''},{''}
            {'EX_pydxn(e)','EX_pydam(e)'},{'-1'},{'1'},{''},{''},{'EX_pydxn(e)','EX_pydam(e)','EX_pydx5p(e)'},{'EX_pydx(e)','PYDXtr','PYDXK'},{''},{''}
            {'EX_pydx(e)','EX_pydxn(e)'},{'-1'},{'1'},{''},{''},{'EX_pydx(e)','EX_pydxn(e)','EX_pydx5p(e)'},{'EX_pydam(e)','PYDAMtr','PYDAMK','PYAM5POr'},{''},{''}
            {'EX_pydx5p(e)'},{'-1'},{'1'},{''},{''},{'EX_pydxn(e)','EX_pydam(e)','EX_pydx5p(e)'},{'EX_pydx(e)','PYDXtr','PYDXK'},{''},{''}
            {'EX_pydam(e)'},{'-1'},{'1'},{''},{''},{'EX_pydxn(e)','EX_pydam(e)','EX_pydx5p(e)'},{'EX_pydx(e)','PYDXtr','PYDXK'},{''},{''}
            {'EX_pydxn(e)'},{'-1'},{'1'},{''},{''},{'EX_pydxn(e)','EX_pydam(e)','EX_pydx5p(e)'},{'EX_pydx(e)','PYDXtr','PYDXK'},{''},{''}
            {'EX_4abz(e)'},{'1'},{'0'},{''},{''},{''},{'EX_4abz(e)','4ABZt2'},{'ADCL','PABB','CHORS','PSCVT','SHKK','SHK3Dr','DHQS','DHQTi','DDPA'},{''}
            {'EX_fol(e)','EX_4abz(e)'},{'-1'},{'1'},{''},{''},{'EX_fol(e)','EX_4abz(e)'},{'ADCL','ADCS','AKP1','CHORS','DDPA','DHFOR2','DHFR','DHFS','DHNPA','DHPS','DHQS','DHQTi','DM_GCALD','DNMPPA','DNTPPA','FOLD3','FOLR3','FTHFCL','FTHFD','FTHFL','GTPCI','HPPK','METFR','MTHFC','MTHFD','PSCVT','r0792','SHK3Dr','SHKK'},{''},{''}
            {'EX_fol(e)'},{'-1'},{'1'},{''},{''},{'EX_fol(e)'},{'DHPS','DHFS','DHFR','DHNPA','AKP1','GTPCI','EX_gcald(e)','GCALDt','EX_4abz(e)','4ABZt2'},{''},{''}
            {'EX_4abz(e)'},{'-1'},{'1'},{''},{''},{'EX_fol(e)','EX_4abz(e)'},{'ADCL','ADCS','AKP1','CHORS','DDPA','DHFOR2','DHFR','DHFS','DHNPA','DHPS','DHQS','DHQTi','DM_GCALD','DNMPPA','DNTPPA','FOLD3','FOLR3','FTHFCL','FTHFD','FTHFL','GTPCI','HPPK','METFR','MTHFC','MTHFD','PSCVT','r0792','SHK3Dr','SHKK'},{''},{''}
            {'EX_mqn7(e)'},{'-1'},{'1'},{''},{''},{'EX_mqn7(e)','EX_4hbz(e)'},{'IPFPHS','HEXTT','HETT','ICHORS','2S6HCC','SUCBZS','SUCBZL','NPHS','DHNAOT4','CHORS','PSCVT','SHKK','SHK3Dr','DHQTi','DHQS','DDPA','AHC','PPA'},{''},{''}
            {'EX_mqn7(e)'},{'1'},{'0'},{''},{''},{''},{'EX_mqn7(e)','MK7t'},{'IPFPHS','HEXTT','HETT','ICHORS','2S6HCC','SUCBZS','SUCBZL','NPHS','DHNAOT4','CHORS','PSCVT','SHKK','SHK3Dr','DHQTi','DHQS','DDPA'},{''}
            {'EX_mqn8(e)'},{'-1'},{'1'},{''},{''},{'EX_mqn8(e)','EX_4hbz(e)'},{'IPFPHS','HEXTT','HETT','ICHORS','2S6HCC','SUCBZS','SUCBZL','NPHS','DHNAOT4','AMMQT8r','DM_2obut[c]','DHNAOT','PPA'},{''},{''}
            {'EX_mqn8(e)'},{'1'},{'0'},{''},{''},{''},{'EX_mqn8(e)','MK8t'},{'IPFPHS','HEXTT','HETT','ICHORS','2S6HCC','SUCBZS','SUCBZL','NPHS','DHNAOT4','AMMQT8r','DM_2obut[c]'},{''}
            {'EX_q8(e)'},{'-1'},{'1'},{''},{''},{'EX_q8(e)','EX_4hbz(e)','EX_o2(e)'},{'DDPA','DHQS','DHQTi','SHK3Dr','SHKK','PSCVT','CHORS','CHRPL','IPFPHS','HEXTT','HETT','HBZOPT','OPHBDC','OHPHM','OMBZLM','OMMBLHX3','OMPHHX3','OPHHX3','2OMPHH','URFGTT','2OMMBOX','DMQMT','DMQMT2','AHC','PPA'},{''},{''}
            {'EX_q8(e)'},{'1'},{'0'},{''},{''},{''},{'EX_q8(e)','Q8abc'},{'DDPA','DHQS','DHQTi','SHK3Dr','SHKK','PSCVT','CHORS','CHRPL','IPFPHS','HEXTT','HETT','HBZOPT','NOPHMO','OPHHX','OPHBDC','OHPHM','OMBZLM','OMMBLHX3','OMPHHX3','OPHHX3','2OMPHH','URFGTT','2OMMBOX','DMQMT','DMQMT2'},{''}
             {'EX_pnto_R(e)'},{'-1'},{'1'},{''},{''},{'EX_pnto_R(e)'},{'ACLS_b','ASP1DC','DHAD1','DPR','KARA1','MOHMT','PANTS','VALTA'},{''},{''}
            {'EX_pnto_R(e)'},{'1'},{'0'},{''},{''},{''},{'EX_pnto_R(e)','PNTOabc'},{'ACLS_b','ASP1DC','DHAD1','DPR','KARA1','MOHMT','PANTS','VALTA'},{''}
            {'EX_ribflv(e)'},{'-1'},{'1'},{''},{''},{'EX_ribflv(e)'},{'APRAUR','DB4PS','DHPPDA','GTPCII','PMDPHT','RBFSa','RBFSb'},{''},{''}
            {'EX_ribflv(e)'},{'1'},{'0'},{''},{''},{''},{'EX_ribflv(e)','RIBFLVt2r'},{'APRAUR','DB4PS','DHPPDA','GTPCII','PMDPHT','RBFSa','RBFSb'},{''}
            {'EX_thm(e)'},{'-1'},{'1'},{''},{''},{'EX_thm(e)'},{'AHMMPS','AMPMS2','DM_4HBA','DM_GCALD','DXPS','GARFTi','GART','GLUPRT','HETZK','HMPK1','PMPK','PRAGS','PRAIS','PRFGS','THZPSN','TMDPK','TMK','TMN','TMPK','TMPPP'},{''},{''}
            {'EX_thm(e)'},{'1'},{'0'},{''},{''},{''},{'EX_thm(e)','THMabc','DM_thmpp(c)'},{'AHMMPS','AMPMS2','DM_4HBA','DM_GCALD','DXPS','GARFTi','GART','GLUPRT','HETZK','HMPK1','PMPK','PRAGS','PRAIS','PRFGS','THZPSN','TMDPK','TMK','TMN','TMPK','TMPPP'},{''}
            {'EX_adocbl(e)'},{'1'},{'0'},{''},{''},{''},{'EX_adocbl(e)','ADOCBLabc','DM_adocbl(c)','EX_cbl1(e)','CBL1abc'},{},{''}
            {'EX_btn(e)'},{'-1'},{'1'},{''},{''},{'EX_btn(e)'},{'BTNCLi','ACCOACL','MALCOAMT','MALCOACD','3OAACPR1','3HACPR1','EACPR1','GACPCD','3OAACPR2','3HACPR2','EACPR2','PMACPME','AOXSr2','AMAOTr','DM_AMOB','MEOHt2','EX_meoh(e)','DBTS','BTS4','5DOAN','DM_5DRIB','sink_s'},{''},{''}
            {'EX_btn(e)'},{'1'},{'0'},{''},{''},{''},{'EX_btn(e)','BTNabc','DM_btn'},{'MALCOAMT','MALCOACD','3OAACPR1','3HACPR1','EACPR1','GACPCD','3OAACPR2','3HACPR2','EACPR2','PMACPME','AOXSr2','AMAOTr','DM_AMOB','MEOHt2','EX_meoh(e)','DBTS','BTS4','5DOAN','DM_5DRIB','sink_s'},{''}
            {'EX_btn(e)'},{'0'},{'1'},{''},{''},{''},{'EX_btn(e)','BTNabc'},{''},{''}
            {'EX_pheme(e)'},{'-1'},{'1'},{''},{''},{'EX_pheme(e)'},{'CPPPGO2','DM_dad_5','FCLTc','G1SAT','GLUTRR','GLUTRS','HMBS','PPBNGS','PPPGO3','UPP3S','UPPDC1','EX_succ(e)','SUCCt'},{''},{''}
            {'EX_pheme(e)'},{'1'},{'0'},{''},{''},{''},{'EX_pheme(e)','HEMEti','DM_pheme(c)'},{'CPPPGO2','DM_dad_5','FCLTc','G1SAT','GLUTRR','GLUTRS','HMBS','PPBNGS','PPPGO3','UPP3S','UPPDC1','EX_succ(e)','SUCCt'},{''}
            {'EX_sheme(e)'},{'-1'},{'1'},{''},{''},{'EX_sheme(e)'},{'CPPPGO2','DM_dad_5','FCLTc','G1SAT','GLUTRR','GLUTRS','HMBS','PPBNGS','PPPGO3','UPP3S','UPP3MT','SHCHD2','SHCHF'},{''},{''}
            {'EX_ura(e)'},{'-1'},{'1'},{''},{''},{'EX_ura(e)'},{'CBPS','ASPCT','DHORTS','DHORDfum','OROTPT','OMPDC','UMPK','URIK1','EX_succ(e)','SUCCt','EX_q8(e)','Q8abc','EX_mqn8(e)','MK8t'},{''},{''}
            {'EX_ura(e)'},{'1'},{'0'},{''},{''},{''},{'EX_ura(e)','URAt2'},{'CBPS','ASPCT','DHORTS','DHORDfum','OROTPT','OMPDC','UMPK','URIK1','EX_succ(e)','SUCCt'},{''}
            {'EX_uri(e)'},{'-1'},{'1'},{''},{''},{'EX_uri(e)'},{'RPI','RPE','PPM','TALA','TKT1','TKT2'},{''},{''}
            {'EX_csn(e)'},{'-1'},{'1'},{''},{''},{'EX_csn(e)'},{'EX_ura(e)','URAt2','URIK4','UMPK','NDPK2','CTPS1','CTPS2','PPM'},{''},{''}
            {'EX_adn(e)'},{'-1'},{'1'},{''},{''},{'EX_adn(e)'},{'ADSS','ADSL1r','IMPC','AICART','ADSL2r','PRASCSi','AIRC4','PRAIS','PRFGS','H2CO3D','EX_fum(e)','FUMt','EX_hxan(e)','HXANt2','GMPS2'},{''},{''}
            {'EX_adn(e)'},{'1'},{'0'},{''},{''},{''},{'EX_adn(e)','ADEt2','ADPT'},{'ADSS','ADSL1r','IMPC','AICART','ADSL2r','PRASCSi','AIRC4','PRAIS','PRFGS','H2CO3D','EX_fum(e)','FUMt'},{''}
            {'EX_ade(e)'},{'1'},{'0'},{''},{''},{'EX_adn(e)'},{'EX_ade(e)','ADEt2','ADPT'},{'ADSS','ADSL1r','IMPC','AICART','ADSL2r','PRASCSi','AIRC4','PRAIS','PRFGS','H2CO3D','EX_fum(e)','FUMt'},{''}
            {'EX_ins(e)'},{'-1'},{'1'},{''},{''},{'EX_ins(e)'},{'GLUPRT','PRAGS','GARFTi','PRFGS','PRAIS','AIRC4','PRASCSi','ADSL2r','AICART','IMPC','NTD11','H2CO3D'},{''},{''}
            {'EX_ins(e)'},{'1'},{'0'},{''},{''},{'EX_ins(e)'},{'EX_ins(e)','INSt2'},{'GLUPRT','PRAGS','GARFTi','PRFGS','PRAIS','AIRC4','PRASCSi','ADSL2r','AICART','IMPC','NTD11','H2CO3D'},{''}
            {'EX_gua(e)'},{'-1'},{'1'},{''},{''},{'EX_gua(e)'},{'GLUPRT','PRAGS','GARFTi','PRFGS','PRAIS','AIRC4','PRASCSi','ADSL2r','AICART','IMPC','IMPD','GMPS2','H2CO3D','r0456'},{''},{''}
            {'EX_gua(e)'},{'1'},{'0'},{''},{''},{'EX_gua(e)'},{'EX_gua(e)','GUAt2'},{'GLUPRT','PRAGS','GARFTi','PRFGS','PRAIS','AIRC4','PRASCSi','ADSL2r','AICART','IMPC','IMPD','GMPS2','H2CO3D','r0456'},{''}
            {'EX_dgsn(e)'},{'-1'},{'1'},{''},{''},{'EX_dgsn(e)'},{'EX_gua(e)','GUAt2'},{''},{''}
            {'EX_thymd(e)'},{'-1'},{'1'},{''},{''},{'EX_thymd(e)'},{'URIDK3','RNDR4','DURIK1','TMDS','TMDSf'},{''},{''}
            {'EX_thymd(e)'},{'1'},{'0'},{''},{''},{''},{'EX_thymd(e)','THMDt2'},{'URIDK3','RNDR4','DURIK1','TMDS','TMDSf'},{''}
            {'EX_hxan(e)'},{'-1'},{'1'},{''},{''},{'EX_hxan(e)'},{'ADSS','ADSL1r','IMPC','AICART','ADSL2r','PRASCSi','AIRC4','PRAIS','PRFGS','ADK1','AMPN','ADD','H2CO3D'},{''},{''}
            {'EX_hxan(e)'},{'1'},{'0'},{''},{''},{''},{'EX_hxan(e)','HXANt2'},{'ADSS','ADSL1r','IMPC','AICART','ADSL2r','PRASCSi','AIRC4','PRAIS','PRFGS','ADK1','AMPN','ADD','H2CO3D'},{''}
            {'EX_xan(e)'},{'-1'},{'1'},{''},{''},{'EX_xan(e)'},{'H2CO3D'},{''},{''}
            {'EX_cit(e)'},{'-1'},{'1'},{''},{''},{'EX_cit(e)'},{'CA2abc'},{'CITCAt'},{''}
            {'EX_lanost(e)'},{'-1'},{'1'},{''},{''},{'EX_lanost(e)'},{'DMATT','GRTT','DMPPS','IPDDI','DXPS','DXPRIi','MEPCT','CDPMEK','MECDPS','MECDPDH2'},{'EX_lanost(e)','LANOSTt','SSQEPXS','SQLErev'},{''}
            };
        
      modelPrevious=model;
        
        %% go through the conditions one by one to find the ones that fit
        for i=2:length(conditions)
            metToTest=conditions{i,1};
            go=1;
            % test if the conditions match
            clear invitro;
            clear insilico;
            for j=1:length(metToTest)
                invitro(j,1)=string(speciesNutrRequ{find(strcmp(speciesNutrRequ(:,1),metToTest{j})),2});
                insilico(j,1)=string(speciesNutrRequ{find(strcmp(speciesNutrRequ(:,1),metToTest{j})),3});
            end
            if any(~strcmp(invitro,conditions{i,2}{1})) || any(~strcmp(insilico,conditions{i,3}{1}))
                go=0;
            end
            if ~isempty(conditions{i,4}{1})
                if ~any(strcmp(model.rxns,conditions{i,4}))
                    go=0;
                end
            end
            if ~isempty(conditions{i,5}{1})
                if any(strcmp(model.rxns,conditions{i,5}))
                    go=0;
                end
            end
            if ~isempty(conditions{i,9}{1})
                if strncmp(microbeID,conditions{i,9},length(conditions{i,9}{1}))
                    go=0;
                end
            end
            if go==1
                % proceed to make the proposed changes and test if they
                % work
                model=modelPrevious;
                % for false negatives
                % test if the model  can grow and put reactions back in as needed
                if strcmp('1',conditions{i,2}{1})
                    for j=1:length(conditions{i,7})
                        formula = database.reactions{find(strcmp(database.reactions(:, 1), conditions{i,7}{j})), 3};
                        model = addReaction(model, conditions{i,7}{j}, 'reactionFormula', formula, 'geneRule', 'GrowthRequirementsGapfill');
                        if strncmp(conditions{i,7}{j},'DM_',3)
                            model=changeRxnBounds(model,conditions{i,7}{j},0.1','l');
                        end
                    end
                    model=changeRxnBounds(model,conditions{i,6},0,'l');
                    % remove alternate sources
                    for j=1:length(metToTest)
                        findExch=find(strcmp(alternateSources(:,1),metToTest{j}));
                        if ~isempty(findExch)
                            altExch=alternateSources(findExch,find(~cellfun(@isempty, alternateSources(findExch,1:end))));
                            model=changeRxnBounds(model,altExch,0,'l');
                        end
                    end
                    % if oxygen is required
                    if strcmp(metToTest,'EX_pydam(e)')
                        model = changeRxnBounds(model, 'EX_o2(e)', -1, 'l');
                    end
                    % enable uptake of in all vitro essential nutrients
                    for j=1:length(speciesNutrRequ)
                        if strcmp(speciesNutrRequ{j,2},'1') || strcmp(speciesNutrRequ{j,2},'0')
                            model=changeRxnBounds(model,speciesNutrRequ{j,1},-1,'l');
                        end
                    end
                    % delete reactions that are not annotated and test if
                    % they can be safely removed
                    [rxnsInModel,IA,IB]=intersect(model.rxns,conditions{i,8});
                    idx = ~ismember(model.grRules(IA),gapfillGPRs,'rows');
                    rxnsInModel(idx==1,:)=[];
                    if ~isempty(rxnsInModel)
                        [grRatio, grRateKO, grRateWT, hasEffect, delRxn, fluxSolution] = singleRxnDeletion(model, 'FBA', rxnsInModel);
                        toDelete = rxnsInModel(grRateKO> tol);
                        modelTest = changeRxnBounds(model, toDelete,0,'b');
                        FBA=optimizeCbModel(modelTest,'max');
                        if FBA.f<tol
                            % find out which reactions need to be put back
                            % in
                            for j=1:length(toDelete)
                                origConstrLB=model.lb(find(strcmp(model.rxns,toDelete{j})),1);
                                origConstrUB=model.ub(find(strcmp(model.rxns,toDelete{j})),1);
                                modelBack=changeRxnBounds(model, toDelete{j},origConstrLB,'l');
                                modelBack=changeRxnBounds(modelBack, toDelete{j},origConstrUB,'u');
                                FBA=optimizeCbModel(modelBack,'max');
                                if FBA.f>tol
                                    toDelete{j}=[];
                                    % remaining reactions can be safely
                                    % deleted
                                    deletedMismatchRxns(length(deletedMismatchRxns)+1:length(deletedMismatchRxns)+length(toDelete),1)=toDelete;
                                    break
                                end
                            end
                        else
                            % all unannotated reactions can be safely
                            % deleted
                            deletedMismatchRxns(length(deletedMismatchRxns)+1:length(deletedMismatchRxns)+length(toDelete),1)=toDelete;
                        end
                    end
                elseif strcmp('-1',conditions{i,2}{1})
                    % for false positives
                    % test which reactions need to be gap-filled to enable
                    % growth without the growth factor
                    model=removeRxns(model,conditions{i,8});
                    model=changeRxnBounds(model,conditions{i,6},0,'l');
                    % remove alternate sources
                    for j=1:length(metToTest)
                        findExch=find(strcmp(alternateSources(:,1),metToTest{j}));
                        if ~isempty(findExch)
                            altExch=alternateSources(findExch,find(~cellfun(@isempty, alternateSources(findExch,1:end))));
                            model=changeRxnBounds(model,altExch,0,'l');
                        end
                    end
                    
                    % relax enforced uptake of vitamins-causes infeasibility problems
                    relaxConstraints=model.rxns(find(model.lb>0));
                    model=changeRxnBounds(model,relaxConstraints,0,'l');
                    
                    % species cases
                    if length(metToTest)<4
                        if length(intersect(metToTest,{'EX_pydx(e)','EX_pydxn(e)'}))==2
                            model = changeRxnBounds(model, {'EX_o2(e)','EX_pydam(e)'}, -1, 'l');
                        end
                        if length(intersect(metToTest,{'EX_pydx(e)','EX_pydam(e)'}))==2
                            model = changeRxnBounds(model, {'EX_pydxn(e)'}, -1, 'l');
                        end
                        if length(intersect(metToTest,{'EX_pydx(e)','EX_pydx5p(e)'}))==2
                            model = changeRxnBounds(model, {'EX_pydxn(e)'}, -1, 'l');
                        end
                        if length(intersect(metToTest,{'EX_pydxn(e)','EX_pydam(e)'}))==2
                            model = changeRxnBounds(model, {'EX_pydx'}, -1, 'l');
                        end
                    end
                    % if oxygen is required
                    if any(strcmp(metToTest,'EX_pydam(e)')) || any(strcmp(metToTest,'EX_q8(e)'))
                        model = changeRxnBounds(model, 'EX_o2(e)', -1, 'l');
                    end
                    % enable uptake of all in vitro essential or possibly essential nutrients
                    for j=1:length(speciesNutrRequ)
                        if strcmp(speciesNutrRequ{j,2},'1') || strcmp(speciesNutrRequ{j,2},'0')
                            model=changeRxnBounds(model,speciesNutrRequ{j,1},-1,'l');
                        end
                    end
                    % add the gap-filling reactions to test them afterwards
                    [rxnsToAdd,IA]=setdiff(conditions{i,7},model.rxns);
                    if ~isempty(rxnsToAdd)
                        for j=1:length(rxnsToAdd)
                            formula = database.reactions{find(strcmp(database.reactions(:, 1), rxnsToAdd{j})), 3};
                            model = addReaction(model, rxnsToAdd{j}, 'reactionFormula', formula, 'geneRule', 'GrowthRequirementsGapfill');
                            % for the ones that are essential in vitro
                        end
                        FBA=optimizeCbModel(model,'max');
                        if FBA.f>tol
                            % test if all reactions are needed
                            if ~isempty(rxnsToAdd)
                                [grRatio, grRateKO, grRateWT, hasEffect, ~, fluxSolution] = singleRxnDeletion(model, 'FBA', rxnsToAdd);
                                toRemove = rxnsToAdd(grRateKO> tol);
                                % remove exchange reactions, otherwise this
                                % step may fail
                                toRemove(strncmp(toRemove,'EX_',3))=[];
                                neccRxns=setdiff(rxnsToAdd,toRemove);
                                modelTest = changeRxnBounds(model, toRemove,0,'b');
                                FBA=optimizeCbModel(modelTest,'max');
                                if FBA.f>tol
                                    % only add the reactions that are needed
                                    addedMismatchRxns(length(addedMismatchRxns)+1:length(addedMismatchRxns)+length(neccRxns),1)=neccRxns;
                                else
                                    % find out which reactions need to be put back
                                    % in
                                    for j=1:length(toRemove)
                                        origConstrLB=model.lb(find(strcmp(model.rxns,toRemove{j})),1);
                                        origConstrUB=model.ub(find(strcmp(model.rxns,toRemove{j})),1);
                                        modelBack=changeRxnBounds(modelTest, toRemove{j},origConstrLB,'l');
                                        modelBack=changeRxnBounds(modelBack, toRemove{j},origConstrUB,'u');
                                        FBA=optimizeCbModel(modelBack,'max');
                                        allFBA(j)=FBA.f;
                                        if FBA.f > tol
                                            neccRxns{length(neccRxns)+1}=rxnsToAdd{j};
                                            % adding this reaction bck in is
                                            % sufficient
                                            addedMismatchRxns(length(addedMismatchRxns)+1:length(addedMismatchRxns)+length(neccRxns),1)=neccRxns;
                                            break
                                        end
                                    end
                                    % if putting one back isn't enough
                                    if sum(allFBA) < tol
                                        addedMismatchRxns(length(addedMismatchRxns)+1:length(addedMismatchRxns)+length(toRemove),1)=toRemove;
                                    end
                                end
                            end
                        end
                    end
                    % if not clear from the experimental data, but possibly
                    % essential
                elseif strcmp('0',conditions{i,2}{1})
                    if strcmp(insilico,'0')
                        [rxnsToAdd,IA]=setdiff(conditions{i,7},model.rxns);
                        if ~isempty(rxnsToAdd)
                            for j=1:length(rxnsToAdd)
                                addedMismatchRxns(length(addedMismatchRxns)+1:length(addedMismatchRxns)+length(rxnsToAdd),1)=rxnsToAdd;
                            end
                        end
                    elseif strcmp(insilico,'1')
                        model=removeRxns(model,conditions{i,8});
                        model=changeRxnBounds(model,conditions{i,6},0,'l');
                        % remove alternate sources
                        for j=1:length(metToTest)
                            findExch=find(strcmp(alternateSources(:,1),metToTest{j}));
                            if ~isempty(findExch)
                                altExch=alternateSources(findExch,find(~cellfun(@isempty, alternateSources(findExch,1:end))));
                                model=changeRxnBounds(model,altExch,0,'l');
                            end
                        end
                        % add the gap-filling reactions to test them afterwards
                        [rxnsToAdd,IA]=setdiff(conditions{i,7},model.rxns);
                        if ~isempty(rxnsToAdd)
                            for j=1:length(rxnsToAdd)
                                formula = database.reactions{find(strcmp(database.reactions(:, 1), rxnsToAdd{j})), 3};
                                model = addReaction(model, rxnsToAdd{j}, 'reactionFormula', formula, 'geneRule', 'GrowthRequirementsGapfill');
                                % for the ones that are essential in vitro
                            end
                            FBA=optimizeCbModel(model,'max');
                            if FBA.f>tol
                                % test if all reactions are needed
                                if ~isempty(rxnsToAdd)
                                    [grRatio, grRateKO, grRateWT, hasEffect, ~, fluxSolution] = singleRxnDeletion(model, 'FBA', rxnsToAdd);
                                    toRemove = rxnsToAdd(grRateKO> tol);
                                    % remove exchange reactions, otherwise this
                                    % step may fail
                                    toRemove(strncmp(toRemove,'EX_',3))=[];
                                    neccRxns=setdiff(rxnsToAdd,toRemove);
                                    modelTest = changeRxnBounds(model, toRemove,0,'b');
                                    FBA=optimizeCbModel(modelTest,'max');
                                    if FBA.f>tol
                                        % only add the reactions that are needed
                                        addedMismatchRxns(length(addedMismatchRxns)+1:length(addedMismatchRxns)+length(neccRxns),1)=neccRxns;
                                    else
                                        % find out which reactions need to be put back
                                        % in
                                        for j=1:length(toRemove)
                                            origConstrLB=model.lb(find(strcmp(model.rxns,toRemove{j})),1);
                                            origConstrUB=model.ub(find(strcmp(model.rxns,toRemove{j})),1);
                                            modelBack=changeRxnBounds(modelTest, toRemove{j},origConstrLB,'l');
                                            modelBack=changeRxnBounds(modelBack, toRemove{j},origConstrUB,'u');
                                            FBA=optimizeCbModel(modelBack,'max');
                                            FBA.f
                                            if FBA.f>tol
                                                neccRxns{length(neccRxns)+1}=rxnsToAdd{j};
                                                % adding this reaction bck in is
                                                % sufficient
                                                addedMismatchRxns(length(addedMismatchRxns)+1:length(addedMismatchRxns)+length(neccRxns),1)=neccRxns;
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        %% make the proposed changes to reconstruction
        model=convertOldStyleModel(modelPrevious);
        modelOld=model;
        addedMismatchRxns(find(cellfun(@isempty,addedMismatchRxns)))=[];
        deletedMismatchRxns(find(cellfun(@isempty,deletedMismatchRxns)))=[];
        if ~isempty(deletedMismatchRxns)
            deletedMismatchRxns = unique(deletedMismatchRxns);
            delInd=[];
            % in rare cases will abolish growth
            for i=1:length(deletedMismatchRxns)
                modelTest = removeRxns(model, deletedMismatchRxns{i});
                FBA=optimizeCbModel(modelTest,'max');
                if FBA.f > tol
                    model=modelTest;
                else
                    delInd(length(delInd)+1)=i;
                end
            end
            if ~isempty(delInd)
                deletedMismatchRxns(delInd)=[];
            end
        end
        
        
        if ~isempty(addedMismatchRxns)
            addedMismatchRxns = unique(addedMismatchRxns(:, 1));
            % check for reactions being replaced with duplicates. Need to propagate
            % GPR in these cases.
            for j = 1:length(addedMismatchRxns)
                if any(strcmp(modelOld.rxns,addedMismatchRxns{j, 1}))
                    getGPR{j, 1}=modelOld.grRules{find(strcmp(modelOld.rxns,addedMismatchRxns{j, 1})),1};
                else
                    getGPR{j, 1}= 'GrowthRequirementsGapfill';
                    RxForm = database.reactions(find(ismember(database.reactions(:, 1), addedMismatchRxns{j, 1})), 3);
                    modelOld = addReaction(modelOld, addedMismatchRxns{j, 1}, RxForm{1, 1});
                end
            end
            % check for reversible/irreversible versions of the same reaction and
            % propagate GPRs
            [modelOut, removedRxnInd, keptRxnInd] = checkDuplicateRxn(modelOld);
            remRxns=modelOld.rxns(removedRxnInd);
            keptRxns=modelOld.rxns(keptRxnInd);
            % replace GPRs if possible
            GPRToReplace=intersect(remRxns,addedMismatchRxns);
            if ~isempty(GPRToReplace)
                for j=1:length(GPRToReplace)
                    findEntry=find(strcmp(addedMismatchRxns,GPRToReplace{j, 1}));
                    % find the matching reaction to delete/replace GPR
                    toDelete=find(ismember(removedRxnInd,find(strcmp(modelOld.rxns,GPRToReplace{j, 1}))));
                    getGPR{findEntry, 1}=modelOld.grRules{toDelete,1};
                    model = removeRxns(model, keptRxns{toDelete,1});
                end
            end
            for j = 1:length(addedMismatchRxns)
                % find the formula
                RxForm = database.reactions(find(ismember(database.reactions(:, 1), addedMismatchRxns{j, 1})), 3);
                model = addReaction(model, addedMismatchRxns{j, 1}, RxForm{1, 1});
                rxnID = find(ismember(model.rxns, addedMismatchRxns{j, 1}));
                % propagate GPR if possible
                model.grRules{rxnID, 1} = getGPR{j, 1};
                model.comments{rxnID, 1} = 'Added to enable growth without nonessential nutrients based ion experimental data.';
                model.citations{rxnID, 1} = '';
                model.rxnECNumbers{rxnID,1} = '';
                model.rxnKEGGID{rxnID,1} = '';
                model.rxnConfidenceScores(rxnID,1) = 0;
            end
        end
        
        %% try gapfilling of already refined model
                
        % enable uptake of potentially essential exchanges
        model=changeRxnBounds(model,essentialComp,-1,'l');
        
        % prevent uptake of nonessential exchanges
        model=changeRxnBounds(model,nonessentialComp,0,'l');
        
        % check if growth is possible, try gapfilling otherwise
        FBA = optimizeCbModel(model, 'max');
        if FBA.f < tol || FBA.stat==0
            model = targetedGapFilling(model,'max',database);
            % Save the gapfilled reactions
            for n = 1:length(model.rxns)
                if ~isempty(strfind(model.rxns{n, 1}, '_tGF'))
                    addedMismatchRxns{length(addedMismatchRxns)+1, 1} = strrep(model.rxns{n}, '_tGF', '');
                    model.rxns{n, 1}=strrep(model.rxns{n}, '_tGF', '');
                    model.grRules{n, 1} = 'GrowthRequirementsGapfill';
                end
            end
        end
    end
end

% relax enforced uptake of vitamins-causes infeasibility problems
relaxConstraints=model.rxns(find(model.lb>0));
model=changeRxnBounds(model,relaxConstraints,0,'l');

% change back to unlimited medium
% list exchange reactions
exchanges = model.rxns(strncmp('EX_', model.rxns, 3));
% open all exchanges
model = changeRxnBounds(model, exchanges, -1000, 'l');
model = changeRxnBounds(model, exchanges, 1000, 'u');

end
