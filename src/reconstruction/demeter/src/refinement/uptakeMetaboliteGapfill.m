function [model,uptakeRxnsAdded] = uptakeMetaboliteGapfill(model,microbeID, database, inputDataFolder)
% This function adds exchange, transport and biosynthesis reactions for 
% experimentally shown consumed metabolites according to data collected for
% the DEMETER pipeline.
%
% USAGE:
%
%   [model,uptakeRxnsAdded] = uptakeMetaboliteGapfill(model,microbeID, database, inputDataFolder)
%
% INPUTS
% model:             COBRA model structure
% microbeID:         ID of the reconstructed microbe that serves as the
%                    reconstruction name and to identify it in input tables
% database:          rBioNet reaction database containing min. 3 columns:
%                    Column 1: reaction abbreviation, Column 2: reaction
%                    name, Column 3: reaction formula.
% inputDataFolder:   Folder with input tables with experimental data
%                    and databases that inform the refinement process
%
% OUTPUTS
% model:             COBRA model structure with added pathways if applies
% uptakeRxnsAdded:   Reactions added based on experimental data
%
% .. Author:
%       - Almut Heinken, 2019-2020

% structure of lists of reactions to add per uptake metabolite
% non-alphanumeric characters are removed from uptake metabolite names in
% the structure; the script accounts for this when matching with the
% experimental data input

