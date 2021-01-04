function [TruePositives, FalseNegatives] = testSecretionProducts(model, microbeID, biomassReaction)
% Performs an FVA and reports those secretions (exchange reactions)
% that can be secreted by the model and should be secreted according to
% data (true positives) and those secretions that cannot be secreted by
% the model but should be secreted according to in vitro data (false
% negatives).
% Based on literature search of reported secretion-secreting probiotics
% performed 11/2017
%
% INPUT
% model             COBRA model structure
% microbeID         Microbe ID in secretion secretion data file
% biomassReaction   Biomass objective functions (low flux through BOF
%                   required in analysis)
%
% OUTPUT
% TruePositives     Cell array of strings listing all secretions
%                   (exchange reactions) that can be secreted by the model
%                   and in in vitro data.
% FalseNegatives    Cell array of strings listing all secretions
%                   (exchange reactions) that cannot be secreted by the model
%                   but should be secreted according to in vitro data.
%
% Almut Heinken, August 2019

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end
solver = CBT_LP_SOLVER;

fileDir = fileparts(which('ReactionTranslationTable.txt'));
metaboliteDatabase = readtable([fileDir filesep 'MetaboliteDatabase.txt'], 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
metaboliteDatabase=table2cell(metaboliteDatabase);

% read secretion product tables
secretionTable = readtable('secretionProductTable.txt', 'Delimiter', '\t');
% remove the reference columns
for i=1:11
    if ismember(['Ref' num2str(i)],secretionTable.Properties.VariableNames)
secretionTable.(['Ref' num2str(i)])=[];
    end
end
secretionExchanges = {'2-oxobutyrate','EX_2obut(e)','','','','','','','','','','','','','','';'2-oxoglutarate','EX_akg(e)','','','','','','','','','','','','','','';'4-Hydroxyproline','EX_4hpro_LT(e)','','','','','','','','','','','','','','';'Acetate','EX_ac(e)','','','','','','','','','','','','','','';'Alginate','EX_algin(e)','','','','','','','','','','','','','','';'alpha-Mannan','EX_mannan(e)','','','','','','','','','','','','','','';'Amylopectin','EX_amylopect900(e)','','','','','','','','','','','','','','';'Amylose','EX_amylose300(e)','','','','','','','','','','','','','','';'Arabinan','EX_arabinan101(e)','','','','','','','','','','','','','','';'Arabinogalactan','EX_arabinogal(e)','','','','','','','','','','','','','','';'Arabinoxylan','EX_arabinoxyl(e)','','','','','','','','','','','','','','';'Arbutin','EX_arbt(e)','','','','','','','','','','','','','','';'beta-Glucan','EX_bglc(e)','','','','','','','','','','','','','','';'Butanol','EX_btoh(e)','','','','','','','','','','','','','','';'Butyrate','EX_but(e)','','','','','','','','','','','','','','';'Cellobiose','EX_cellb(e)','','','','','','','','','','','','','','';'Cellotetrose','EX_cellttr(e)','','','','','','','','','','','','','','';'Cellulose','EX_cellul(e)','','','','','','','','','','','','','','';'Chitin','EX_chitin(e)','','','','','','','','','','','','','','';'Choline','EX_chol(e)','','','','','','','','','','','','','','';'Chondroitin sulfate','EX_cspg_a(e)','EX_cspg_b(e)','EX_cspg_c(e)','','','','','','','','','','','','';'cis-Aconitate','EX_acon_C(e)','','','','','','','','','','','','','','';'Citrate','EX_cit(e)','','','','','','','','','','','','','','';'CO2','EX_co2(e)','','','','','','','','','','','','','','';'D-arabinose','EX_arab_D(e)','','','','','','','','','','','','','','';'Deoxyribose','EX_drib(e)','','','','','','','','','','','','','','';'Dextran','EX_dextran40(e)','','','','','','','','','','','','','','';'Dextrin','EX_dextrin(e)','','','','','','','','','','','','','','';'D-Fructuronate','EX_fruur(e)','','','','','','','','','','','','','','';'D-galacturonic acid','EX_galur(e)','','','','','','','','','','','','','','';'D-gluconate (Entner-Doudoroff pathway)','EX_glcn(e)','','','','','','','','','','','','','','';'D-glucosamine','EX_gam(e)','','','','','','','','','','','','','','';'D-glucose','EX_glc_D(e)','','','','','','','','','','','','','','';'D-glucuronic acid','EX_glcur(e)','','','','','','','','','','','','','','';'D-maltose','EX_malt(e)','','','','','','','','','','','','','','';'D-Psicose','EX_psics_D(e)','','','','','','','','','','','','','','';'D-ribose','EX_rib_D(e)','','','','','','','','','','','','','','';'D-Sorbitol','EX_sbt_D(e)','','','','','','','','','','','','','','';'D-Tagatose','EX_tagat_D(e)','','','','','','','','','','','','','','';'D-Tagaturonate','EX_tagur(e)','','','','','','','','','','','','','','';'D-Turanose','EX_turan_D(e)','','','','','','','','','','','','','','';'D-xylose','EX_xyl_D(e)','','','','','','','','','','','','','','';'Erythritol','EX_ethrtl(e)','','','','','','','','','','','','','','';'Ethanolamine','EX_etha(e)','','','','','','','','','','','','','','';'Fructooligosaccharides','EX_kesto(e)','EX_kestopt(e)','EX_kestottr(e)','','','','','','','','','','','','';'Fructose','EX_fru(e)','','','','','','','','','','','','','','';'Fumarate','EX_fum(e)','','','','','','','','','','','','','','';'Galactan','EX_galactan(e)','','','','','','','','','','','','','','';'Galactomannan','EX_galmannan(e)','','','','','','','','','','','','','','';'Galactosamine','EX_galam(e)','','','','','','','','','','','','','','';'Galactose','EX_gal(e)','','','','','','','','','','','','','','';'Glucomannan','EX_glcmannan(e)','','','','','','','','','','','','','','';'Glycerol','EX_glyc(e)','','','','','','','','','','','','','','';'Glycine','EX_gly(e)','','','','','','','','','','','','','','';'Glycogen','EX_glygn2(e)','','','','','','','','','','','','','','';'Heparin','EX_hspg(e)','','','','','','','','','','','','','','';'Homogalacturonan','EX_homogal(e)','','','','','','','','','','','','','','';'Hyaluronan','EX_ha(e)','','','','','','','','','','','','','','';'Indole','EX_indole(e)','','','','','','','','','','','','','','';'Inosine','EX_ins(e)','','','','','','','','','','','','','','';'Inositol','EX_inost(e)','','','','','','','','','','','','','','';'Inulin','EX_inulin(e)','','','','','','','','','','','','','','';'Isobutyrate','EX_isobut(e)','','','','','','','','','','','','','','';'Isomaltose','EX_isomal(e)','','','','','','','','','','','','','','';'Isovalerate','EX_isoval(e)','','','','','','','','','','','','','','';'Lactose','EX_lcts(e)','','','','','','','','','','','','','','';'L-alanine','EX_ala_L(e)','','','','','','','','','','','','','','';'Laminarin','EX_lmn30(e)','','','','','','','','','','','','','','';'L-arabinose','EX_arab_L(e)','','','','','','','','','','','','','','';'L-arabitol','EX_abt(e)','','','','','','','','','','','','','','';'L-arginine','EX_arg_L(e)','','','','','','','','','','','','','','';'L-asparagine','EX_asn_L(e)','','','','','','','','','','','','','','';'L-aspartate','EX_asp_L(e)','','','','','','','','','','','','','','';'L-cysteine','EX_cys_L(e)','','','','','','','','','','','','','','';'Levan','EX_levan1000(e)','','','','','','','','','','','','','','';'L-fucose','EX_fuc_L(e)','','','','','','','','','','','','','','';'L-glutamate','EX_glu_L(e)','','','','','','','','','','','','','','';'L-glutamine','EX_gln_L(e)','','','','','','','','','','','','','','';'L-histidine','EX_his_L(e)','','','','','','','','','','','','','','';'Lichenin','EX_lichn(e)','','','','','','','','','','','','','','';'L-Idonate','EX_idon_L(e)','','','','','','','','','','','','','','';'L-isoleucine','EX_ile_L(e)','','','','','','','','','','','','','','';'L-leucine','EX_leu_L(e)','','','','','','','','','','','','','','';'L-lysine','EX_lys_L(e)','','','','','','','','','','','','','','';'L-lyxose','EX_lyx_L(e)','','','','','','','','','','','','','','';'L-malate','EX_mal_L(e)','','','','','','','','','','','','','','';'L-methionine','EX_met_L(e)','','','','','','','','','','','','','','';'L-ornithine','EX_orn(e)','','','','','','','','','','','','','','';'L-phenylalanine','EX_phe_L(e)','','','','','','','','','','','','','','';'L-proline','EX_pro_L(e)','','','','','','','','','','','','','','';'L-rhamnose','EX_rmn(e)','','','','','','','','','','','','','','';'L-serine','EX_ser_L(e)','','','','','','','','','','','','','','';'L-Sorbose','EX_srb_L(e)','','','','','','','','','','','','','','';'L-threonine','EX_thr_L(e)','','','','','','','','','','','','','','';'L-tryptophan','EX_trp_L(e)','','','','','','','','','','','','','','';'L-tyrosine','EX_tyr_L(e)','','','','','','','','','','','','','','';'L-valine','EX_val_L(e)','','','','','','','','','','','','','','';'Mannitol','EX_mnl(e)','','','','','','','','','','','','','','';'Mannose','EX_man(e)','','','','','','','','','','','','','','';'Melibiose','EX_melib(e)','','','','','','','','','','','','','','';'Mucin','EX_T_antigen(e)','EX_Tn_antigen(e)','EX_core2(e)','EX_core3(e)','EX_core4(e)','EX_core5(e)','EX_core6(e)','EX_core7(e)','EX_core8(e)','EX_dsT_antigen(e)','EX_dsT_antigen(e)','EX_gncore1(e)','EX_gncore2(e)','EX_sT_antigen(e)','EX_sTn_antigen(e)';'N-acetylgalactosamine','EX_acgal(e)','','','','','','','','','','','','','','';'N-acetylglucosamine','EX_acgam(e)','','','','','','','','','','','','','','';'N-Acetylmannosamine','EX_acmana(e)','','','','','','','','','','','','','','';'N-acetylneuraminic acid','EX_acnam(e)','','','','','','','','','','','','','','';'Orotate','EX_orot(e)','','','','','','','','','','','','','','';'Oxalate','EX_oxa(e)','','','','','','','','','','','','','','';'Oxaloacetate','EX_oaa(e)','','','','','','','','','','','','','','';'Pectic galactan','EX_pecticgal(e)','','','','','','','','','','','','','','';'Pectin','EX_pect(e)','','','','','','','','','','','','','','';'Phenylacetate','EX_pac(e)','','','','','','','','','','','','','','';'Propionate','EX_ppa(e)','','','','','','','','','','','','','','';'Pullulan','EX_pullulan1200(e)','','','','','','','','','','','','','','';'Pyruvate','EX_pyr(e)','','','','','','','','','','','','','','';'Raffinose','EX_raffin(e)','','','','','','','','','','','','','','';'Resistant starch','EX_starch1200(e)','','','','','','','','','','','','','','';'Rhamnogalacturonan I','EX_rhamnogalurI(e)','','','','','','','','','','','','','','';'Rhamnogalacturonan II','EX_rhamnogalurII(e)','','','','','','','','','','','','','','';'Salicin','EX_salcn(e)','','','','','','','','','','','','','','';'Stachyose','EX_stys(e)','','','','','','','','','','','','','','';'Starch','EX_strch1(e)','','','','','','','','','','','','','','';'Stickland reaction','EX_pro_L(e)','EX_gly(e)','EX_ala_L(e)','EX_ile_L(e)','EX_leu_L(e)','EX_tyr_L(e)','EX_trp_L(e)','EX_val_L(e)','EX_glyb(e)','','','','','','';'Succinate','EX_succ(e)','','','','','','','','','','','','','','';'Sucrose','EX_sucr(e)','','','','','','','','','','','','','','';'Trehalose','EX_tre(e)','','','','','','','','','','','','','','';'Urea','EX_urea(e)','','','','','','','','','','','','','','';'Xylan','EX_xylan(e)','','','','','','','','','','','','','','';'Xylitol','EX_xylt(e)','','','','','','','','','','','','','','';'Xyloglucan','EX_xyluglc(e)','','','','','','','','','','','','','','';'Xylooligosaccharides','EX_xylottr(e)','','','','','','','','','','','','','',''};
secretionExchanges=cell2table(secretionExchanges);

% find microbe index in secretion table
mInd = find(ismember(secretionTable.MicrobeID, microbeID));
if isempty(mInd)
    warning(['Microbe "', microbeID, '" not found in secretion product data file.'])
    TruePositives = {};
    FalseNegatives = {};
else
    % perform FVA to identify uptake metabolites
    % set BOF
    if ~any(ismember(model.rxns, biomassReaction)) || nargin < 3
        error(['Biomass reaction "', biomassReaction, '" not found in model.'])
    end
    model = changeObjective(model, biomassReaction);
    % set a low lower bound for biomass
    model = changeRxnBounds(model, biomassReaction, 1e-3, 'l');
    % list exchange reactions
    exchanges = model.rxns(strncmp('EX_', model.rxns, 3));
    % open all exchanges
    model = changeRxnBounds(model, exchanges, -1000, 'l');
    model = changeRxnBounds(model, exchanges, 1000, 'u');
    
    rxns = secretionExchanges(table2array(secretionTable(mInd, 2:end)) == 1, 2:end);
    
    TruePositives = {};  % true positives (secretion in vitro and in silico)
    FalseNegatives = {};  % false negatives (secretion in vitro not in silico)
    
    % flux variability analysis on reactions of interest
    rxns = unique(table2cell(rxns));
    rxns = rxns(~cellfun('isempty', rxns));
    if ~isempty(rxns)
       rxnsInModel=intersect(rxns,model.rxns);
        if isempty(rxnsInModel)
            % all exchange reactions that should be there are not there -> false
            % negatives
            FalseNegatives = rxns;
            TruePositives= {};
        else
            if ~isempty(ver('distcomp')) && strcmp(solver,'ibm_cplex')
                [~, maxFlux, ~, ~] = fastFVA(model, 0, 'max', solver, ...
                    rxnsInModel, 'S');
            else
                FBA=optimizeCbModel(model,'max');
                if FBA.stat ~=1
                    warning('Model infeasible. Testing could nbot be performed.')
                    maxFlux=zeros(length(rxnsInModel),1);
                else
                    [~, maxFlux] = fluxVariability(model, 0, 'max', rxnsInModel);
                end
            end
            % active flux
            flux = rxnsInModel(maxFlux > 1e-6);
            % which secretions should be secreted according to in vitro data
            %     vData = secretionExchanges(table2array(secretionTable(mInd, 2:end)) == 1, 2);
            vData = find(table2array(secretionTable(mInd, 2:end)) == 1);
            % check all exchanges corresponding to each secretion
            % with multiple exchanges per secretion, at least one should be secreted
            % so if there is least one true positive per secretion false negatives
            % are not considered
            for i = 1:size(vData,1)
                tableData = table2array(secretionExchanges(vData(i), 2:end));
                allEx = tableData(~cellfun(@isempty, tableData));
                % let us also make sure de novo production is predicted by
                % preventing uptake of these secretions
                if ~isempty(allEx)
                    for j = 1:length(allEx)
                        model = changeRxnBounds(model, allEx{j}, 0, 'l');
                    end
                end
                if ~isempty(intersect(allEx, flux))
                    TruePositives = union(TruePositives, intersect(allEx, flux));
                else
                    FalseNegatives = union(FalseNegatives, setdiff(allEx, flux));
                end
            end
        end
    else
        TruePositives = {};
        FalseNegatives = {};
    end
end

% replace reaction IDs with metabolite names
if ~isempty(TruePositives)
    TruePositives = TruePositives(~cellfun(@isempty, TruePositives));
    TruePositives=strrep(TruePositives,'EX_','');
    TruePositives=strrep(TruePositives,'(e)','');
    
    for i=1:length(TruePositives)
        TruePositives{i}=metaboliteDatabase{find(strcmp(metaboliteDatabase(:,1),TruePositives{i})),2};
    end
end

% warn about false negatives
if ~isempty(FalseNegatives)
    FalseNegatives = FalseNegatives(~cellfun(@isempty, FalseNegatives));
    FalseNegatives=strrep(FalseNegatives,'EX_','');
    FalseNegatives=strrep(FalseNegatives,'(e)','');
    for i = 1:length(FalseNegatives)
        FalseNegatives{i}=metaboliteDatabase{find(strcmp(metaboliteDatabase(:,1),FalseNegatives{i})),2};
        warning(['Microbe "' microbeID, '" cannot secrete secretion product "', FalseNegatives{i}, '".'])
    end
end

end
