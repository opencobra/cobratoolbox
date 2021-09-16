function [networks, rxnNumGenes] = GPR2models(metabolic_model, selected_rxns, separate_transcript, numWorkers, printLevel)
% Each GPR rule is converted into a network where the reaction and genes
% involved are interconnected.
%
% USAGE:
%
%    [networks, rxnNumGenes] = GPR2models(metabolic_model, selected_rxns, separate_transcript, numWorkers, printLevel)
%
% INPUTS:
%    metabolic_model:        Metabolic model structure (COBRA Toolbox format)
%    selected_rxns:          Index array which indicates selected reactions to
%                            calculate the network.
%    separate_transcript:    Character used to discriminate
%                            different isoforms of a gene. Default ''.
%
% OPTIONAL INPUTS:
%    numWorkers:        Maximum number of workers
%                       * 0 - maximum provided by the system (automatic)
%                       (default). If parallel pool is active, numWorkers
%                       is defined by the system, otherwise is 1.
%                       * 1 - sequential
%                       * 2+ - parallel
%    printLevel:        show the reactions created in models.
%                       * 0 - shows nothing
%                       * 1 - shows progress by reactions (default)
%                       * 2+ - shows everything (reaction and network generation)
%
% OUTPUT:
%    networks:          Cell array which contains all the networks.
%    rxnNumGenes:       Array with the number of genes present in each GPR
%                       rule for each reaction.
%
% .. Authors:
%       - Inigo Apaolaza, Aug 2017, University of Navarra, TECNUN School of Engineering.
%       - Luis V. Valcarcel, Aug 2017, University of Navarra, TECNUN School of Engineering.
%       - Francisco J. Planes, Aug 2017, University of Navarra, TECNUN School of Engineering.
%       - Inigo Apaolaza, April 2018, University of Navarra, TECNUN School of Engineering.


p = inputParser;
% check required arguments
addRequired(p, 'metabolic_model');
addOptional(p, 'selected_rxns', [], @isnumeric);
addOptional(p, 'separate_transcript', '', @(x)ischar(x)); % default is empty
addOptional(p, 'numWorkers', 0, @(x)isnumeric(x)&&isscalar(x)); % Default is gpc('nocreate')
addOptional(p, 'printLevel', 1, @(x)isnumeric(x)&&isscalar(x));
% extract variables from parser
parse(p, metabolic_model, selected_rxns, separate_transcript, numWorkers, printLevel);
metabolic_model = p.Results.metabolic_model;
selected_rxns = p.Results.selected_rxns;
separate_transcript = p.Results.separate_transcript;
numWorkers = p.Results.numWorkers;
printLevel = p.Results.printLevel;

% fill with all reactions
if (isempty(selected_rxns))
    selected_rxns = 1:length(metabolic_model.rxns);
end

% Step 1: check the fields of the input metabolic model
if ~isfield(metabolic_model,'genes')
    error('The genes of the model are not defined');
end
if ~isfield(metabolic_model,'rxns')
    error('The reactions of the model are not defined');
end
if ~isfield(metabolic_model,'grRules') || ~isfield(metabolic_model,'rules') ||~isfield(metabolic_model,'rxnGeneMat')
    error('The GPR rules of the model are not defined');
end

%rxnGeneMat is a required field for this function, so if it does not exist,
%build it.
if ~isfield(metabolic_model,'rxnGeneMat')
    metabolic_model = buildRxnGeneMat(metabolic_model);
end

% Generate a cell array to store the resulting models
networks = cell(size(selected_rxns));

% Examine if there is an existing pool
p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
    poolsize = 0;               % Single core
elseif numWorkers == 0
    poolsize = p.NumWorkers;    % Multi core, all cores in the PC
elseif numWorkers == 1
    poolsize = 0;               % Single core
else
    p = parpool(numWorkers);
    poolsize = p.NumWorkers;    % Multi core, limited by user
end

% Step 2: Create models
if printLevel > 0 && length(selected_rxns)>1
    disp('Calculating Networks for GPR rules...');
end
parfor (i=1:length(selected_rxns),poolsize)
    if printLevel > 0