uptakeRxns = struct();
uptakeRxns.Ammonia = {'EX_nh4(e)', 'NH4tb'};
uptakeRxns.Hydrogen = {'EX_h2(e)', 'H2td'};
uptakeRxns.Isethionate = {'EX_isetac(e)', 'ISETACabc'};
uptakeRxns.Menaquinone = {'EX_mqn7(e)', 'MK7te', 'EX_mqn8(e)', 'MK8t','DM_mql7(c)','DM_mql8(c)'};
uptakeRxns.Methanol = {'EX_meoh(e)', 'MEOHt2','PRDX','ALDD1'};
uptakeRxns.Methylamine = {'EX_mma(e)', 'MMAt2e'};
uptakeRxns.Niacin = {'EX_nac(e)', 'EX_ncam(e)','NACt2r','NCAMt2r'};
uptakeRxns.NitrogenN2 = {'EX_n2(e)', 'N2t'};
uptakeRxns.Nitrite = {'NO2OR', 'ATPS4', 'EX_no2(e)', 'EX_no3(e)'};
uptakeRxns.Nitrate = {'EX_no3(e)', 'NO3abc', 'NO3R1', 'NO3R2', 'EX_no2(e)', 'NO2t2r'};
uptakeRxns.Pantothenate = {'EX_pnto_R(e)', 'PNTOabc'};
uptakeRxns.Phenol = {'EX_phenol(e)', 'PHENOLt2r'};
uptakeRxns.x_2methylbutyrate = {'EX_2mbut(e)', '2MBUTt2r'};
uptakeRxns.x_12propanediol = {'EX_12ppd_S(e)', '12PPDt'};
uptakeRxns.Cobalamin = {'EX_cbl1(e)', 'CBL1abc', 'EX_adocbl(e)', 'ADOCBLabc'};
uptakeRxns.Linoleicacid = {'EX_lnlc(e)', 'LNLCt'};
uptakeRxns.alphaLinolenicacid = {'EX_lnlnca(e)', 'LNLNCAt'};
uptakeRxns.Benzoate = {'EX_bz(e)', 'BZt'};
uptakeRxns.Betaine = {'EX_glyb(e)', 'GLYBt2r', 'DM_glyb_c_'};
uptakeRxns.Bicarbonate = {'EX_hco3(e)', 'HCO3abc'};
uptakeRxns.Biotin = {'EX_btn(e)', 'BTNabc', 'DM_btn'};
uptakeRxns.Chenodeoxycholate = {'EX_C02528(e)', 'BIACt2'};
uptakeRxns.Cholate = {'EX_cholate(e)', 'BIACt1'};
uptakeRxns.Dimethylamine = {'EX_dma(e)', 'DMAt2r'};
uptakeRxns.Folate = {'EX_fol(e)', 'FOLabc'};
uptakeRxns.Formate = {'EX_for(e)','FORt'};
uptakeRxns.Glycochenodeoxycholate = {'EX_dgchol(e)', 'GCDCHOLBHSe', 'EX_C02528(e)', 'EX_gly(e)'};
uptakeRxns.Pyridoxal = {'EX_pydx(e)', 'PYDXabc', 'EX_pydxn(e)', 'PYDXNabc', 'EX_pydam(e)', 'PYDAMabc', 'PYDXK'};
uptakeRxns.Propanol = {'EX_ppoh(e)', 'PPOHt2r'};
uptakeRxns.Uridine = {'EX_uri(e)', 'URIt2'};
uptakeRxns.Urea = {'EX_urea(e)', 'UREAt', 'UREA'};
uptakeRxns.Riboflavin = {'EX_ribflv(e)', 'RIBFLVt2r'};
uptakeRxns.Shikimate = {'EX_skm(e)', 'SKMt2'};
uptakeRxns.Spermidine = {'EX_spmd(e)', 'SPMDtex2'};
uptakeRxns.Sulfate = {'EX_so4(e)', 'SO4t2'};
uptakeRxns.Valerate = {'EX_M03134(e)', 'M03134t2r'};
uptakeRxns.Tryptamine = {'EX_trypta(e)', 'TRYPTAte'};
uptakeRxns.Tyramine = {'EX_tym(e)', 'TYMt2r'};
uptakeRxns.Trimethylamine = {'EX_tma(e)', 'TMAt2r'};
uptakeRxns.Taurine = {'EX_taur(e)', 'TAURabc'};
uptakeRxns.Taurochenodeoxycholate = {'EX_tdchola(e)', 'TCDCHOLBHSe', 'EX_C02528(e)', 'EX_taur(e)'};
uptakeRxns.Taurocholate = {'EX_tchola(e)', 'TCHOLBHSe', 'EX_cholate(e)', 'EX_taur(e)'};
uptakeRxns.Thiamine = {'EX_thm(e)', 'THMabc'};
uptakeRxns.Thymidine = {'EX_thymd(e)', 'THMDt2r'};
uptakeRxns.Thiosulfate = {'EX_tsul(e)', 'TSULabc'};
uptakeRxns.Glycocholate = {'EX_gchola(e)', 'GCHOLBHSe', 'EX_cholate(e)', 'EX_gly(e)'};
uptakeRxns.x_4Aminobenzoate = {'EX_4abz(e)', '4ABZt2'};
uptakeRxns.x_4Aminobutyrate = {'EX_4abut(e)', 'ABUTt2r'};
uptakeRxns.x_23Butanediol = {'EX_btd_RR(e)', 'BTDt1_RR'};
uptakeRxns.Glycodeoxycholate = {'EX_M01989(e)', 'GDCABSHe', 'EX_dchac(e)', 'EX_gly(e)'};
uptakeRxns.Glycolithocholate = {'EX_HC02193(e)', 'GLCABSHe', 'EX_HC02191(e)', 'EX_gly(e)'};
uptakeRxns.Taurodeoxycholate = {'EX_tdechola(e)', 'TDCABSHe', 'EX_dchac(e)', 'EX_taur(e)'};
uptakeRxns.Taurolithocholate = {'EX_HC02192(e)', 'TLCABSHe', 'EX_HC02191(e)', 'EX_taur(e)'};
uptakeRxns.x_12Ethanediol = {'EX_12ethd(e)','12ETHDt','LCAR2'};
uptakeRxns.Lalanine = {'EX_ala_L(e)','ALAt2r'};
uptakeRxns.Larginine = {'EX_arg_L(e)','ARGt2r'};
uptakeRxns.Lasparagine = {'EX_asn_L(e)','ASNt2r'};
uptakeRxns.Laspartate = {'EX_asp_L(e)','ASPt2r'};
uptakeRxns.Lcysteine = {'EX_cys_L(e)','CYSt2r'};
uptakeRxns.Lglutamate = {'EX_glu_L(e)','GLUt2r'};
uptakeRxns.Lglutamine = {'EX_gln_L(e)','GLNt2r'};
uptakeRxns.Glycine = {'EX_gly(e)','GLYt2r'};
uptakeRxns.Lhistidine = {'EX_his_L(e)','HISt2r'};
uptakeRxns.Lisoleucine = {'EX_ile_L(e)','ILEt2r'};
uptakeRxns.Lleucine = {'EX_leu_L(e)','LEUt2r'};
uptakeRxns.Llysine = {'EX_lys_L(e)','LYSt2r'};
uptakeRxns.Lisoleucine = {'EX_ile_L(e)','ILEt2r'};
uptakeRxns.Lmethionine = {'EX_met_L(e)','METt2r'};
uptakeRxns.Lphenylalanine = {'EX_phe_L(e)','PHEt2r'};
uptakeRxns.Lproline = {'EX_pro_L(e)','PROt2r'};
uptakeRxns.Lserine = {'EX_ser_L(e)','SERt2r'};
uptakeRxns.Lthreonine = {'EX_thr_L(e)','THRt2r'};
uptakeRxns.Ltryptophan = {'EX_trp_L(e)','TRPt2r'};
uptakeRxns.Ltyrosine = {'EX_tyr_L(e)','TYRt2r'};
uptakeRxns.Lvaline = {'EX_val_L(e)','VALt2r'};

