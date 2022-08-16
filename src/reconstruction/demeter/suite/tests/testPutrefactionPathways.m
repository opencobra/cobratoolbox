function [TruePositives, FalseNegatives] = testPutrefactionPathways(model, microbeID, biomassReaction, database)
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
% database          Structure containing rBioNet reaction and metabolite
%                   database
%
% OUTPUT
% TruePositives     Cell array of strings listing all putrefaction reactions
% that can carry flux in the model and in in vitro data.
% FalseNegatives    Cell array of strings listing all putrefaction reactions
% that cannot carry flux in the model but should carry flux according to in
% vitro data.
%
% .. Author:
%      Almut Heinken, Dec 2017
%                     March 2022 - changed code to string-matching to make
%                     it more robust

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end

% read putrefaction product tables
dataTable = readInputTableForPipeline('PutrefactionTable.txt');

corrRxns = {'Histidine degradation (histidine -> glutamate)','GLUFORT';'THF production (histidine -> tetrahydrofolate)','FTCD';'Glutamate production (glutamate -> acetate + pyruvate)','CITMALL';'Putrescine_1','EX_ptrc(e)';'Putrescine_2','EX_ptrc(e)';'Putrescine_3','EX_ptrc(e)';'Spermidine/ Spermine production (methionine -> spermidine)','EX_spmd(e)';'Cadaverine production (lysine -> cadaverine)','EX_15dap(e)';'Cresol production (tyrosine -> cresol)','EX_pcresol(e)';'Indole production (tryptophan -> indole)','EX_indole(e)';'Phenol production (tyrosine -> phenol)','EX_phenol(e)';'H2S_1','EX_h2s(e)';'H2S_2','EX_h2s(e)';'H2S_3','EX_h2s(e)';'H2S_4','EX_h2s(e)';'H2S_5','EX_h2s(e)'};

TruePositives = {};  % true positives (uptake in vitro and in silico)
FalseNegatives = {};  % false negatives (uptake in vitro not in silico)

% find microbe index in putrefaction table
mInd = find(strcmp(dataTable(:,1), microbeID));
if isempty(mInd)
    warning(['Microbe "', microbeID, '" not found in putrefaction product data file.'])
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

    % get the reactions to test
    rxns = {};
    for i=2:size(dataTable,2)
        if contains(version,'(R202') % for Matlab R2020a and newer
            if dataTable{mInd,i}==1
                findCorrRxns = find(strcmp(corrRxns(:,1),dataTable{1,i}));
                rxns = union(rxns,corrRxns(findCorrRxns,2:end));
            end
        else
            if strcmp(dataTable{mInd,i},'1')
                findCorrRxns = find(strcmp(corrRxns(:,1),dataTable{1,i}));
                rxns = union(rxns,corrRxns(findCorrRxns,2:end));
            end
        end
    end

    % flux variability analysis on reactions of interest
    rxns = unique(rxns);
    rxns = rxns(~cellfun('isempty', rxns));
    rxnsInModel=intersect(rxns,model.rxns);
    if ~isempty(rxnsInModel)
        currentDir=pwd;
        try
            [minFlux, maxFlux, ~, ~] = fastFVA(model, 0, 'max', 'ibm_cplex', ...
                rxnsInModel, 'S');
        catch
            warning('fastFVA could not run, so fluxVariability is instead used. Consider installing fastFVA for shorter computation times.');
            cd(currentDir)
            [minFlux, maxFlux] = fluxVariability(model, 0, 'max', rxnsInModel);
        end

        % active flux
        flux = rxnsInModel(maxFlux > -1e-6);
    else
        flux = {};
    end

    % which reaction should carry flux according to in vitro data
    for i=2:size(dataTable,2)
        rxn={};
        if contains(version,'(R202') % for Matlab R2020a and newer
            if dataTable{mInd,i}==1
                rxn = corrRxns{find(strcmp(corrRxns(:,1),dataTable{1,i})),2};
            end
        else
            if strcmp(dataTable{mInd,i},'1')
                rxn = corrRxns{find(strcmp(corrRxns(:,1),dataTable{1,i})),2};
            end
        end
        if ~isempty(rxn)
            % add any that are not in model/not carrying flux to the false negatives
            if ~isempty(intersect(rxn,flux))
                TruePositives = union(TruePositives,rxn);
            else
                FalseNegatives=union(FalseNegatives,rxn);
            end
        end
    end
end

% replace reaction IDs with metabolite names
if ~isempty(TruePositives)
    TruePositives = TruePositives(~cellfun(@isempty, TruePositives));
    TruePositives=strrep(TruePositives,'EX_','');
    TruePositives=strrep(TruePositives,'(e)','');

    for i=1:length(TruePositives)
        if ~isempty(find(strcmp(database.metabolites(:,1),TruePositives{i})))
            TruePositives{i}=database.metabolites{find(strcmp(database.metabolites(:,1),TruePositives{i})),2};
        end
    end
end

% warn about false negatives
if ~isempty(FalseNegatives)
    FalseNegatives = FalseNegatives(~cellfun(@isempty, FalseNegatives));
    FalseNegatives=strrep(FalseNegatives,'EX_','');
    FalseNegatives=strrep(FalseNegatives,'(e)','');
    for i = 1:length(FalseNegatives)
        if ~isempty(find(strcmp(database.metabolites(:,1),FalseNegatives{i})))
        FalseNegatives{i}=database.metabolites{find(strcmp(database.metabolites(:,1),FalseNegatives{i})),2};
        end
    end
end

end
