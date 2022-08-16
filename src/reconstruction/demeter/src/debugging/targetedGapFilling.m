function model = targetedGapFilling(model,osenseStr,database)
% This function gapfills a reconstruction during the DEMETER refinement
% suite to conform with experimental data and/or to enable growth.
% Metabolites are identified that would enable flux and reactions are
% gapfilled based on that.
%
% USAGE:
%
%   model = targetedGapFilling(model,osenseStr,database)
%
% INPUTS
% model:              COBRA model structure
% osenseStr:          Maximize ('max')/minimize ('min')linear part of the
%                     objective.
% database:           rBioNet reaction database containing min. 3 columns:
%                     Column 1: reaction abbreviation, Column 2: reaction
%                     name, Column 3: reaction formula.
%
% OUTPUT
% model:               Gapfilled COBRA model structure
%
% .. Authors:
%       - Almut Heinken, 2016-2020

tol = 0.00001;

%%
% define the gap-filling solutions for each metabolite that cannot be
% produced

gapfillSolutions={'Metabolite','Present','ToAdd'
    'adn[c]', '', {'ADPRDP','NADN'}
    'ins[c]', '', {'ADPRDP','NADN','INSH'}
    'ca2[c]', '', {'EX_ca2(e)','CA2abc'}
    'cobalt2[c]', '', {'EX_cobalt2(e)','Coabc'}
    'utp[c]', '', {'NDPK3','NDPK1','NDPK2','NDPK4','NDPK5','NDPK6','NDPK7','NDPK8','NDPK9','URIDK1','URIDK2'}
    'nad[c]', '', {'NADS1','NADS2','NNATr','EX_nac(e)','NACt2r'}
    'nac[c]', '', {'EX_nac(e)','NACt2r'}
    'ncam[c]', '', {'EX_ncam(e)','NCAMt2r'}
    'pydx5p[c]', '', {'EX_pydx(e)','PYDXabc','PYDXK'}
    'thmpp[c]', '', {'EX_thm(e)','THMabc','TMDPK'}
    'malcoa[c]', '', {'ACCOAC','H2CO3D'}
    'pi[c]', '', {'EX_pi(e)','PIabc','PIt6b'}
    'ac[c]', '', {'EX_ac(e)','ACtr'}
    'so4[c]', '', {'EX_so4(e)','SO4t2'}
    'h2[c]', '', {'EX_h2(e)','H2td'}
    'co2[c]', '', {'EX_co2(e)','CO2t'}
    'hco3[c]', '', {'EX_hco3(e)','HCO3abc','H2CO3D'}
    'h2[c]', '', {'EX_h2(e)','H2td'}
    'h2s[c]', '', {'EX_h2s(e)','H2St'}
    'arg_L[c]', '', {'EX_arg_L(e)','ARGt2r'}
    'cys_L[c]', '', {'EX_cys_L(e)','CYSt2r'}
    'pro_L[c]', '', {'EX_pro_L(e)','PROt2r'}
    'thr_L[c]', '', {'EX_thr_L(e)','THRt2r'}
    'asp_L[c]', '', {'EX_asp_L(e)','ASPt2r'}
    'asn_L[c]', 'EX_glyasn(e)', {'EX_asn_L(e)','ASNt2r'}
    'ala_D[c]', 'ALAR', {'EX_ala_L(e)','ALAt2r'}
    'ala_D[c]', '', {'EX_ala_D(e)','DALAt2r'}
    'phe_L[c]', '', {'EX_phe_L(e)','PHEt2r'}
    'tyr_L[c]', '', {'EX_tyr_L(e)','TYRt2r'}
    'trp_L[c]', '', {'EX_trp_L(e)','TRPt2r'}
    'glu_L[c]', '', {'EX_glu_L(e)','GLUt2r'}
    'gln_L[c]', '', {'EX_gln_L(e)','GLNt2r'}
    'met_L[c]', '', {'EX_met_L(e)','METt2r'}
    'ser_L[c]', '', {'EX_ser_L(e)','SERt2r'}
    'glu_D[c]', '', {'EX_glu_D(e)','GLU_Dt2r'}
    'glu_L[c]', 'GLUR', {'EX_glu_L(e)','GLUt2r'}
    'gly[c]', '', {'EX_gly(e)','GLYt2r'}
    'his_L[c]', '', {'EX_his_L(e)','HISt2r'}
    'ile_L[c]', '', {'EX_ile_L(e)','ILEt2r'}
    'leu_L[c]', 'EX_glyleu(e)', {'EX_leu_L(e)','LEUt2r'}
    'val_L[c]', '', {'EX_val_L(e)','VALt2r'}
    'pphn[c]', '', {'EX_phe_L(e)','PHEt2r','EX_tyr_L(e)','TYRt2r'}
    'pheme[c]', '', {'EX_pheme(e)','HEMEti'}
    'adocbl[c]', '', {'EX_adocbl(e)','ADOCBLabc','ADPRDP','NADN'}
    'sheme[c]', '', {'EX_sheme(e)','SHEMEabc'}
    'udpg[c]', '', {'GALUi','PGMT'}
    'spmd[c]', '', {'EX_spmd(e)','SPMDabc'}
    'atp[c]', '', {'ADK1','ADK2'}
    'adp[c]', '', {'ADK1','ADK2'}
    '5mthf[c]', '', {'METFR','FOLR3'}
    '10fthf[c]', '', {'FTHFL'}
    'q8[c]', '', {'EX_q8(e)','Q8abc'}
    '2dmmq8[c]', '', {'EX_2dmmq8(e)','2DMMQ8abc'}
    'mqn8[c]', '', {'EX_mqn8(e)','MK8t'}
    'ade[c]', '', {'EX_ade(e)','ADEt2r'}
    'fol[c]', '', {'EX_fol(e)','FOLabc'}
    'fru[c]', '', {'EX_fru(e)','FRUt2r'}
    'sucr[c]', '', {'EX_sucr(e)','SUCRt2'}
    'glc_D[c]', '', {'EX_glc_D(e)','GLCabc'}
    'glc_D[c]', 'HEX1', {'EX_glc_D(e)','GLCabc','PFK','FBA'}
    'pep[c]', 'HEX1', {'PGK','GAPD'}
    '4hba[c]', '', {'DM_4HBA'}
    'fum[c]', '', {'EX_fum(e)','FUMt2r'}
    'r5p[c]', '', {'TALA','TKT1','TKT2','RPI','RPE'}
    'amp[c]', '', {'ADPT'}
    'glyc3p[c]', '', {'GLYK'}
    'pppi[c]', '', {'PPA2'}
    'g1p[c]', '', {'PGMT'}
    'f6p[c]', '', {'FBP'}
    'acgam[c]', '', {'G1PACT','UAGDP'}
    'nmn[c]', '', {'EX_nmn(e)','NMNP'}
    'btn[c]', '', {'EX_btn(e)','BTNabc','BTNCLi','ACCOACL','ADPRDP','NADN'}
    '2obut[c]', '', {'DM_2obut[c]'}
    'g1p[c]', {'G16BPS','G1PP','G1PPT'}, {'G1PACT','UAGDP'}
    'gam[c]', '', {'GF6PTA'}
    'g1p[c]', {'G1PACT','UAGDP','HEX10','G6PDA'}, {'GF6PTA'}
    'g1p[c]', '', {'G16BPS','G1PPi','G1PPT','G1PACT','UAGDP'}
    'nadp[c]', 'EX_nadp(e)', {'NADK'}
    'no2[c]', 'NTRIR4', {'EX_no2(e)','NO2t2'}
    '4ppcys[c]', '', {'PNTK','EX_pnto_R(e)','PNTOabc','EX_cys_L(e)','CYSt2r'}
    'dtdp[c]', '', {'ADK10','DTMPK','NADK2','TMDK1','EX_thymd(e)','THMDt2'}
    'dtmp[c]', '', {'ADK10','DTMPK','NADK2','TMDK1','EX_thymd(e)','THMDt2'}
    'thymd[c]', '',{'EX_thymd(e)','THMDt2r'}
    'pnto_R[c]', '',{'DPCOAK','EX_pnto_R(e)','PNTK','PNTOabc','PPCDC','PPNCL','PTPAT'}
    'PGPm1[c]','',{'sink_PGPm1[c]'}
    'fad[c]','',{'FMNAT'}
    % assuming the most common cholate conversion reaction here-almost all
    % false negatives were E. coli which has this pathway
    'cholate[c]','',{'7AHSDH', '7AHSDHe', 'BIACt4', 'EX_7ocholate(e)'}
    'C02528[c]','',{'CDCA7aHSDHe', 'EX_7dhcdchol(e)'}
    };

