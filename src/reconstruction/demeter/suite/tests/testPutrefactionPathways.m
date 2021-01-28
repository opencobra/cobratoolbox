function [TruePositives, FalseNegatives] = testPutrefactionPathways(model, microbeID, biomassReaction)
% Performs an FVA and reports those putrefaction pathway end reactions (exchange reactions)
% that can carry flux in the model and should carry flux according to
% data (true positives) and those putrefaction pathway end reactions that
% cannot carry flux in the model but should be secreted according to in
% vitro data (false negatives).
%
% INPUT
% model             COBRA model structure
% microbeID         Microbe ID in carbon source data file
% biomassReaction   Biomass objective functions (low flux through BOF
%                   required in analysis)
%
% OUTPUT
% TruePositives     Cell array of strings listing all putrefaction reactions
% that can carry flux in the model and in in vitro data.
% FalseNegatives    Cell array of strings listing all putrefaction reactions
% that cannot carry flux in the model but should carry flux according to in
% vitro data.
% Almut Heinken, Dec 2017

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end
solver = CBT_LP_SOLVER;

% read metabolite database
metaboliteDatabase = table2cell(readtable('MetaboliteDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false));

% read putrefaction product tables
putrefactionTable = readtable('PutrefactionTable.txt', 'Delimiter', '\t');
putrefactionReactions = {'Histidine degradation (histidine -> glutamate)','GLUFORT';'THF production (histidine -> tetrahydrofolate)','FTCD';'Glutamate production (glutamate -> acetate + pyruvate)','CITMALL';'Putrescine_1','EX_ptrc(e)';'Putrescine_2','EX_ptrc(e)';'Putrescine_3','EX_ptrc(e)';'Spermidine/ Spermine production (methionine -> spermidine)','EX_spmd(e)';'Cadaverine production (lysine -> cadaverine)','EX_15dap(e)';'Cresol production (tyrosine -> cresol)','EX_pcresol(e)';'Indole production (tryptophan -> indole)','EX_indole(e)';'Phenol production (tyrosine -> phenol)','EX_phenol(e)';'H2S_1','EX_h2s(e)';'H2S_2','EX_h2s(e)';'H2S_3','EX_h2s(e)';'H2S_4','EX_h2s(e)';'H2S_5','EX_h2s(e)'};
putrefactionReactions=cell2table(putrefactionReactions);

% find microbe index in putrefaction table
mInd = find(ismember(putrefactionTable.MicrobeID, microbeID));
if isempty(mInd)
    warning(['Microbe "', microbeID, '" not found in putrefaction pathway data file.'])
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
%     model = changeRxnBounds(model, biomassReaction, 1e-3, 'l');
    % list exchange reactions
    exchanges = model.rxns(strncmp('EX_', model.rxns, 3));
    % open all exchanges
    model = changeRxnBounds(model, exchanges, -1000, 'l');
    model = changeRxnBounds(model, exchanges, 1000, 'u');
    rxns = putrefactionReactions(table2array(putrefactionTable(mInd, 2:end)) == 1, 2:end);
    if ~isempty(rxns)
        % flux variability analysis on reactions of interest
        rxns = unique(table2cell(rxns));
        rxns = rxns(~cellfun('isempty', rxns));
        rxnsInModel=intersect(rxns,model.rxns);
        rxnsNotInModel=setdiff(rxns,model.rxns);
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
            % which putrefaction products should be secreted according to in vitro data
            %      fData = find(table2array(putrefactionTable(mInd, 2:end)) == 1);
            fData = putrefactionReactions(table2array(putrefactionTable(mInd, 2:end)) == 1, 2:end);
            
            % check all exchanges corresponding to each putrefaction pathway
            TruePositives = intersect(table2cell(fData), flux);
            FalseNegatives = setdiff(table2cell(fData), flux);
            % add any that are not in model to the false negatives
            if ~isempty(rxnsNotInModel)
                FalseNegatives=union(FalseNegatives,rxnsNotInModel);
            end
        end
    else
        TruePositives = {};
        FalseNegatives = {};
    end
end

% warn about false negatives
if ~isempty(FalseNegatives)
    FalseNegatives = FalseNegatives(~cellfun(@isempty, FalseNegatives));
    FalseNegatives=strrep(FalseNegatives,'EX_','');
    FalseNegatives=strrep(FalseNegatives,'(e)','');
    for i = 1:length(FalseNegatives)
        FalseNegatives{i}=metaboliteDatabase{find(strcmp(metaboliteDatabase(:,1),FalseNegatives{i})),2};
        warning(['Microbe "' microbeID, '" cannot produce flux through putrefaction pathway "', FalseNegatives{i}, '".'])
    end
end

end