uptakeTable = readInputTableForPipeline([inputDataFolder filesep 'uptakeTable.txt']);
uptakeTable(:,find(strncmp(uptakeTable(1,:),'Ref',3)))=[];

% uptake metabolite list from input table
% modify names to agree with structure
% can only contain alphabetic, numeric, or underscore characters and cannot
% start with a number or underscore.
% Any non-alphabetic, numeric, or underscore characters removed. Any names
% starting with a number changed to x_number.
uptMets = uptakeTable(1, 2:end);
numStart = find(~cellfun(@isempty, regexp(uptMets, '^\d+')));% find names that start with numbers
uptMets(numStart) = strcat('x_', uptMets(numStart));
uptMets = regexprep(uptMets, '\W', '');% remove special characters

% microbe index in file
orgRow = find(strcmp(microbeID, uptakeTable(:, 1)));

% find the secretion products for this microbe
if contains(version,'(R202') % for Matlab R2020a and newer
    uptCols = find(cell2mat(uptakeTable(orgRow, 2:end)) == 1);
else
    uptCols = find(str2double(uptakeTable(orgRow, 2:end)) == 1);
end

gapfillAddConditional = {
    'Methylamine', 'any(ismember(model.rxns, ''MOGMAH''))', {'DM_nmth2ogltmt_c_'}
    'Benzoate', 'find(ismember(model.rxns, {''BZ12DOX'', ''BZDIOLDH'', ''CATDOX'', ''MUCCYCI''}))', {'EX_mucl(e)','MUCLt2r'}
    };

% added rxns list
uptakeRxnsAdded = {};

if ~isempty(uptCols)
    takenUp = uptMets(uptCols);
    for i = 1:length(takenUp)
        % add rxns that are not already in model
        rxns2Add = setdiff(uptakeRxns.(takenUp{i}), model.rxns);
        if ~isempty(rxns2Add)
            for j = 1:length(rxns2Add)
                RxnForm = database.reactions(find(ismember(database.reactions(:, 1), rxns2Add{j})), 3);
                model = addReaction(model, rxns2Add{j}, 'reactionFormula', RxnForm{1, 1}, 'geneRule','uptakeMetaboliteGapfill');
            end
            uptakeRxnsAdded = union(uptakeRxnsAdded, rxns2Add);
        end
        % add conditional reactions
        if any(ismember(gapfillAddConditional(:, 1), takenUp{i}))
            conditions = find(ismember(gapfillAddConditional(:, 1), takenUp{i}));
            for k = 1:length(conditions)
                if eval(gapfillAddConditional{conditions(k), 2})
                    addRxns = gapfillAddConditional{conditions(k), 3};
                    addRxns = setdiff(addRxns,model.rxns);
                    for j = 1:length(addRxns)
                        formula = database.reactions{ismember(database.reactions(:, 1), addRxns{j}), 3};
                        model = addReaction(model, addRxns{j}, 'reactionFormula', formula, 'geneRule', 'uptakeMetaboliteGapfill');
                        uptakeRxnsAdded = union(uptakeRxnsAdded,addRxns{j});
                    end
                end
            end
        end
    end
end

end
