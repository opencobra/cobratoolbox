function [TruePositives, FalseNegatives] = testFermentationProducts(model, microbeID, biomassReaction)
% Performs an FVA and reports those fermentation products (exchange reactions)
% that can be secreted by the model and should be secreted according to
% data (true positives) and those fermentation products that cannot be secreted by
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
% TruePositives     Cell array of strings listing all fermentation products
%                   (exchange reactions) that can be secreted by the model
%                   and in in vitro data.
% FalseNegatives    Cell array of strings listing all fermentation products
%                   (exchange reactions) that cannot be secreted by the model
%                   but should be secreted according to in vitro data.
%
% Stefania Magnusdottir, Nov 2017
% Almut Heinken, Jan 2018-reduced number of reactions minimized and
% maximized to speed up the computation

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end
solver = CBT_LP_SOLVER;

metaboliteDatabase = readtable('MetaboliteDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
metaboliteDatabase=table2cell(metaboliteDatabase);

% read fermentation product tables
fermentationTable = readtable('FermentationTable.txt', 'Delimiter', '\t');
% remove the reference columns
for i=1:11
    if ismember(['Ref' num2str(i)],fermentationTable.Properties.VariableNames)
fermentationTable.(['Ref' num2str(i)])=[];
    end
end
fermentationExchanges = {'Acetate kinase (acetate producer or consumer)','EX_ac(e)';'Bifid shunt','EX_ac(e)';'Acetogen pathway','EX_ac(e)';'Formate producer','EX_for(e)';'D-lactate producer or consumer','EX_lac_D(e)';'L-lactate producer or consumer','EX_lac_L(e)';'Ethanol producer or consumer','EX_etoh(e)';'Succinate producer','EX_succ(e)';'Propionate from succinate','EX_ppa(e)';'Propionate from propane-1,2-diol','EX_ppa(e)';'Propionate from lactate (acrylate pathway)','EX_ppa(e)';'Propionate from threonine','EX_ppa(e)';'Wood-Werkman cycle','EX_ppa(e)';'Butyrate via butyryl-CoA: acetate CoA transferase','EX_but(e)';'Butyrate via butyrate kinase','EX_but(e)';'Butyrate from lysine via butyrate-acetoacetate CoA-transferase','EX_but(e)';'Butyrate from glutarate or glutamate','EX_but(e)';'Butyrate from 4-hydroxybutyrate or succinate','EX_but(e)';'Hydrogen from ferredoxin oxidoreductase','EX_h2(e)';'Hydrogen from formate hydrogen lyase','EX_h2(e)';'Methanogenesis','EX_ch4(e)';'Sulfate reducer','EX_h2s(e)';'Isobutyrate producer','EX_isobut(e)';'Isovalerate producer','EX_isoval(e)';'Acetoin producer','EX_actn_R(e)';'2,3-butanediol producer','EX_btd_RR(e)';'Indole producer','EX_indole(e)';'Phenylacetate producer','EX_pac(e)';'Butanol producer','EX_btoh(e)';'Valerate producer','EX_M03134(e)'};
fermentationExchanges=cell2table(fermentationExchanges);

% find microbe index in fermentation table
mInd = find(ismember(fermentationTable.MicrobeID, microbeID));
if isempty(mInd)
    warning(['Microbe "', microbeID, '" not found in fermentation product data file.'])
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
    
    rxns = fermentationExchanges(table2array(fermentationTable(mInd, 2:end)) == 1, 2:end);
    
    TruePositives = {};  % true positives (flux in vitro and in silico)
    FalseNegatives = {};  % false negatives (flux in vitro not in silico)
    % flux variability analysis on reactions of interest
    rxns = unique(table2cell(rxns));
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
            % which fermentation product should be secreted according to in vitro data
            fData = fermentationExchanges(table2array(fermentationTable(mInd, 2:end)) == 1, 2);
            
            % check all exchanges corresponding to each fermentation product
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
        warning(['Microbe "' microbeID, '" cannot secrete fermentation product "', FalseNegatives{i}, '".'])
    end
end

end
