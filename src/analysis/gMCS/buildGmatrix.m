function [G, G_ind, related, n_genes_KO, G_time] = buildGmatrix(model_name, model, separate_isoform, numWorkers, printLevel)
% Build the G matrix required for the calculation of genetic Minimal Cut
% Sets (gMCSs).
%
% USAGE:
%
%    [G, G_ind, related, n_genes_KO, G_time] = buildGmatrix(model_name, model_struct, separate_isoform, numWorkers, printLevel)
%
% INPUTS:
%    model_name:          Name of the metabolic model under study.
%    model_struct:        Metabolic model structure (COBRA Toolbox format).
%    separate_isoform:    Character used to discriminate different isoforms of a gene.
%
% OPTIONAL INPUTS:
%    numWorkers:        Maximum number of workers
%                       * 0 - maximum provided by the system (automatic)
%                       * 1 - sequential
%                       * 2+ - parallel
%    printLevel:        show the reactions created in models.
%                       * 0 - shows nothing
%                       * 1 - shows progress by reactions (default)
%                       * 2+ - shows everything (reaction and network generation)
%
% OUTPUTS:
%    G:             G matrix.
%    G_ind:         Gene knockouts associated with each row in the G matrix.
%    related:       Relationships among rows of the G matrix.
%    n_genes_KO:    Number of genes whose knockout is added by each row of the G matrix.
%    G_time:        Calculation times for each of the steps.
%
% EXAMPLE:
%
%    [G, G_ind, related, n_genes_KO, G_time] = buildGmatrix('Recon2.v04', modelR204, '.')
%
% .. Authors:
%       - Inigo Apaolaza, 16/11/2017, University of Navarra, TECNUN School of Engineering.
%       - Luis V. Valcarcel, 19/11/2017, University of Navarra, TECNUN School of Engineering.
%       - Francisco J. Planes, 20/11/2017, University of Navarra, TECNUN School of Engineering.
%       - Inigo Apaolaza, 10/04/2018, University of Navarra, TECNUN School of Engineering.

time_a = tic;
% Generate name for temporary folder
global CBTDIR
tmpFolderName = [CBTDIR filesep '.tmp'];
if ~exist(tmpFolderName,'dir')  % Create directories if needed
    mkdir(tmpFolderName)
end
if ~exist([tmpFolderName filesep 'rxn_level_gMCSs'],'dir')
    mkdir([tmpFolderName filesep 'rxn_level_gMCSs'])
end
if ~exist([tmpFolderName filesep 'rxn_level_gMCSs_by_rxn'],'dir')
    mkdir([tmpFolderName filesep 'rxn_level_gMCSs_by_rxn'])
end
if ~exist([tmpFolderName filesep 'rxn_level_models'],'dir')
    mkdir([tmpFolderName filesep 'rxn_level_models'])
end

% Analyze the GPR rules in order to set the strategy for the calculation of
% the knockouts for the G matrix
grRules = model.grRules;
rxnGeneMat = model.rxnGeneMat;
n_rxns = size(rxnGeneMat, 1);

rxns_0_genes = sum(rxnGeneMat, 2) == 0;
rxns_1_gene = sum(rxnGeneMat, 2) == 1;
rxns_or = cellfun(@strfind, grRules, repmat({'or'}, n_rxns, 1), 'UniformOutput', false);
rxns_or = ~cellfun(@isempty, rxns_or) & sum(rxnGeneMat, 2) > 1;
rxns_and = cellfun(@strfind, grRules, repmat({'and'}, n_rxns, 1), 'UniformOutput', false);
rxns_and = ~cellfun(@isempty, rxns_and) & sum(rxnGeneMat, 2) > 1;
rxns_only_or = rxns_or & ~rxns_and;
rxns_only_and = ~rxns_or & rxns_and;
rxns_or_and = rxns_or & rxns_and;

n_rxns_0_genes = sum(rxns_0_genes);
n_rxns_1_gene = sum(rxns_1_gene);
n_rxns_only_or = sum(rxns_only_or);
n_rxns_only_and = sum(rxns_only_and);
n_rxns_or_and = sum(rxns_or_and);
n_rxns_total = n_rxns_0_genes+n_rxns_1_gene+n_rxns_only_or+n_rxns_only_and+n_rxns_or_and;

summary_1 = {'n_rxns_0_genes', n_rxns_0_genes; 'n_rxns_1_gene', n_rxns_1_gene;
    'n_rxns_only_or', n_rxns_only_or; 'n_rxns_only_and', n_rxns_only_and;
    'n_rxns_or_and', n_rxns_or_and; 'n_rxns_total', n_rxns_total};
if printLevel >=1
    fprintf('\nG MATRIX - Summary\n')
    disp(summary_1)
end
ini_time = toc(time_a);

% Step 1 - Reactions with 1 gene
% clc
if printLevel >=1
    disp('G MATRIX - STEP 1');
