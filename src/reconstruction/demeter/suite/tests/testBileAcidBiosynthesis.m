function [TruePositives, FalseNegatives] = testBileAcidBiosynthesis(model, microbeID, biomassReaction)
% Performs an FVA and reports those bile acid metabolites (exchange reactions)
% that can be secreted by the model and should be secreted according to
% data (true positives) and those bile acid metabolites that cannot be secreted by
% the model but should be secreted according to in vitro data (false
% negatives).
%
% INPUT
% model             COBRA model structure
% microbeID         Microbe ID in carbon source data file
% biomassReaction   Biomass objective functions (low flux through BOF
%                   required in analysis)
%
% OUTPUT
% TruePositives     Cell array of strings listing all bile acid products
%                   (exchange reactions) that can be secreted by the model
%                   and in in vitro data.
% FalseNegatives    Cell array of strings listing all bile acid products
%                   (exchange reactions) that cannot be secreted by the model
%                   but should be secreted according to in vitro data.
%
% Almut Heinken, Dec 2017

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end
solver = CBT_LP_SOLVER;

fileDir = fileparts(which('ReactionTranslationTable.txt'));
metaboliteDatabase = readtable([fileDir filesep 'MetaboliteDatabase.txt'], 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
metaboliteDatabase=table2cell(metaboliteDatabase);

% read bile acid product table
BileAcidTable = readtable('BileAcidTable.txt', 'Delimiter', '\t');
BileAcidExchanges = {'Chenodeoxycholate','EX_C02528(e)';'Cholate','EX_cholate(e)';'7-Dehydrochenodeoxycholate','EX_7dhcdchol(e)';'7-Dehydrocholate','EX_7ocholate(e)';'Ursocholate','EX_uchol(e)';'Ursodiol','EX_HC02194(e)';'3-Dehydrochenodeoxycholate','EX_3dhcdchol(e)';'3-Dehydrocholate','EX_3dhchol(e)';'Isochenodeoxycholate','EX_icdchol(e)';'Isocholate','EX_isochol(e)';'12-Dehydrocholate','EX_12dhchol(e)';'Allodeoxycholate','EX_adchac(e)';'Allolithocholate','EX_alchac(e)';'Deoxycholate','EX_dchac(e)';'Lithocholate','EX_HC02191(e)'};
BileAcidExchanges=cell2table(BileAcidExchanges);

% find microbe index in bile acid table
mInd = find(ismember(BileAcidTable.MicrobeID, microbeID));
if isempty(mInd)
    warning(['Microbe "', microbeID, '" not found in bile acid product data file.'])
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
    rxns = BileAcidExchanges(table2array(BileAcidTable(mInd, 2:end)) == 1, 2:end);
    
    TruePositives = {};  % true positives (flux in vitro and in silico)
    FalseNegatives = {};  % false negatives (flux in vitro not in silico)
    
    % flux variability analysis on reactions of interest
    rxns = table2cell(rxns);
    rxns = unique(rxns);
    rxns = rxns(~cellfun('isempty', rxns));
    if ~isempty(rxns)
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
            % which bile acid should be secreted according to in vitro data
            fData = BileAcidExchanges(table2array(BileAcidTable(mInd, 2:end)) == 1, 2:end);
            %         fData = find(table2array(BileAcidTable(mInd, 2:end)) == 1);
            % check all exchanges corresponding to each bile acid
            TruePositives = intersect(table2cell(fData), flux);
            FalseNegatives = setdiff(table2cell(fData), flux);
            % add any that are not in model to the false negatives
            if ~isempty(rxnsNotInModel)
                FalseNegatives=union(FalseNegatives,rxnsNotInModel);
            end
        end
    end
end

% replace reaction IDs with metabolite names
TruePositives=strrep(TruePositives,'EX_','');
TruePositives=strrep(TruePositives,'(e)','');

for i=1:length(TruePositives)
    TruePositives{i}=metaboliteDatabase{find(strcmp(metaboliteDatabase(:,1),TruePositives{i})),2};
end

% warn about false negatives
if ~isempty(FalseNegatives)
    FalseNegatives = FalseNegatives(~cellfun(@isempty, FalseNegatives));
    FalseNegatives=strrep(FalseNegatives,'EX_','');
    FalseNegatives=strrep(FalseNegatives,'(e)','');
    for i = 1:length(FalseNegatives)
        FalseNegatives{i}=metaboliteDatabase{find(strcmp(metaboliteDatabase(:,1),FalseNegatives{i})),2};
        warning(['Microbe "' microbeID, '" cannot secrete bile acid product "', FalseNegatives{i}, '".'])
    end
end

end
