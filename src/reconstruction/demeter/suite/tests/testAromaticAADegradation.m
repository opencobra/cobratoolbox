function [TruePositives, FalseNegatives] = testAromaticAADegradation(model, microbeID, biomassReaction)
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
%
% OUTPUT
% TruePositives     Cell array of strings listing all aromatic amino acid
% degradation products
% that can be secreted by the model and in comnparative genomic data.
% FalseNegatives    Cell array of strings listing all aromatic amino acid
% degradation products
% that cannot be secreted by the model but should be secreted according to comparative genomic data.
% Almut Heinken, Dec 2017

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end
solver = CBT_LP_SOLVER;

metaboliteDatabase = readtable('MetaboliteDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
metaboliteDatabase=table2cell(metaboliteDatabase);

% read aromatic amino acid degradation product tables
AromaticAATable = readtable('AromaticAATable.txt', 'Delimiter', '\t');
AromaticAAExchanges = {'Phenylpropanoate','EX_pppn(e)';'4-Hydroxyphenylpropanoate','EX_r34hpp(e)';'Indolepropionate','EX_ind3ppa(e)';'Isocaproate','EX_isocapr(e)'};
AromaticAAExchanges=cell2table(AromaticAAExchanges);

% find microbe index in AromaticAA table
mInd = find(ismember(AromaticAATable.MicrobeID, microbeID));
if isempty(mInd)
    warning(['Microbe "', microbeID, '" not found in aromatic amino acid degradation data file.'])
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
    rxns = AromaticAAExchanges(table2array(AromaticAATable(mInd, 2:end)) == 1, 2:end);
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
             currentDir=pwd;
            try
                [~, maxFlux, ~, ~] = fastFVA(model, 0, 'max', 'ibm_cplex', ...
                    rxnsInModel, 'S');
            catch
                warning('fastFVA could not run, so fluxVariability is instead used. Consider installing fastFVA for shorter computation times.');
                cd(currentDir)
                [~, maxFlux] = fluxVariability(model, 0, 'max', rxnsInModel);
            end
            % active flux
            flux = rxnsInModel(maxFlux > 1e-6);
            % which aromatic amino acid degradation product should be secreted according to in vitro data
            %     fData = find(table2array(AromaticAATable(mInd, 2:end)) == 1);
            fData = AromaticAAExchanges(table2array(AromaticAATable(mInd, 2:end)) == 1, 2:end);
            
            % check all exchanges corresponding to each aromatic amino acid degradation product
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

% replace reaction IDs with metabolite names
if ~isempty(TruePositives)
    TruePositives = TruePositives(~cellfun(@isempty, TruePositives));
    TruePositives=strrep(TruePositives,'EX_','');
    TruePositives=strrep(TruePositives,'(e)','');
    
    for i=1:length(TruePositives)
        TruePositives{i}=metaboliteDatabase{find(strcmp(metaboliteDatabase(:,1),TruePositives{i})),2};
    end
end

% warn about false negatives
if ~isempty(FalseNegatives)
    FalseNegatives = FalseNegatives(~cellfun(@isempty, FalseNegatives));
    FalseNegatives=strrep(FalseNegatives,'EX_','');
    FalseNegatives=strrep(FalseNegatives,'(e)','');
    for i = 1:length(FalseNegatives)
        FalseNegatives{i}=metaboliteDatabase{find(strcmp(metaboliteDatabase(:,1),FalseNegatives{i})),2};
        warning(['Microbe "' microbeID, '" cannot produce aromatic amino acid degradation product"', FalseNegatives{i}, '".'])
    end
end

end
