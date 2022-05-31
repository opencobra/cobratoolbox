function [TruePositives, FalseNegatives] = testSecretionProducts(model, microbeID, biomassReaction, database, inputDataFolder)
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
% database          Structure containing rBioNet reaction and metabolite
%                   database
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
% .. Author:
%      Almut Heinken, August 2019
%                     March  2022 - changed code to string-matching to make
%                     it more robust

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end

% read secretion product tables
dataTable = readInputTableForPipeline([inputDataFolder filesep 'secretionProductTable.txt']);

% remove the reference columns
dataTable(:,find(strncmp(dataTable(1,:),'Ref',3))) = [];

corrRxns = {'Folate','EX_fol(e)','EX_5mthf(e)','EX_thf(e)';'Thiamin','EX_thm(e)','','';'Riboflavin','EX_ribflv(e)','','';'Niacin','EX_nac(e)','EX_ncam(e)','';'Pyridoxine','EX_pydx(e)','EX_pydxn(e)','EX_pydam(e)';'Cobalamin','EX_cbl1(e)','EX_adocbl(e)','';'Menaquinone','EX_mqn7(e)','EX_mqn8(e)','';'GABA','EX_4abut(e)','','';'Biotin','EX_btn(e)','','';'Cholate','EX_cholate(e)','','';'Chenodeoxycholate','EX_C02528(e)','','';'Deoxycholate','EX_dchac(e)','','';'Tyramine','EX_tym(e)','','';'Tryptamine','EX_trypta(e)','','';'Trimethylamine N-oxide','EX_tmao(e)','','';'Trimethylamine','EX_tma(e)','','';'Spermine','EX_sprm(e)','','';'Spermidine','EX_spmd(e)','','';'Putrescine','EX_ptrc(e)','','';'p-Cresol','EX_pcresol(e)','','';'Ammonia','EX_nh4(e)','','';'Nitrogen','EX_n2(e)','','';'Methylamine','EX_mma(e)','','';'Methanol','EX_meoh(e)','','';'L-threonine','EX_thr_L(e)','','';'Linoleic acid','EX_lnlc(e)','','';'Lithocholate','EX_HC02191(e)','','';'L-Glutamate','EX_glu_L(e)','','';'L-Glutamine','EX_gln_L(e)','','';'L-Alanine','EX_ala_L(e)','','';'Indole-3-acetate','EX_ind3ac(e)','','';'Histamine','EX_hista(e)','','';'Peroxide','EX_h2o2(e)','','';'5-Aminovalerate','EX_5aptn(e)','','';'2-Oxobutyrate','EX_2obut(e)','','';'1,2-Ethanediol','EX_12ethd(e)','','';'Hydrogen','EX_h2(e)','','';'2-Aminobutyrate','EX_C02356(e)','','';'1,3-Propanediol','EX_13ppd(e)','','';'1,2-propanediol ','EX_12ppd_S(e)','','';'Acetone','EX_acetone(e)','','';'Butylamine','EX_butam(e)','','';'Cadaverine','EX_15dap(e)','','';'Formaldehyde','EX_fald(e)','','';'Urea','EX_urea(e)','','';'Propanol','EX_ppoh(e)','','';'Propanal','EX_ppal(e)','','';'Phenylethylamine','EX_peamn(e)','','';'Isopropanol','EX_2ppoh(e)','','';'L-malate','EX_mal_L(e)','','';'Sulfide','EX_h2s(e)','',''};

TruePositives = {};  % true positives (secretion in vitro and in silico)
FalseNegatives = {};  % false negatives (secretion in vitro not in silico)

% find microbe index in secretion table
mInd = find(strcmp(dataTable(:,1), microbeID));
if isempty(mInd)
    warning(['Microbe "', microbeID, '" not found in secretion product data file.'])
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
    % check all exchanges corresponding to each uptake
    % with multiple exchanges per uptake, at least one should be
    % consumed
    % so if there is least one true positive per secretion false negatives
    % are not considered

    for i=2:size(dataTable,2)
        findCorrRxns = [];
        if contains(version,'(R202') % for Matlab R2020a and newer
            if dataTable{mInd,i}==1
                findCorrRxns = find(strcmp(corrRxns(:,1),dataTable{1,i}));
            end
        else
            if strcmp(dataTable{mInd,i},'1')
                findCorrRxns = find(strcmp(corrRxns(:,1),dataTable{1,i}));
            end
        end
        if ~isempty(findCorrRxns)
            allEx = corrRxns(findCorrRxns,2:end);
            allEx = allEx(~cellfun(@isempty, allEx));
            if ~isempty(intersect(allEx, rxnsInModel))
                if isempty(intersect(allEx, flux))
                    FalseNegatives = union(FalseNegatives, setdiff(allEx{1}, flux));
                else
                    TruePositives = union(TruePositives, intersect(allEx{1}, flux));
                end
            else
                % add any that are not in model to the false negatives
                % if there are multiple exchanges per metabolite, only
                % take the first one
                FalseNegatives=union(FalseNegatives,allEx{1});
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