%         clc
        disp([num2str(i),' of ', num2str(length(selected_rxns)) ,' rxns']);
    end
    RXN = metabolic_model.rxns{selected_rxns(i)};
    % Create empty model
    model = createModel();
    % include metabolic reaction as objective metabolite
    model.mets{1} = RXN;
    % Add objective function
    model.rxns{1} = RXN;
    model.S(1,1) = -1;

    % Check if there is any gene related to this reaction and add them
    genes = metabolic_model.genes(metabolic_model.rxnGeneMat(selected_rxns(i),:)>0);
    if length(genes)>1
        model.mets = vertcat(RXN, genes); % Include genes in the model
%         model = addMetabolite(model,genes);
        model.genes = genes;
        fp = FormulaParser();
        head = fp.parseFormula(metabolic_model.rules{selected_rxns(i)});
        model = modelParser(model,metabolic_model.genes,head,[RXN,'_N_1'],RXN, printLevel);
        model = reduceModel(model);
    elseif length(genes)==1
        model.mets = vertcat(RXN, genes); % Include genes in the model
        model.genes = genes;
        model.rxns(2) = genes;
        model.S(1:2,2) = [+1 -1];
    else
        model.rxns{2} = 'NO_GENES';
        model.S(1,1:2) = [-1 +1];
    end

    % Include Exchange reactions
    [~, gene_idx] = ismember(genes, model.mets);
    demand_idx = (1:length(genes)) + length(model.rxns);
    % compulsitory fields
    model.rxns(demand_idx) = strcat('DM_',genes);
    model.rxns = model.rxns';
    model.S(gene_idx,demand_idx) = eye(length(genes));

    % converge isoforms (if neccesary)
    if ~isempty(separate_transcript) && length(genes)>1
        model = convergeTranscripts2Gene(model, separate_transcript);
    end

    % Generate rest of fields
    idx_rxns = (1:length(model.rxns))';
    idx_mets = (1:length(model.mets))';
    model.b(idx_mets) = 0;
    model.csense(idx_mets) = 'E';
    model.c(idx_rxns) = 0;
    model.c(1) = 1;
    model.lb(idx_rxns) = 0;
    model.ub(idx_rxns) = inf;
    model.ub(1) = 1000;
    model.rules(demand_idx) = {''};
    model.b = model.b';
    model.c = model.c';
    model.lb = model.lb';
    model.ub = model.ub';
    model.rules = model.rules';

    % Store the model
    networks{i} = model;
end

% Calculate the number of genes per GPR rule
rxnNumGenes = zeros(size(selected_rxns));
for i = 1:length(selected_rxns)
    rxn = selected_rxns(i);
    idx_genes = find(metabolic_model.rxnGeneMat(rxn,:));
    rxn_isoforms = metabolic_model.genes(idx_genes);
    rxn_genes = unique(strtok(rxn_isoforms,separate_transcript));
    rxnNumGenes(i) = length(rxn_genes);
end

end


function model = modelParser(model,genes,head,node_parent,parent,printLevel)
% This function look into the GPRparser and builds auxiliary nodes for each
% layer of the GPR rules.
% For example:
%     g1 & g2 & g3 is one layer in the model,   RXN = g1 + g2 + g3
%     (g1 | g2) & g3 is a two layer model:      RXN = (g1 | g2) + g3
%                                               (g1 | g2) = g1
%                                               (g1 | g2) = g2



%  Name nodes according to position and layer inside the GPR rule
node = strcat({[node_parent,'_']},cellfun(@num2str,num2cell(1:length(head.children)),'UniformOutput', false));

