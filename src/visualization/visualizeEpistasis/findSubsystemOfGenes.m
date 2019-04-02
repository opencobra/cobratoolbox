function [rxns, subsys, subsysGenes, uSys, Nr, rxnNames] = findSubsystemOfGenes(model, genes)
% This function is used to find out which genes belong to which subsystem
%
% USAGE:
%
%     [rxns,subsys,subsysGenes,uSys,Nr,rxnNames]=findSubsystemOfGenes(model,genes)
%
% INPUT:
%     model:    model to which genes belong to
%     genes:    genes in question, if not provided will do it for all
%               the genes, default: model.genes
%
% OUTPUT:
%     rxns:         Reactions governed by these genes
%     subsys:       subsystem(s) to which the gene belongs to
%     subsysGenes:  which Genes are involved in each subsystem, subsystem
%                   name given by the cell array, usys
%     uSys:         unique subsystems
%
% NOTE:
%    See figures in following publication:
%    Joshi CJ and Prasad A, 2014, "Epistatic interactions among metabolic genes
%    depend upon environmental conditions", Mol. BioSyst., 10, 2578-2589.
%
% .. Authors:
%      - Chintan Joshi 10/26/2018

if (nargin < 2)
    genes = model.genes;
end

for i = 1:length(genes)
    % find the reactions that were constrained by this gene
    [cRxns, iRxns] = findRxnsConstrained(model, genes(i, 1), false);
    rxns{i, 1} = iRxns{1, 1};
    rxnNames{i, 1} = model.rxnNames(ismember(model.rxns, iRxns{1, 1}));
    for j = 1:length(rxns{i, 1})
        rxnInds = find(strcmp(rxns{i, 1}{j, 1}, model.rxns) == 1);  % find the index of each of the reactions involved
    end
%     if ~isempty(rxnInds)
    subs{i, 1} = model.subSystems{rxnInds, 1};  % finds the subsytem of the reaction
%     end
%     rxnInds=[];
    if length(unique(subs{i, 1})) == 1  % checks if all the reactions belong to the same compartment
        subsys{i, 1} = unique(subs{i, 1});  % if they do, stores them under one string
    else
        subsys{i, 1} = subs(i, 1);  % else, stores them as a second-ordered cell string
    end
end

uSys = unique(convertMyCell2List(subsys, 2));
for i = 1:length(uSys)
    c = 0;
    geneIdx = 0;
    for j = 1:length(subsys)
        indc = find(strcmp(uSys{i, :}, subsys{j, 1}) == 1);
        if (~isempty(indc))
            c = c + 1;
            geneIdx(c, 1) = j;
        end
    end
    subsysGenes{i, 1} = genes(geneIdx, 1);
end
for i = 1:length(subsysGenes)
Nr(i, 1) = length(subsysGenes{i, 1});
end
% Nrp=Nr/sum(Nr); % if wanting to normalize or get frequency insteady.
[Nr, ind] = sort(Nr, 'ascend');
uComp4plot = uSys(ind);
barh(Nr);
set(gca, 'YAxisLocation', 'Right');
set(gca, 'YTickLabelMode', 'auto');
set(gca, 'YTickMode', 'auto');
set(gca, 'YTick', 1:1:length(Nr));
set(gca, 'YTickLabel', uComp4plot);

function B = convertMyCell2List(A, dimSense)

% This function linearizes a cell array if some of the cells in the array are another embbedded cell arrays.
% (hence, two degrees of cell array)

% This will only work for atmost two degrees of cell array.

% A=cell array to be linearized.
% dimSense=determines if inner cells are row (dimSense=1) vectors or columns (dimSense=2, default)

cnt = 0;
if nargin < 2
    dimSense = 2;
end
for i = 1:length(A)
    for j = 1:length(A{i, 1})
        cnt = cnt + 1;
        if dimSense == 1
            B{cnt, 1} = A{i, 1}{1, j};
        elseif dimSense == 2
            B{cnt, 1} = A{i, 1}{j, 1};
        end
    end
end

function [constrRxns, invRxns, rxns] = findRxnsConstrained(model, genes, verbFlag)
%[constrRxns,invRxns]=findRxnsConstrained(model,genes)
% This function was written to find out all the reactions that are
% catalyzed due to expression of the genes and all  the reactions that are
% constrained due to deletion of these genes
%
% INPUT:
% model:    model in question
% genes (optional): genes in questions, all the genes in model (default)
% verbFlag (optional):  verbose output to be printed, true (default)
% OUTPUT:
% constrRxns:   reactions constrained
% invRxns:      reactions catalyzed due to expression of this gene
% rxns:         numbers of reactions involved (inv) or constrained (constr)
%
if (nargin < 2)
    genes = model.genes;
end
if (nargin < 3)
    verbFlag = true;
end
constrRxns = cell(length(genes), 1);
invRxns = cell(length(genes), 1);
for i = 1:length(genes)
    geneInd = find(strcmp(genes(i, 1), model.genes) == 1);
    [~, ~, cRxns, ~] = deleteModelGenes(model, genes{i, 1});
    constrRxns{i, 1} = cRxns;
    rMatInd = find(full(model.rxnGeneMat(:, geneInd)) ~= 0);
    invRxns{i, 1} = model.rxns(rMatInd, 1);
    if verbFlag == true
        disp(sprintf('\n reactions catalyzed by %s:', genes{i, :}));
        printRxnFormula(model, invRxns{i, :});
        if isempty(cRxns)
            disp(sprintf('no reactions are constrained due to deletion of %s!!', genes{i, :}));
        else
            disp(sprintf('reactions constrained due to deletion of %s:', genes{i, :}));
            disp(constrRxns{i, 1});
        end
    end
end

for i = 1:length(invRxns)
    rxns.inv(i, 1) = length(invRxns{i, 1});
    rxns.constr(i, 1) = length(constrRxns{i, 1});
end