% First find out which biomass precursors cannot be synthesized
% Needed if more than one compound is missing
[missingMets, presentMets] = biomassPrecursorCheck(model);

modelPrevious=model;

for i=2:size(gapfillSolutions,1)
    if ~isempty(find(ismember(missingMets,gapfillSolutions{i,1}))) || ~isempty(intersect(model.rxns,gapfillSolutions{i,2}))
        rxns=gapfillSolutions{i,3};
        for j=1:length(rxns)
            if isempty(find(ismember(model.rxns, rxns{j})))
                model = addReaction(model, [rxns{j},'_tGF'], database.reactions{find(ismember(database.reactions(:, 1), rxns{j})), 3});
            end
        end
    end
end

% If this did not solve the problem, predict which metabolites could 
% otherwise enable growth if either produced or consumed. This makes 
% targeted gap-filling possible.

growthEnablingMets = {};

FBA = optimizeCbModel(model,osenseStr);
if abs(FBA.f) < tol || FBA.stat==0
    
    model=modelPrevious;
    
    % try adding sink reactions
    sinks=gapfillSolutions(2:end,1);
    modelSink=addSinkReactions(model,sinks);
    FBA = optimizeCbModel(modelSink,osenseStr);
    if abs(FBA.f) > tol
        for i=1:size(sinks,1)
            rxnList{i}=['sink_' sinks{i,1}];
        end
        [grRatio, grRateKO, grRateWT, hasEffect, delRxn, fluxSolution] = singleRxnDeletion(modelSink, 'FBA', rxnList);
        growthEnablingMets=sinks(grRatio(:,1)<tol);
    end
    
    if ~isempty(find(ismember(growthEnablingMets,'gam6p[c]'))) && ~isempty(find(ismember(model.rxns,'HEX1')))
        % if HEX1 is already present, add with gene rule
        rxns={
            'HEX10'
            };
        for i=1:length(rxns)
            if isempty(find(ismember(model.rxns, rxns{i})))
                model = addReaction(model, [rxns{i} '_tGF'], ...
                    'reactionName', database.reactions{find(ismember(database.reactions(:, 1), rxns{i})), 2}, ...
                    'reactionFormula', database.reactions{find(ismember(database.reactions(:, 1), rxns{i})), 3}, ...
                    'subSystem', database.reactions{find(ismember(database.reactions(:, 1), rxns{i})), 11}, ...
                    'geneRule', model.grRules{find(strcmp(model.rxns,'HEX1'))}, ...
                    'printLevel', 0);
            end
        end
    end
    
    for i=2:size(gapfillSolutions,1)
        if ~isempty(find(ismember(growthEnablingMets,gapfillSolutions{i,1}))) || ~isempty(intersect(model.rxns,gapfillSolutions{i,2}))
            rxns=gapfillSolutions{i,3};
            for j=1:length(rxns)
                if isempty(find(ismember(model.rxns, rxns{j})))
                    model = addReaction(model, [rxns{j} '_tGF'], database.reactions{find(ismember(database.reactions(:, 1), rxns{j})), 3});
                end
            end
        end
    end
end

end