% model = addMetabolite(model, node);
model.mets = vertcat(model.mets,node');
[~, idx_new_mets] = ismember(node, model.mets);

idx_parent_mets = find(strcmp(parent, model.mets));

%  Expand model with every node, using OR/AND rules
if isa(head,'OrNode')
    idx_new_rxn = length(model.rxns) + (1:length(head.children));
    model.rxns(idx_new_rxn) = node;
    model.S(idx_new_mets,idx_new_rxn) = -eye(length(head.children));
    model.S(idx_parent_mets,idx_new_rxn) = +1;
else
    idx_new_rxn = length(model.rxns)+1;
    model.rxns{idx_new_rxn} = ['AND_' parent];
    model.S(idx_new_mets,idx_new_rxn) = -1;
    model.S(idx_parent_mets,idx_new_rxn) = +1;
end


for i=1:length(head.children)
    child = head.children(i);
    % check if the child is final layer
    if isa(child,'LiteralNode')
        gen = genes(str2double(child.id));
        idx_new_rxn = length(model.rxns)+1;
        idx_met_gen = strcmp(gen,model.mets);
        idx_met_node = strcmp(node(i),model.mets);
        model.rxns{idx_new_rxn} = [gen{1},'_',node{i}];
        model.S(idx_met_node,idx_new_rxn) = +1;
        model.S(idx_met_gen,idx_new_rxn) = -1;
    else
        model = modelParser(model,genes,child,node{i},node{i},printLevel);
    end
end

end

function modelOut = reduceModel(model)
% As the algorithm generates redundant nodes, this function is used to
% remove these nodes:
% Ej:       gen -> node -> rule  == gen -> rule

% This is done for every gene of the model
genes = model.genes;
for gen=1:length(genes)
    gen_idx = strcmp(model.mets,genes{gen}); % find idx of gene
    rxn_gen_out = find(model.S(gen_idx,:)<0);   % find reactions that consume gene
    % for each reaction, find consumption node
    [node_idx,~] = find(model.S(:,rxn_gen_out)>0);
    for i = 1:length(node_idx)
        % for each reaction, find consumption node
        node_name = model.mets(node_idx(i));
        % find reactions out of this node
        [~, rxn_idx] = find((model.S(node_idx(i),:)<0));
        rxn_name = model.rxns(rxn_idx);
        % in this reaction, change (node -> rule) for (gene -> rule)
        model = changeRxnMets(model, node_name, genes(gen), rxn_name);
    end
    % remove stoichimetri of intermediate nodes
    model.S(node_idx,:)=0;
    % remove output of genes to intermediate nodes
    model.S(:,rxn_gen_out)=0;
end

% remove unused reactions and unused metabolites
idx_rxns = sum(model.S~=0,1)>0;
idx_mets = sum(model.S~=0,2)>0;
modelOut.S = model.S(idx_mets,idx_rxns);
modelOut.rxns = model.rxns(idx_rxns);
modelOut.mets = model.mets(idx_mets);

end


function model = convergeTranscripts2Gene(model, separate_transcripts)
% Some COBRA models have transcripts instead of genes. Most of the
% transcripts have the same functionallity, so we can converge them as the
% same gene.
% Ej:       gene 10005.1
%           gene 10005.2        ==>     gene 10005
%           gene 10005.3
%
% This is done for every gene of the model at exchange reaction level

% seach demand reactions
idx_DM_rxns = startsWith(model.rxns,'DM_');
DM_rxns = model.rxns(idx_DM_rxns);
% obtain isoforms and genes
transcripts = regexprep(DM_rxns,'DM_','');
genes = strtok(transcripts,separate_transcripts);

% Remove all the previously existing exchange reactions
model.S = model.S(:,~idx_DM_rxns);
model.rxns = model.rxns(~idx_DM_rxns);

% Divide into genes with one transcript and two or more transcripts
x = tabulate(genes);
genes_unique = x(:,1);
genes_one_transcrits = x(cell2mat(x(:,2))==1,1);
genes_more_transcripts = x(cell2mat(x(:,2))>1,1);

% For genes with one transcript, just change the name
[~,idx_genes_one_transcript] = ismember(genes_one_transcrits, strtok( model.mets,separate_transcripts));
model.mets(idx_genes_one_transcript) = genes_one_transcrits;

% For genes with more than one transcript, converge them into one
% metabolite
% Generate new metabolites
model = addMetabolite(model, genes_more_transcripts);
% Converge genes
for i = 1:length(genes_more_transcripts)
    gen_idx = find(strcmp(genes_more_transcripts{i}, model.mets));
    transcripts_idx = find(strcmp(genes_more_transcripts{i}, strtok( model.mets,separate_transcripts)));
    transcripts_idx = setdiff(transcripts_idx,gen_idx);
    % new reactions to converge genes
    idx_new_rxns = length(model.rxns)+1 : length(model.rxns) + length(transcripts_idx);
    model.S(transcripts_idx,idx_new_rxns) = +eye(length(transcripts_idx)); % produce transcript
    model.S(gen_idx,idx_new_rxns) = -1; % consume gene
    model.rxns(idx_new_rxns) = strcat('Con_',genes_more_transcripts{i},'_',model.mets(transcripts_idx));
end

% Generate new demand reactions for all genes
[~, gene_idx] = ismember(genes_unique, model.mets);
demand_idx = (1:length(genes_unique)) + length(model.rxns);
model.rxns(demand_idx) = strcat('DM_',genes_unique);
model.S(gene_idx,demand_idx) = eye(length(genes_unique));


end