end
time_b = tic;
act_rxnGeneMat = rxnGeneMat(rxns_1_gene, :);
not_delete_cols = sum(act_rxnGeneMat, 1) ~= 0;
act_rxnGeneMat = act_rxnGeneMat(:, not_delete_cols);
G_ind_1 = model.genes(not_delete_cols);
n_KO_1 = length(G_ind_1);
tmp_G_1 = act_rxnGeneMat';
G_1 = zeros(n_KO_1, n_rxns);
G_1(:, rxns_1_gene) = tmp_G_1;
G_time(1, 1) = toc(time_b);

% Step2 - Reactions with more than one gene and only OR rules
% clc
if printLevel >=1
    disp('G MATRIX - STEP 2');
end
time_c = tic;
act_rxnGeneMat = rxnGeneMat(rxns_only_or, :);
pos_rxns_only_or = find(rxns_only_or);
for i = 1:n_rxns_only_or
    G_ind_2{i, 1} = model.genes(logical(act_rxnGeneMat(i, :)))';
end
tmp_G_2 = eye(n_rxns_only_or);
G_2 = zeros(n_rxns_only_or, n_rxns);
G_2(:, rxns_only_or) = tmp_G_2;
G_time(2, 1) = toc(time_c);

% Reactions with more than one gene and only AND rules
% clc
if printLevel >=1
    disp('G MATRIX - STEP 3');
end
time_d = tic;
act_rxnGeneMat = rxnGeneMat(rxns_only_and, :);
not_delete_cols = sum(act_rxnGeneMat, 1) ~= 0;
act_rxnGeneMat = act_rxnGeneMat(:, not_delete_cols);
G_ind_3 = model.genes(not_delete_cols);
n_KO_3 = length(G_ind_3);
tmp_G_3 = act_rxnGeneMat';
G_3 = zeros(n_KO_3, n_rxns);
G_3(:, rxns_only_and) = tmp_G_3;
G_time(3, 1) = toc(time_d);

% Reactions with more than one gene and both OR and AND rules
time_e = tic;
search_filename = [tmpFolderName filesep 'rxn_level_models' filesep 'rxn_level_' model_name '_and_or.mat'];
if exist(search_filename,'file')
    load(search_filename);
else
    pos_rxns_or_and = find(rxns_or_and);
    [models_or_and, rxnNumGenes_or_and] = GPR2models(model, pos_rxns_or_and, separate_isoform, numWorkers, printLevel);
    save(search_filename, 'models_or_and', 'rxnNumGenes_or_and');
end

search_filename_2 = [tmpFolderName filesep 'rxn_level_gMCSs' filesep 'rxn_level_gMCSs_' model_name '.mat'];
if exist(search_filename_2,'file')
    load(search_filename_2);
else
    target_b = 1e-3;
    n_mcs = 100000000000;
    timelimit = 5*60;
    pos_rxns_or_and = find(rxns_or_and);
    if printLevel >=1
        disp('G MATRIX - STEP 4');
        showprogress(0);
    end
    for i = 1:n_rxns_or_and
        if printLevel >=1
%             disp([num2str(i),' of ', num2str(n_rxns_or_and)]);
            showprogress(i/n_rxns_or_and);
        end
        search_filename_3 = [tmpFolderName filesep 'rxn_level_gMCSs_by_rxn' filesep 'rxn_level_gMCSs_' model_name '_rxn' num2str(pos_rxns_or_and(i)) '.mat'];
        if exist(search_filename_3,'file')
            load(search_filename_3);
            mcs{i, 1} = act_mcs;
        else
            act_model = models_or_and{i};
            nbio = find(act_model.c);
            rxns = act_model.rxns;
            tmp = repmat({'DM_'}, length(rxns), 1);
            DM = cellfun(@strfind, rxns, tmp, 'UniformOutput', false);
            DM = ~cellfun(@isempty, DM);
            n_DM = sum(DM);
            DM = rxns(find(DM));
%             options.rxn_set = DM;
% %             options.timelimit = timelimit;
%             options.target_b = target_b;
%             options.printLevel = 0;
            max_len_mcs = length(DM);
            [act_mcs, act_mcs_time] = calculateMCS(act_model, n_mcs, max_len_mcs,...
                'rxn_set', DM,...
                'timelimit', timelimit,... 
                'target_b', target_b,...
                'printLevel', 0);
            mcs{i, 1} = act_mcs;
            mcs_time{i, 1} = act_mcs_time;
            save(search_filename_3, 'act_mcs', 'act_mcs_time');
        end
    end
    save(search_filename_2);
end

k = 0;
for i = 1:n_rxns_or_and
    load([tmpFolderName filesep 'rxn_level_gMCSs_by_rxn' filesep 'rxn_level_gMCSs_' model_name '_rxn' num2str(pos_rxns_or_and(i)) '.mat']);
    n_act_mcs = length(act_mcs);

    for j = 1:n_act_mcs
        act_G_ind = act_mcs{j};
        if ~iscell(act_G_ind) && isnan(act_G_ind)
        else
            act_G_ind = cellfun(@strrep, act_G_ind, repmat({'DM_'}, length(act_G_ind), 1), repmat({''}, length(act_G_ind), 1), 'UniformOutput', false);
            act_G_ind = cellfun(@strtok, act_G_ind, repmat({separate_isoform}, length(act_G_ind), 1), 'UniformOutput', false);
            k = k+1;
            G_4(k, :) = zeros(1, n_rxns);
            G_4(k, pos_rxns_or_and(i)) = 1;
            G_ind_4{k, 1} = act_G_ind';
        end
    end
