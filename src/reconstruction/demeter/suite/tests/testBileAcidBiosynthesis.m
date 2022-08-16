function [TruePositives, FalseNegatives] = testBileAcidBiosynthesis(model, microbeID, biomassReaction, database)
% Performs an FVA and reports those bile acid metabolites (exchange reactions)
% that can be secreted by the model and should be secreted according to
% data (true positives) and those bile acid metabolites that cannot be secreted by
% the model but should be secreted according to in vitro data (false
% negatives).
%
% INPUT
% model             COBRA model structure
% microbeID         Microbe ID in data file
% biomassReaction   Biomass objective functions (low flux through BOF
%                   required in analysis)
% database          Structure containing rBioNet reaction and metabolite
%                   database
%
% OUTPUT
% TruePositives     Cell array of strings listing all bile acid products
%                   (exchange reactions) that can be secreted by the model
%                   and in in vitro data.
% FalseNegatives    Cell array of strings listing all bile acid products
%                   (exchange reactions) that cannot be secreted by the model
%                   but should be secreted according to in vitro data.
%
% .. Author:
%      Almut Heinken, Dec 2017
%                     March 2022 - changed code to string-matching to make
%                     it more robust

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end

% read bile acid product table
dataTable = readInputTableForPipeline('BileAcidTable.txt');

corrRxns = {'Chenodeoxycholate','EX_C02528(e)';'Cholate','EX_cholate(e)';'7-Dehydrochenodeoxycholate','EX_7dhcdchol(e)';'7-Dehydrocholate','EX_7ocholate(e)';'Ursocholate','EX_uchol(e)';'Ursodiol','EX_HC02194(e)';'3-Dehydrochenodeoxycholate','EX_3dhcdchol(e)';'3-Dehydrocholate','EX_3dhchol(e)';'Isochenodeoxycholate','EX_icdchol(e)';'Isocholate','EX_isochol(e)';'12-Dehydrocholate','EX_12dhchol(e)';'Allodeoxycholate','EX_adchac(e)';'Allolithocholate','EX_alchac(e)';'Deoxycholate','EX_dchac(e)';'Lithocholate','EX_HC02191(e)'};

TruePositives = {};  % true positives (uptake in vitro and in silico)
FalseNegatives = {};  % false negatives (uptake in vitro not in silico)

% find microbe index in bile acid table
mInd = find(strcmp(dataTable(:,1), microbeID));
if isempty(mInd)
    warning(['Microbe "', microbeID, '" not found in bile acid metabolism data file.'])
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
        flux = rxnsInModel(maxFlux > 1e-6);
    else
        flux = {};
    end

    % which reaction should carry flux according to comparative genomics data
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
TruePositives=strrep(TruePositives,'EX_','');
TruePositives=strrep(TruePositives,'(e)','');

for i=1:length(TruePositives)
    TruePositives{i}=database.metabolites{find(strcmp(database.metabolites(:,1),TruePositives{i})),2};
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
