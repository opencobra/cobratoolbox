function [model,rxnsAdded]=putrefactionPathwaysGapfilling(model,microbeID,database)
% This function adds exchange, transport and biosynthesis reactions for 
% putrefaction pathways according to data collected from Ref. PMID:29163445
% as part of the DEMETER pipeline.
%
% USAGE:
%
%    [model,rxnsAdded]=putrefactionPathwaysGapfilling(model,microbeID,database)
%
% INPUTS
% model:             COBRA model structure
% microbeID:         ID of the reconstructed microbe that serves as the
%                    reconstruction name and to identify it in input tables
% database:          rBioNet reaction database containing min. 3 columns:
%                    Column 1: reaction abbreviation, Column 2: reaction
%                    name, Column 3: reaction formula.
%
% OUTPUTS
% model:             COBRA model structure with added pathways if applies
% rxnsAdded:         Reactions added based on experimental data
%
% .. Author:
%       - Almut Heinken, 2019-2020

PutrefactionTable = readtable('PutrefactionTable.txt', 'Delimiter', '\t');
PutrefactionTable = table2cell(PutrefactionTable);

rxnsAdded={};
% model index in data table
mInd = find(ismember(PutrefactionTable(:, 1), microbeID));
% if in data table
if ~isempty(mInd)
    if PutrefactionTable{mInd, 2}==1
        % Histidine degradation (histidine -> glutamate)
        % add reactions that are not already in reconstruction
        pthwRxns = {'HISD', 'URCN', 'IZPN', 'GluForTx', 'GLUFORT'};
        if any(~ismember(pthwRxns, model.rxns))
            rxnsAdded = union(rxnsAdded, pthwRxns(~ismember(pthwRxns, model.rxns)));
        end
    end
    if PutrefactionTable{mInd, 3}==1
        % THF production (histidine -> tetrahydrofolate)
        % add reactions that are not already in reconstruction
        pthwRxns = {'HISD', 'URCN', 'IZPN', 'GluForTx', 'FTCD'};
        if any(~ismember(pthwRxns, model.rxns))
            rxnsAdded = union(rxnsAdded, pthwRxns(~ismember(pthwRxns, model.rxns)));
        end
        if ismember('FORTHFC', model.rxns)
            model=removeRxns(model, 'FORTHFC');
        end
    end
    if PutrefactionTable{mInd, 4}==1
        % Glutamate degradation (glutamate -> acetate + pyruvate)
        % add reactions that are not already in reconstruction
        pthwRxns = {'GLUM', '3MASPL', 'MESCONH', 'CITMALL'};
        if any(~ismember(pthwRxns, model.rxns))
            rxnsAdded = union(rxnsAdded, pthwRxns(~ismember(pthwRxns, model.rxns)));
        end
    end
    if PutrefactionTable{mInd, 5}==1
        % Arginine to putrescine_1 via ornithine decarboxylase (ODC, EC: 4.1.1.17)
        % add reactions that are not already in reconstruction
        pthwRxns = {'ARGN', 'ORNDC', 'EX_ptrc(e)', 'PTRCtex2'};
        if any(~ismember(pthwRxns, model.rxns))
            rxnsAdded = union(rxnsAdded, pthwRxns(~ismember(pthwRxns, model.rxns)));
        end
    end
    if PutrefactionTable{mInd, 6}==1
        % Arginine to putrescine_2 via agmatinase (EC: 3.5.3.11)
        % add reactions that are not already in reconstruction
        % exchange and transporter need to be added separately-some
        % models already have uptake reaction
        pthwRxns = {'ARGDC', 'AGMT', 'EX_urea(e)', 'UREAt', 'EX_ptrc(e)', 'PTRCtex2'};
        if any(~ismember(pthwRxns, model.rxns))
            rxnsAdded = union(rxnsAdded, pthwRxns(~ismember(pthwRxns, model.rxns)));
        end
    end
    if PutrefactionTable{mInd, 7}==1
        % Arginine to putrescine_3 via carbamoylputrescine hydrolase (EC: 3.5.1.53)
        % add reactions that are not already in reconstruction
        pthwRxns = {'ARGDC', 'AGMD', 'NCPTRCA', 'EX_ptrc(e)', 'PTRCtex2'};
        if any(~ismember(pthwRxns, model.rxns))
            rxnsAdded = union(rxnsAdded, pthwRxns(~ismember(pthwRxns, model.rxns)));
        end
    end
    if PutrefactionTable{mInd, 8}==1
        % Spermidine/ Spermine production (methionine -> spermidine)
        % add reactions that are not already in reconstruction
        % exchange and transporter need to be added separately-some
        % models already have uptake reaction
        pthwRxns = {'METAT', 'ADMDC', 'SPMS', 'EX_spmd(e)', 'SPMDtex2', 'EX_5mta(e)', '5MTAte'};
        if any(~ismember(pthwRxns, model.rxns))
            rxnsAdded = union(rxnsAdded, pthwRxns(~ismember(pthwRxns, model.rxns)));
        end
    end
    if PutrefactionTable{mInd, 9}==1
        % Cadaverine production (lysine -> cadaverine)
        % add reactions that are not already in reconstruction
        pthwRxns = {'LYSDC', 'EX_15dap(e)', '15DAPt'};
        if any(~ismember(pthwRxns, model.rxns))
            rxnsAdded = union(rxnsAdded, pthwRxns(~ismember(pthwRxns, model.rxns)));
        end
    end
    if PutrefactionTable{mInd, 10}==1
        % Cresol production (tyrosine -> cresol)
        % add reactions that are not already in reconstruction
        pthwRxns = {'TYRTA', '34HPPDC', '4HOXPACDOX_NADP_', '4HPHACDC', 'EX_pcresol(e)', 'PCRESOLt2r'};
        if any(~ismember(pthwRxns, model.rxns))
            rxnsAdded = union(rxnsAdded, pthwRxns(~ismember(pthwRxns, model.rxns)));
        end
    end
    if PutrefactionTable{mInd, 11}==1
        % Indole production (tryptophan -> indole)
        % add reactions that are not already in reconstruction
        pthwRxns = {'TRPAS2i', 'EX_indole(e)', 'INDOLEt2r'};
        if any(~ismember(pthwRxns, model.rxns))
            rxnsAdded = union(rxnsAdded, pthwRxns(~ismember(pthwRxns, model.rxns)));
        end
    end
    if PutrefactionTable{mInd, 12}==1
        % Phenol production (tyrosine -> phenol)
        % add reactions that are not already in reconstruction
        pthwRxns = {'TYRL', 'EX_phenol(e)', 'PHENOLt2r'};
        if any(~ismember(pthwRxns, model.rxns))
            rxnsAdded = union(rxnsAdded, pthwRxns(~ismember(pthwRxns, model.rxns)));
        end
    end
    if PutrefactionTable{mInd, 13}==1
        % H2S_1 via gamma lyase (EC: 4.4.1.1)
        % add reactions that are not already in reconstruction
        pthwRxns = {'CYSDS', 'EX_h2s(e)', 'H2St'};
        if any(~ismember(pthwRxns, model.rxns))
            rxnsAdded = union(rxnsAdded, pthwRxns(~ismember(pthwRxns, model.rxns)));
        end
    end
    if PutrefactionTable{mInd, 14}==1
        % H2S_2 via  3-mercaptopyruvate sulfurtransferase (EC: 2.8.1.2)
        % add reactions that are not already in reconstruction
        pthwRxns = {'CYSTA', 'MCPST_H2S', 'EX_h2s(e)', 'H2St'};
        if any(~ismember(pthwRxns, model.rxns))
            rxnsAdded = union(rxnsAdded, pthwRxns(~ismember(pthwRxns, model.rxns)));
        end
    end
    if PutrefactionTable{mInd, 15}==1
        % H2S_3 via cystathionine beta-synthase (EC: 4.2.1.22)
        % add reactions that are not already in reconstruction
        pthwRxns = {'CYSTS_H2S', 'EX_h2s(e)', 'H2St'};
        if isempty(intersect(model.rxns,{'CYSTGL','SHSL1r','CYSTL'}))
            pthwRxns = union(pthwRxns,{'CYSTGL','EX_2obut(e)','2OBUTt2r'}); 
        end
        if any(~ismember(pthwRxns, model.rxns))
            rxnsAdded = union(rxnsAdded, pthwRxns(~ismember(pthwRxns, model.rxns)));
        end
    end
    if PutrefactionTable{mInd, 16}==1
        % H2S_4 via L-cysteine desulfhydrase (EC: 4.4.1.28)
        % add reactions that are not already in reconstruction
        pthwRxns = {'CYSDS', 'EX_h2s(e)', 'H2St'};
        if any(~ismember(pthwRxns, model.rxns))
            rxnsAdded = union(rxnsAdded, pthwRxns(~ismember(pthwRxns, model.rxns)));
        end
    end
    if PutrefactionTable{mInd, 17}==1
        % H2S_5 via D-cysteine desulfhydrase (EC: 4.4.1.15)
        % add reactions that are not already in reconstruction
        pthwRxns = {'CYSR', 'DCYSDS', 'EX_h2s(e)', 'H2St'};
        if any(~ismember(pthwRxns, model.rxns))
            rxnsAdded = union(rxnsAdded, pthwRxns(~ismember(pthwRxns, model.rxns)));
        end
    end
end

% add all reactions that should be added
for i = 1:length(rxnsAdded)
    if ~ismember(rxnsAdded{i}, model.rxns)
        formula = database.reactions{ismember(database.reactions(:, 1), rxnsAdded{i}), 3};
        model = addReaction(model, rxnsAdded{i}, 'reactionFormula', formula, 'geneRule', 'PutrefactionGapfill');
    end
end

end
