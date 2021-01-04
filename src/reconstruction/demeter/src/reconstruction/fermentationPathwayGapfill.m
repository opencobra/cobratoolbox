function [model, addedRxns, removedRxns] = fermentationPathwayGapfill(model, microbeID, database, inputDataFolder)
% Gap-fills fermentation pathways in a microbial reconstruction based on
% experimental evidence.
%
% USAGE
%       [model, addedRxns, removedRxns] = fermentationPathwayGapfill(model, microbeID, database, inputDataFolder)
%
% INPUT
% model             COBRA model structure
% microbeID         Microbe ID corresponding to that in Column 1 in
%                   fermDataTable
% fermDataTable     Data table with binary data showing which microbe
%                   should have what fermentation pathway(s).
%                   Column 1: Cell array of strings with microbeIDs.
%                   Columns 2-29: Cell array of numbers either 0 (microbe
%                   does not have pathway) or 1 (has pathway).
% database          rBioNet reaction database containing min. 3 columns:
%                   Column 1: reaction abbreviation, Column 2: reaction
%                   name, Column 3: reaction formula.
%
% OUTPUT
% model             COBRA model structure
% addedRxns         List of reactions that were added during refinement
% removedRxns       List of reactions that were removed during refinement
% 
%
% Almut Heinken and Stefania Magnusdottir, 2016-2020

addedRxns = {};
removedRxns = {};

% read in the fermentation pathway data
fermDataTable = readtable([inputDataFolder filesep 'FermentationTable.txt'], 'Delimiter', '\t', 'ReadVariableNames', false);
for i=1:11
    if ismember(['Ref' num2str(i)],fermDataTable.Properties.VariableNames)
fermDataTable.(['Ref' num2str(i)])=[];
    end
end
fermDataTable = table2cell(fermDataTable);

mInd = find(ismember(fermDataTable(:, 1), microbeID));
if isempty(mInd)
    warning(['Microbe ID not found in fermentation data table: ', microbeID])
end

fpathways = fermDataTable(1,find(strcmp(fermDataTable(mInd, 1:end),'1')));
if isempty(fpathways)
    warning(['No fermentation pathways found for ', microbeID])
end

tol = 1e-8;