end
G_time(4, 1) = toc(time_e);

% Delete isoforms in order to work at the gene level
time_f = tic;
G_ind_1 = cellfun(@strtok, G_ind_1, repmat({separate_isoform}, length(G_ind_1), 1), 'UniformOutput', false);

n_KO_2 = length(G_ind_2);
for i = 1:n_KO_2
    act_G_ind_2 = G_ind_2{i};
    act_G_ind_2 = cellfun(@strtok, act_G_ind_2, repmat({separate_isoform}, 1, length(act_G_ind_2)), 'UniformOutput', false);
    G_ind_2{i} = unique(act_G_ind_2);
end
G_ind_3 = cellfun(@strtok, G_ind_3, repmat({separate_isoform}, length(G_ind_3), 1), 'UniformOutput', false);

% Delete repeats
if printLevel >=1
    disp('G MATRIX - Delete Repeats');
end
tmp_G = [];
try tmp_G = [tmp_G; G_1]; end
try tmp_G = [tmp_G; G_2]; end
try tmp_G = [tmp_G; G_3]; end
try tmp_G = [tmp_G; G_4]; end
tmp_G_ind = [];
try tmp_G_ind = [tmp_G_ind; G_ind_1]; end
try tmp_G_ind = [tmp_G_ind; G_ind_2]; end
try tmp_G_ind = [tmp_G_ind; G_ind_3]; end
try tmp_G_ind = [tmp_G_ind; G_ind_4]; end
n_tmp_G_ind = length(tmp_G_ind);

k = 0;
clear G G_ind
for i = 1:n_tmp_G_ind
    if i == 1
        k = k+1;
        G(k, :) = tmp_G(i, :);
        if ~iscell(tmp_G_ind{i})
            G_ind{k, 1} = tmp_G_ind(i);
        else
            G_ind{k, 1} = sort(tmp_G_ind{i});
        end
    else
        if ~iscell(tmp_G_ind{i})
            act_G_ind = tmp_G_ind(i);
        else
            act_G_ind = sort(tmp_G_ind{i});
        end

        pos_equal = cellfun(@isequal, G_ind, repmat({act_G_ind}, length(G_ind), 1));
        if sum(pos_equal) > 0
            G(pos_equal, :) = G(pos_equal, :) + tmp_G(i, :);
        else
            k = k+1;
            G(k, :) = tmp_G(i, :);
            G_ind{k, 1} = act_G_ind;
        end
    end
end

% Fill the G matrix with reactions which are knocked out by a given KO
% without being a gMCS
n_genes_KO = cellfun(@length, G_ind);
[n_genes_KO, ind] = sort(n_genes_KO, 'ascend');
G_ind = G_ind(ind);
G = G(ind, :);
n_G_ind = length(G_ind);
for i = 1:n_G_ind
    act_G_ind = G_ind{i};
    n_act_G_ind = length(act_G_ind);
    pos = find(n_genes_KO > n_act_G_ind);
    greater_G_ind = G_ind(pos);
    n_greater_G_ind = length(pos);
    for j = 1:n_greater_G_ind
        if sum(ismember(G_ind{pos(j)}, act_G_ind)) == n_act_G_ind
            G(pos(j), :) = G(pos(j), :) + G(i, :);
        end
    end
end
G = double(G>0);

% Check the interconnections between KOs
if printLevel >=1
    disp('G MATRIX - Check Relations');
end
k = 0;
n_genes_KO = cellfun(@length, G_ind);
for i = 2:n_G_ind
    act_G_ind = G_ind(i);
    n_act_G_ind = length(act_G_ind{:});
    pos = find(n_genes_KO < n_act_G_ind);
    if ~isempty(pos)
        pos = pos(end);
        for j = 1:pos
            act_G_ind_2 = G_ind(j);
            tmp = ismember(act_G_ind{:}, act_G_ind_2{:});
            n_act_G_ind_2 = length(act_G_ind_2{:});
            if sum(tmp) == n_act_G_ind_2
                k = k+1;
                related(k, 1) = i;
                related(k, 2) = j;
            end
        end
    end
end

if exist('related')
    un_related = unique(related(:, 1));
    n_un_related = length(un_related);
    for i = 1:n_un_related
        act_KO = un_related(i);
        ind = find(related(:, 1) == act_KO);
        act_related = related(ind, 2);
        all_genes = [G_ind{act_related}];
        un_all_genes = unique(all_genes);
        n_un_all_genes = length(un_all_genes);
        n_genes_KO(act_KO) = n_genes_KO(act_KO)-n_un_all_genes;
    end
else
    related = NaN;
end

final_filename = [pwd filesep 'G_' model_name '.mat'];
G_time(5, 1) = toc(time_f)+ini_time;
save(final_filename, 'G', 'G_ind', 'related', 'n_genes_KO', 'G_time');
if printLevel >=1
    disp('The G Matrix has been successfully calculated');
end
rmdir(tmpFolderName, 's');
end
