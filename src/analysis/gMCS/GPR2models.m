function [networks, rxnNumGenes] = GPR2models(metabolic_model, selected_rxns, separate_transcript, printLevel)
% Each GPR rule is converted into a network where the reaction and genes
% involved are interconnected.
%
% USAGE:
%
%    [networks, rxnNumGenes] = GPR2models(metabolic_model, selected_rxns, separate_transcript, printLevel)
%
% INPUTS:
%    metabolic_model:        Metabolic model structure (COBRA Toolbox format)
%    selected_rxns:          Index array which indicates selected reactions to
%                            calculate the network.
%    separate_transcript:    Character used to discriminate
%                            different isoforms of a gene. Default ''.
%
% OPTIONAL INPUTS:
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
%       - Luis V. Valcarcel, Aug 2017, University of Navarra, TECNUN School of Engineering.
%       - Iñigo Apaolaza, Aug 2017, University of Navarra, TECNUN School of Engineering.
%       - Francisco J. Planes, Aug 2017, University of Navarra, TECNUN School of Engineering.

if (nargin < 4 || isempty(printLevel))
    printLevel = 1;
end

if (nargin < 3)
    separate_transcript = ''; % default is empty
end

if (nargin < 2)
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

% Generate a cell array to store the resulting models
networks = cell(size(selected_rxns));

% Examine if there is an existing pool
p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
    poolsize = 0;               % Single core
else
    poolsize = p.NumWorkers;    % Multi core
end

% Step 2: Create models
disp('Calculating Networks for GPR rules...');
% parfor (i=1:length(selected_rxns),poolsize)
for i=1:length(selected_rxns)
    if printLevel > 0
        clc
        disp([num2str(i),' of ', num2str(length(selected_rxns)) ,' rxns']);
    end
    RXN = metabolic_model.rxns{selected_rxns(i)};
    % Create empty model
    model = createModel();
    % include metabolic reaction as objective metabolite
    model = addMetabolite(model,RXN);

    % Check if there is any gene related to this reaction and add them
    genes = metabolic_model.genes(metabolic_model.rxnGeneMat(selected_rxns(i),:)>0);
    if length(genes)>1
        model = addMetabolite(model,genes); % Include genes in the model 
        model.genes = genes;
        fp = FormulaParser();
        head = fp.parseFormula(metabolic_model.rules{selected_rxns(i)});
        model = modelParser(model,metabolic_model.genes,head,'N_1',RXN, printLevel);
        model = reduceModel(model);
    elseif length(genes)==1
        model = addMetabolite(model,genes); % Include genes in the model
        model.genes = genes;
        model = addReaction(model,genes{1},...
            'metaboliteList',{genes{1},RXN},'stoichCoeffList',[-1, 1],...
            'printLevel',printLevel-1);
    else
        model = addReaction(model,'NO_GENES','reactionFormula',[' -> ',RXN],'printLevel',printLevel-1);
    end

    % Include Exchange reactions
    for gen = 1:length(genes)
        model = addReaction(model,['DM_',genes{gen}],...
            'metaboliteList',{genes{gen}},'stoichCoeffList',[1],...
            'reversible',false,'printLevel',printLevel-1,...
            'geneRule', genes{gen});
    end

    % converge isoforms (if neccesary)
    if ~isempty(separate_transcript) && length(genes)>1
        model = convergeTranscripts2Gene(model, separate_transcript, printLevel);
    end

    % Add objective function
    model = addReaction(model,RXN,'reactionFormula',[RXN,' -> '],...
        'printLevel',printLevel-1); % exchange reaction for objective metabolite
    % Define objective function
    model = changeObjective(model, RXN);

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
node = cell(size(head.children));
for child=1:length(head.children)
    node{child} = [node_parent,'_',num2str(child)];
end
model = addMetabolite(model, node);

%  Expand model with every node, using OR/AND rules
if strcmp(class(head),'OrNode')
    for child=1:length(head.children)
        model = addReaction(model,node{child},...
            'reactionFormula',[node{child},' -> ',parent],'printLevel',printLevel-1);
    end
else
    model = addReaction(model,strjoin(node,' & '),...
        'reactionFormula',[strjoin(node,' + '),' -> ',parent],'printLevel',printLevel-1);
end


for i=1:length(head.children)
    child = head.children(i);
    % check if the child is final layer
    if strcmp(class(child),'LiteralNode')
        gen = genes(str2num(child.id));
        model = addReaction(model,[gen{1},'_',node{i}],...
            'metaboliteList',{gen{1},node{i}},'stoichCoeffList',[-1, 1],...
            'printLevel',printLevel-1);
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
    gen_idx = find(strcmp(model.mets,genes{gen})); % find idx of gene
    rxn_gen_out = find(model.S(gen_idx,:)<0);   % find reactions that consume gene
    % for each reaction, find consumption node
    [node_idx,aux] = find(model.S(:,rxn_gen_out)>0);
    for i = 1:length(node_idx)
        % for each reaction, find consumption node
        node_name = model.mets(node_idx(i));
        % find reactions out of this node
        [aux, rxn_idx] = find((model.S(node_idx(i),:)<0));
        rxn_name = model.rxns(rxn_idx);
        % in this reaction, change (node -> rule) for (gene -> rule)
        model = changeRxnMets(model, node_name, genes(gen), rxn_name);   
    end
    % remove reactions (gene -> node)
%     model = removeRxns(model, model.rxns(rxn_gen_out), 'metFlag',false); 
    % remove stoichimetri of intermediate nodes
    model.S(node_idx,:)=0;
    % remove output of genes to intermediate nodes
    model.S(:,rxn_gen_out)=0;
end

% remove unused reactions and unused metabolites
modelOut = removeTrivialStoichiometry(model);    

end


function model = convergeTranscripts2Gene(model, separate_transcripts, printLevel)
% Some COBRA models have transcripts instead of genes. Most of the
% transcripts have the same functionallity, so we can converge them as the
% same gene.
% Ej:       gene 10005.1    
%           gene 10005.2        ==>     gene 10005 
%           gene 10005.3
% 
% This is done for every gene of the model at exchange reaction level

% seach demand reactions
DM_rxns = model.rxns(startsWith(model.rxns,'DM_'));
% obtain isoforms and genes
transcripts = regexprep(DM_rxns,'DM_','');
genes = strtok(transcripts,separate_transcripts);
[genes_unique,IA,IC] = unique(genes);

for i = 1:length(genes_unique)
    % look those genes with several isoforms
    if sum(strcmp(genes_unique(i),genes))>1
        idx_transcripts = IC==i;
        model = removeRxns(model,DM_rxns(idx_transcripts), 'metFlag', false);
        model = addReaction(model,['DM_',genes_unique{i}],...
            'metaboliteList',transcripts(idx_transcripts)','stoichCoeffList',...
            ones(size(transcripts(idx_transcripts)')),'reversible',false,...
            'printLevel',printLevel-1);
    end
end

end