% pathway, rxns to add
fpathwayGapfillAdd = {
    'Acetate kinase (acetate producer or consumer)', {'EX_ac(e)', 'ACtr', ...
                                                      'ACKr', 'PTAr'}
    'Bifid shunt', {'EX_ac(e)', 'ACtr', 'ACKr', 'F6PE4PL', 'TALA', 'TKT1', ...
                    'TKT2', 'RPI', 'RPE', 'PKL', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK', 'HEX1'}
    'Acetogen pathway', {'EX_ac(e)', 'ACtr', 'EX_h2(e)', 'H2td', 'EX_for(e)', ...
                         'FORt', 'FDHfdx', 'MTHFRfdx', 'FTHFL', 'MTHFC', 'METR', 'CODH_ACS', ...
                         'HYDFDNrfdx', 'HYDFDN2rfdx', 'PTAr', 'ACKr'}
    'Formate producer', {'EX_for(e)', 'FORt', 'PFL'}
    'D-lactate producer or consumer', {'EX_lac_D(e)', 'D_LACt2ei', 'LDH_D', 'PYK'}
    'L-lactate producer or consumer', {'EX_lac_L(e)', 'L_LACt2ei', 'LDH_L', 'PYK'}
    'Ethanol producer or consumer', {'EX_etoh(e)', 'ETOHt2r', 'ALCD2x', 'ACALD', ...
                                     'ACALDt', 'EX_acald(e)', 'PYK'}
    'Succinate producer', {'EX_succ(e)', 'SUCCt2r', 'FRD2', 'FRD3', 'FRD7', ...
                           'SUCD1', 'SUCD4', 'SUCDi', 'FUM', 'MDH', 'PPCKr'}
    'Propionate from succinate', {'EX_succ(e)', 'SUCCt2r', 'SUCOAS', 'MMM2r' ...
                                  'MME', 'MMCD', 'PTA2', 'PPAKr', 'PPAt2r', 'EX_ppa(e)'}
    'Propionate from propane-1,2-diol', {'EX_12ppd_S(e)', '12PPDt', '12PPDSDH', ...
                                         'MMSAD2', 'PTA2', 'PPAKr', 'PPAt2r', 'EX_ppa(e)'}
    'Propionate from lactate (acrylate pathway)', {'PPCOA_FDX_OX', 'LACCOAD', ...
                                                   'LACCOAT', 'PPAt2r', 'EX_ppa(e)'}
    'Propionate from threonine', {'EX_thr_L(e)', 'THRt2r', 'THRD_L', 'OBTFL', ...
                                  'PTA2', 'PPAKr', 'PPAt2r', 'EX_ppa(e)', 'FORt', 'EX_for(e)'}
    'Wood-Werkman cycle', {'EX_succ(e)', 'SUCCt2r', 'SUCOAS', 'MMM2r' ...
                                  'MME', 'MMCD', 'PTA2', 'PPAKr', 'PPAt2r', 'EX_ppa(e)', 'EX_lac_L(e)', 'LDH_L2', 'MDH', 'PYRCT','EX_succ(e)', 'SUCCt2r', 'FRD2', 'FRD3', 'FRD7', ...
                           'SUCD1', 'SUCD4', 'SUCDi', 'FUM', 'MDH', 'PPCKr'}
    'Butyrate via butyryl-CoA: acetate CoA transferase', {'ACACT1r', 'HACD1', ...
                                                          'ECOAH1', 'ECOAH1R', '3HBCOAE', 'BTCOADH', 'FDNADOX_H', 'BTCOAACCOAT', ...
                                                          'BUTt2r', 'EX_but(e)'}
    'Butyrate via butyrate kinase', {'ACACT1r', 'HACD1', 'ECOAH1', 'ECOAH1R', ...
                                     '3HBCOAE', 'BTCOADH', 'FDNADOX_H', 'BUTKr', 'PBUTT', 'BUTt2r', 'EX_but(e)'}
    'Butyrate from lysine via butyrate-acetoacetate CoA-transferase', ...
    {'EX_lys_L(e)', 'LYSt2r', 'LYSAM', '36DAHXI', '35DACAPDH', '5A3OHEXCLE', ...
     '3ABUTCOAL', 'BTCOADH', 'FDNADOX_H', 'ACACT1r', 'BCOAACT',  'BUTt2r', 'EX_but(e)'}
    'Butyrate from glutarate or glutamate', {'EX_glu_L(e)', 'GLUt4r', 'EX_glutar(e)', ...
                                             'GLUTARt2r', 'EX_na1(e)', 'GLUDxi', '2HYDOGDH', '2HYDOGCOAT', 'GLUTARCOAT', ...
                                             '2HYDOGCOAD', 'GLUTACCOADC', 'GLUTCOADH', 'ACOAD1', 'BTCOAACCOAT', ...
                                             'BUTt2r', 'EX_but(e)', 'SUCD1', 'SUCD4'}
    'Butyrate from 4-hydroxybutyrate or succinate', {'EX_succ(e)', 'SUCCt2r', ...
                                                     'EX_4abut(e)', 'ABUTt2r', 'ABTAr', 'SSALxr', 'SSALyr', '4HBNOX', 'ACCOAT', ...
                                                     '3HBCD', '3BTCOAI', 'BUTt2r', 'EX_but(e)'}
    'Hydrogen from ferredoxin oxidoreductase', {'HYD4', 'H2td', 'EX_h2(e)'}
    'Hydrogen from formate hydrogen lyase', {'FHL', 'H2td', 'EX_h2(e)','EX_for(e)', 'FORt'}
    'Methanogenesis', {'EX_h2(e)', 'H2td', 'EX_for(e)', 'FORt', 'EX_ac(e)', ...
                       'ACtr', 'EX_nh4(e)', 'NH4tb', 'EX_etoh(e)', 'ETOHt2r', 'EX_acald(e)', ...
                       'ACALDt', 'EX_meoh(e)', 'MEOHt2', 'EX_ch4(e)', 'CH4t', 'EX_hco3(e)', ...
                       'HCO3abc', 'H2CO3D', 'ALCD2y', 'PC', 'MDH', 'FUM', 'SUCD1', 'SUCD4', ...
                       'SUCOAS', 'AKGS', 'GLUDxi', 'GLUDy', 'GLNS', 'GLUSx', 'GLUSy', 'POR4', ...
                       'PPS', 'ACS', 'ALCD2y', 'FDH', 'MCOMR', 'MH4MPTMT', 'COBCOMOX', ...
                       'MCOX', 'MCOX2', 'MTTH4MPTH', 'FMFUROr', 'MPHZEH', 'COF420_NADP_OX', ...
                       'MCMMT', 'COF420H', 'ATPS4'}
    'Sulfate reducer', { 'EX_tsul(e)', 'TSULt2', 'EX_h2s(e)', 'H2St', 'SO3R'}
    'Isobutyrate producer', {'EX_val_L(e)', 'VALt2r', 'VALO', 'ISOBUTt2r', ...
                             'EX_isobut(e)'}
    'Isovalerate producer', {'EX_leu_L(e)', 'LEUt2r', 'LEUO', 'ISOCAPRt2r', ...
                             'EX_isocapr(e)', 'ISOVALt2r', 'EX_isoval(e)'}
    'Acetoin producer', {'EX_actn_R(e)', 'ACTNdiff', 'ACTNDH', 'ACALD'}
    '2,3-butanediol producer', {'EX_btd_RR(e)', 'BTDt1_RR', 'BTDD_RR'}
    'Indole producer', {'EX_trp_L(e)', 'TRPt2r', 'TRPAS2', 'INDOLEt2r', 'EX_indole(e)'}
    'Phenylacetate producer', {'EX_phe_L(e)', 'PHEt2r', 'PACCOALr', 'PACCOAL2r', ...
                               'IOR2', 'IOR3', 'PHETA1', 'PACt2r', 'EX_pac(e)'}
    'Butanol producer', {'ALCD4', 'BTALDH', 'BTOHt2r', 'EX_btoh(e)'}
    'Valerate producer', {'5APTNt2r','EX_5aptn(e)','APTNAT','5HVALDH', '5HVALCOAT', '5HVALCOADH', '5H2PENTCOAD', '24PENTDCOAR', '3PENTI', '24PENTDCOAR2', 'VALCOADH', '3HISOVALCOAG', '3HISOVALCOAC', 'VALCOAACCOAT', 'M03134t2r', 'EX_M03134(e)'}
};

fpathwayGapfillRemove = {
    'Butyrate via butyryl-CoA: acetate CoA transferase', {'BUTCTr'}
    'Butyrate via butyrate kinase', {'BUTK'}
    'Butyrate from glutarate or glutamate', {'BUTCTr'}
    'Butyrate from 4-hydroxybutyrate or succinate', {'ABTA'}
    'Wood-Werkman cycle', {'LDH_L'}
    'Methanogenesis', {'FMFURO'}
    'Phenylacetate producer', {'PACCOAL'}
};

fpathwayAddConditional = {
    % fermentation products, condition, add reaction(s)
    % Some reconstructions need to take up acetate to produce biomass -
    % gap-filled to fix this based on related strains
    'Acetate kinase (acetate producer or consumer)','EX_ac(e)', 'any(ismember(model.rxns, ''FDOXR'')) && any(ismember(model.rxns, ''POR4'')) && ~any(ismember(model.rxns, ''FDNADOX_H''))', {'EX_no2(e)', 'NO2t2'}
    'Acetate kinase (acetate producer or consumer)','EX_ac(e)', 'any(ismember(model.rxns, ''AGPAT180'')) && any(ismember(model.rxns, ''PPIACPT'')) && any(ismember(model.rxns, ''FAO181O''))', {'EX_ocdca(e)','OCDCAtr','FA180ACPHrev'}
    'Acetate kinase (acetate producer or consumer)','EX_ac(e)', 'any(ismember(model.rxns, ''N2OFO'')) && any(ismember(model.rxns, ''OOR2r'')) && any(ismember(model.rxns, ''POR4''))', {'NIT_n1p4'}
    'Acetate kinase (acetate producer or consumer)','EX_ac(e)', 'length(findRxnsFromMets(model,''fdxrd[c]''))<2 && any(ismember(model.rxns, ''POR4''))', {'FRDO'}
    'Acetate kinase (acetate producer or consumer)','EX_ac(e)', '~any(ismember(model.rxns, ''ACS''))', {'ACS'}
    'Acetate kinase (acetate producer or consumer)','EX_ac(e)', 'any(ismember(model.rxns, ''ACONTa''))', {'ICDHx','ICDHyr'}
    'Acetate kinase (acetate producer or consumer)','EX_ac(e)', 'any(ismember(model.rxns, ''MDH'')) && any(ismember(model.rxns, ''POR4'')) && any(ismember(model.rxns, ''FUM''))', {'ACONTa','ACONTb','ICDHx','ICDHyr','OAASr'}
    'Succinate producer','EX_succ(e)', '~any(ismember(model.rxns, ''PPA''))', {'PPA','PPA2'}
    'Sulfate producer','EX_h2s(e)', 'any(strncmp(microbeID, ''Desulfo'',7))', {'EX_so4(e)', 'SO4t2','SADT','AMPSO3OX','EX_so3(e)','SO3t','POR4','FDHr','HYD2','FDNADOX_H','FDX_NAD_NADP_OXi','SO3rDmq'}
    };


% go through fermentation pathways
for i = 1:length(fpathways)
    fprintf('Refining pathway "%s" for %s.\n', fpathways{i}, microbeID)

    % start by removing reactions if needed
    if any(ismember(fpathwayGapfillRemove(:, 1), fpathways{i}))
        remRxns = fpathwayGapfillRemove{find(ismember(fpathwayGapfillRemove(:, 1), fpathways{i})), 2};
        model = removeRxns(model, remRxns);
        removedRxns{length(removedRxns)+1,1} = remRxns;
    end

    % add pathway reactions
    addRxns = fpathwayGapfillAdd{find(ismember(fpathwayGapfillAdd(:, 1), fpathways{i})), 2};
    for j = 1:length(addRxns)
        if ~any(ismember(model.rxns, addRxns{j}))
            formula = database.reactions{ismember(database.reactions(:, 1), addRxns{j}), 3};
            model = addReaction(model, addRxns{j}, 'reactionFormula', formula, 'geneRule', 'FermentationGapfill');
            addedRxns{length(addedRxns)+1,1} = addRxns{j};
        end
    end
end

% add conditional reactions-only if necessary
for i=1:size(fpathwayAddConditional,1)
    if any(ismember(fpathways,fpathwayAddConditional{i,1}))
        modelTest=changeRxnBounds(model,fpathwayAddConditional{i,2},0.1,'l');
        FBA=optimizeCbModel(modelTest,'max');
        if FBA.f < tol || strcmp(FBA.origStat,'INFEASIBLE')
            if eval(fpathwayAddConditional{i, 3})
                addRxns = fpathwayAddConditional{i, 4};
                for j = 1:length(addRxns)
                    if ~any(ismember(model.rxns, addRxns{j}))
                        formula = database.reactions{ismember(database.reactions(:, 1), addRxns{j}), 3};
                        model = addReaction(model, addRxns{j}, 'reactionFormula', formula, 'geneRule', 'FermentationGapfill');
                        addedRxns{length(addedRxns)+1,1} = addRxns{j};
                    end
                end
            end
        end
    end
end

% The following reactions are always added given the corresponding
% conditions:

condRxns={
%     {'ACKr','PTAr'},{'EX_ac(e)','ACtr'}
%     {'LDH_D'},{'EX_lac_D(e)','D_LACt2'}
%     {'ACALD','ALCD2x'},{'EX_etoh(e)','ETOHt2r','EX_acald(e)','ACALDt'}
%     {'ACALD','ALCD2y'},{'EX_etoh(e)','ETOHt2r','EX_acald(e)','ACALDt'}
%     {'SUCD1'},{'EX_succ(e)','SUCCt2r'}
%     {'FRD2'},{'EX_succ(e)','SUCCt2r'}
    {'TRPAS2'},{'EX_indole(e)','INDOLEt2r'}
    {'ACTD'},{'EX_diact(e)','DACTt3'}
    };
for i=size(condRxns,1)
    if length(intersect(model.rxns, condRxns{i,1})) == length(condRxns{i,1})
        for j=1:length(condRxns{i,2})
        formula = database.reactions{ismember(database.reactions(:, 1), condRxns{i,2}{j}), 3};
        model = addReaction(model, condRxns{i,2}{j}, 'reactionFormula', formula, 'geneRule', 'FermentationGapfill');
        addedRxns{length(addedRxns)+1,1} = condRxns{i,2}{j};
        end
    end
end

end
