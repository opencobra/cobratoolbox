function [TruePositives, FalseNegatives] = testBiomassPrecursorBiosynthesis(model, microbeID)
% Tests biomass precursor biosynthesis in the model based and compares against comparative genomics data.
%
% INPUT
% model             COBRA model structure
% microbeID         Microbe ID in carbon source data file
%
% OUTPUT
% TruePositives     Cell array of strings listing all biomass precursors that can
%                   be synthesized de novo in vitro and in silico.
% FalseNegatives    Cell array of strings listing all biomass precursors that can
%                   be synthesized de novo in vitro but not in silico.
%
% Stefania Magnusdottir, Nov 2017

% List the biomass precursor (col1), metabolite whose biosynthesis is tested (col2),
% and the exchange reactions that are blocked for testing (col3)
precursors = {
    'Alanine',{'ala_L[c]'},{'EX_ala_L(e)'}
'Arginine',{'arg_L[c]'},{'EX_arg_L(e)'}
'Asparagine',{'asn_L[c]'},{'EX_asn_L(e)'}
'Aspartate',{'asp_L[c]'},{'EX_asp_L(e)'}
'Cysteine',{'cys_L[c]'},{'EX_cys_L(e)'}
'Glutamate',{'glu_L[c]'},{'EX_glu_L(e)'}
'Glutamine',{'gln_L[c]'},{'EX_gln_L(e)'}
'Glycine',{'gly[c]'},{'EX_gly(e)'}
'Histidine',{'his_L[c]'},{'EX_his_L(e)'}
'Isoleucine',{'ile_L[c]'},{'EX_ile_L(e)'}
'Leucine',{'leu_L[c]'},{'EX_leu_L(e)'}
'Lysine',{'lys_L[c]'},{'EX_lys_L(e)'}
'Methionine',{'met_L[c]'},{'EX_met_L(e)'}
'Phenylalanine',{'phe_L[c]'},{'EX_phe_L(e)'}
'Proline',{'pro_L[c]'},{'EX_pro_L(e)'}
'Serine',{'ser_L[c]'},{'EX_ser_L(e)'}
'Threonine',{'thr_L[c]'},{'EX_thr_L(e)'}
'Tryptophan',{'trp_L[c]'},{'EX_trp_L(e)'}
'Tyrosine',{'tyr_L[c]'},{'EX_tyr_L(e)'}
'Valine',{'val_L[c]'},{'EX_val_L(e)'}
'Biotin',{'btn[c]'},{'EX_btn(e)','EX_pime(e)'}
'Cobalamin',{'cbl1[c]','adocbl[c]'},{'EX_adocbl(e)','EX_cbl1(e)','EX_cbl2(e)'}
'Folate',{'fol[c]','thf[c]'},{'EX_fol(e)','EX_thf(e)'}
'Niacin',{'nac[c]','ncam[c]'},{'EX_nac(e)','EX_ncam(e)'}
'Pantothenate',{'pnto_R[c]'},{'EX_pnto_R(e)'}
'Pyridoxin',{'pydx[c]','pydxn[c]','pydam[c]'},{'EX_pydx5p(e)','EX_pydx(e)','EX_pydxn(e)','EX_pydam(e)'}
'Riboflavin',{'ribflv[c]'},{'EX_ribflv(e)','EX_rbflvrd(e)'}
'Thiamin',{'thmmp[c]'},{'EX_thm(e)','EX_thmmp(e)'}
'Adenine',{'ade[c]'},{'EX_ade(e)','EX_adn(e)','EX_dad_2(e)'}
'Cytosine',{'csn[c]'},{'EX_csn(e)','EX_cytd(e)','EX_dcyt(e)'}
'Guanine',{'gua[c]'},{'EX_gua(e)','EX_gsn(e)','EX_dgsn(e)'}
'Thymine',{'thym[c]'},{'EX_thym(e)','EX_thymd(e)'}
'Uracil',{'ura[c]'},{'EX_ura(e)','EX_uri(e)','EX_duri(e)'}
'Menaquinone',{'mqn8[c]'},{'EX_mqn7(e)','EX_mqn8(e)'}
'Ubiquinone',{'q8[c]'},{'EX_q8(e)'}
};

% load vitamin biosynthesis data table
bprecursorTable = readtable('BiosynthesisPrecursorTable.txt','Delimiter','\t');

% find precursors that should be synthesized de novo
mInd = find(ismember(bprecursorTable.MicrobeID, microbeID));
if isempty(mInd)
    warning(['Microbe " ' microbeID, '" not found in biomass precursor biosynthesis data file.'])
    TruePositives = {};
    FalseNegatives = {};
else
    % which B-precursors should be synthesized
    bpData = find(table2array(bprecursorTable(mInd, 2:end)) == 1);

    TruePositives = {};
    FalseNegatives = {};
    if ~isempty(bpData)
        exchanges = model.rxns(strncmp('EX_', model.rxns, 3));

        % open all exchanges
        model = changeRxnBounds(model, exchanges, -1000, 'l');
        model = changeRxnBounds(model, exchanges, 1000, 'u');
        
        % test biomass precursor biosynthesis
        for i = 1:length(bpData)
            modelT = changeRxnBounds(model, precursors{bpData(i), 3}, 0, 'l');  % block uptake
            for j=1:length(precursors{bpData(i), 2})
                modelT = addDemandReaction(modelT, precursors{bpData(i), 2}{j});
                modelT = changeObjective(modelT, ['DM_' precursors{bpData(i), 2}{j}]);
                
                % simulate biosynthesis
                sol = optimizeCbModel(modelT, 'max');
                sols(j)=sol.obj;
            end
            if any(sols) > 1e-6
                TruePositives = union(TruePositives, precursors{bpData(i)});
            else
                FalseNegatives = union(FalseNegatives, precursors{bpData(i)});
            end
        end
    end
end
