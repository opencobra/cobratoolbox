function [TruePositives, FalseNegatives] = testSecretionProducts(model, microbeID, biomassReaction, inputDataFolder)
% Performs an FVA and reports those secretions (exchange reactions)
% that can be secreted by the model and should be secreted according to
% data (true positives) and those secretions that cannot be secreted by
% the model but should be secreted according to in vitro data (false
% negatives).
% Based on literature search of reported secretion-secreting probiotics
% performed 11/2017
%
% INPUT
% model             COBRA model structure
% microbeID         Microbe ID in secretion secretion data file
% biomassReaction   Biomass objective functions (low flux through BOF
%                   required in analysis)
% inputDataFolder   Folder with experimental data and database files
%                   to load
%
% OUTPUT
% TruePositives     Cell array of strings listing all secretions
%                   (exchange reactions) that can be secreted by the model
%                   and in in vitro data.
% FalseNegatives    Cell array of strings listing all secretions
%                   (exchange reactions) that cannot be secreted by the model
%                   but should be secreted according to in vitro data.
%
% Almut Heinken, August 2019

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end
solver = CBT_LP_SOLVER;

metaboliteDatabase = table2cell(readtable('MetaboliteDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false));

% read secretion product tables
secretionTable = readtable([inputDataFolder filesep 'secretionProductTable.txt'], 'Delimiter', '\t');
% remove the reference columns
for i=1:11
    if ismember(['Ref' num2str(i)],secretionTable.Properties.VariableNames)
        secretionTable.(['Ref' num2str(i)])=[];
    end
end
secretionExchanges = {'Folate','EX_fol(e)','EX_5mthf(e)','EX_thf(e)';'Thiamin','EX_thm(e)','','';'Riboflavin','EX_ribflv(e)','','';'Niacin','EX_nac(e)','EX_ncam(e)','';'Pyridoxine','EX_pydx(e)','EX_pydxn(e)','EX_pydam(e)';'Cobalamin','EX_cbl1(e)','EX_adocbl(e)','';'Menaquinone','EX_mqn7(e)','EX_mqn8(e)','';'GABA','EX_4abut(e)','','';'Biotin','EX_btn(e)','','';'Cholate','EX_cholate(e)','','';'Chenodeoxycholate','EX_C02528(e)','','';'Deoxycholate','EX_dchac(e)','','';'Tyramine','EX_tym(e)','','';'Tryptamine','EX_trypta(e)','','';'Trimethylamine N-oxide','EX_tmao(e)','','';'Trimethylamine','EX_tma(e)','','';'Spermine','EX_sprm(e)','','';'Spermidine','EX_spmd(e)','','';'Putrescine','EX_ptrc(e)','','';'p-Cresol','EX_pcresol(e)','','';'Ammonia','EX_nh4(e)','','';'Nitrogen','EX_n2(e)','','';'Methylamine','EX_mma(e)','','';'Methanol','EX_meoh(e)','','';'L-threonine','EX_thr_L(e)','','';'Linoleic acid','EX_lnlc(e)','','';'Lithocholate','EX_HC02191(e)','','';'L-Glutamate','EX_glu_L(e)','','';'L-Glutamine','EX_gln_L(e)','','';'L-Alanine','EX_ala_L(e)','','';'Indole-3-acetate','EX_ind3ac(e)','','';'Histamine','EX_hista(e)','','';'Peroxide','EX_h2o2(e)','','';'5-Aminovalerate','EX_5aptn(e)','','';'2-Oxobutyrate','EX_2obut(e)','','';'1,2-Ethanediol','EX_12ethd(e)','','';'Hydrogen','EX_h2(e)','','';'2-Aminobutyrate','EX_C02356(e)','','';'1,3-Propanediol','EX_13ppd(e)','','';'1,2-propanediol ','EX_12ppd_S(e)','','';'Acetone','EX_acetone(e)','','';'Butylamine','EX_butam(e)','','';'Cadaverine','EX_15dap(e)','','';'Formaldehyde','EX_fald(e)','','';'Urea','EX_urea(e)','','';'Propanol','EX_ppoh(e)','','';'Propanal','EX_ppal(e)','','';'Phenylethylamine','EX_peamn(e)','','';'Isopropanol','EX_2ppoh(e)','','';'L-malate','EX_mal_L(e)','','';'Sulfide','EX_h2s(e)','',''};
secretionExchanges=cell2table(secretionExchanges);

% find microbe index in secretion table
mInd = find(ismember(secretionTable.MicrobeID, microbeID));
if isempty(mInd)
    warning(['Microbe "', microbeID, '" not found in secretion product data file.'])
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
    
    rxns = secretionExchanges(table2array(secretionTable(mInd, 2:end)) == 1, 2:end);
    
    TruePositives = {};  % true positives (secretion in vitro and in silico)
    FalseNegatives = {};  % false negatives (secretion in vitro not in silico)
    
    % flux variability analysis on reactions of interest
    rxns = unique(table2cell(rxns));
    rxns = rxns(~cellfun('isempty', rxns));
    if ~isempty(rxns)
        rxnsInModel=intersect(rxns,model.rxns);
        if isempty(rxnsInModel)
            % all exchange reactions that should be there are not there -> false
            % negatives
            FalseNegatives = rxns;
            TruePositives= {};
        else
            currentDir=pwd;
            try
                [~, maxFlux, ~, ~] = fastFVA(model, 0, 'max', 'ibm_cplex', ...
                    resolveBlocked, 'S');
            catch
                warning('fastFVA could not run, so fluxVariability is instead used. Consider installing fastFVA for shorter computation times.');
                cd(currentDir)
                [~, maxFlux] = fluxVariability(model, 0, 'max', resolveBlocked);
            end
            
            % active flux
            flux = rxnsInModel(maxFlux > 1e-6);
            % which secretions should be secreted according to in vitro data
            %     vData = secretionExchanges(table2array(secretionTable(mInd, 2:end)) == 1, 2);
            vData = find(table2array(secretionTable(mInd, 2:end)) == 1);
            % check all exchanges corresponding to each secretion
            % with multiple exchanges per secretion, at least one should be secreted
            % so if there is least one true positive per secretion false negatives
            % are not considered
            for i = 1:size(vData,1)
                tableData = table2array(secretionExchanges(vData(i), 2:end));
                allEx = tableData(~cellfun(@isempty, tableData));
                % let us also make sure de novo production is predicted by
                % preventing uptake of these secretions
                if ~isempty(allEx)
                    for j = 1:length(allEx)
                        model = changeRxnBounds(model, allEx{j}, 0, 'l');
                    end
                end
                if ~isempty(intersect(allEx, flux))
                    TruePositives = union(TruePositives, intersect(allEx, flux));
                else
                    FalseNegatives = union(FalseNegatives, setdiff(allEx, flux));
                end
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
    end
end

end
