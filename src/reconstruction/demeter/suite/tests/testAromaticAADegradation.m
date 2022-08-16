function [TruePositives, FalseNegatives] = testAromaticAADegradation(model, microbeID, biomassReaction, database)
% Performs an FVA and reports those AromaticAA pathway end reactions (exchange reactions)
% that can carry flux in the model and should carry flux according to
% data (true positives) and those AromaticAA pathway end reactions that
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
% TruePositives     Cell array of strings listing all aromatic amino acid
% degradation products
% that can be secreted by the model and in comnparative genomic data.
% FalseNegatives    Cell array of strings listing all aromatic amino acid
% degradation products
% that cannot be secreted by the model but should be secreted according to comparative genomic data.
%
% .. Author:
%      Almut Heinken, Dec 2017
%                     March  2022 - changed code to string-matching to make
%                     it more robust

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end

% read aromatic amino acid degradation product table
dataTable = readInputTableForPipeline('AromaticAATable.txt');

corrRxns = {'Phenylpropanoate','EX_pppn(e)';'4-Hydroxyphenylpropanoate','EX_r34hpp(e)';'Indolepropionate','EX_ind3ppa(e)';'Isocaproate','EX_isocapr(e)'};

TruePositives = {};  % true positives (uptake in vitro and in silico)
FalseNegatives = {};  % false negatives (uptake in vitro not in silico)

% find microbe index in data table
mInd = find(strcmp(dataTable(:,1), microbeID));
if isempty(mInd)
    warning(['Microbe "', microbeID, '" not found in aromatic amino acid degradation data file.'])
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
        TruePositives{i}=database.metabolites{find(strcmp(database.metabolites(:,1),TruePositives{i})),2};
    end
end

% warn about false negatives
if ~isempty(FalseNegatives)
    FalseNegatives = FalseNegatives(~cellfun(@isempty, FalseNegatives));
    FalseNegatives=strrep(FalseNegatives,'EX_','');
    FalseNegatives=strrep(FalseNegatives,'(e)','');
    for i = 1:length(FalseNegatives)
        FalseNegatives{i}=database.metabolites{find(strcmp(database.metabolites(:,1),FalseNegatives{i})),2};
    end
end

end
