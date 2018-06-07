function [geneSubSystems,singleList] = findSubSystemsFromGenes(model,genes, varargin)
% Returns the subsystems associated with the provided genes. 
%
% USAGE:
%
%    [geneSubSystems,singleList] = findSubSystemsFromGenes(model,genes,...)
%
% INPUT:
%    model:            COBRA model structure
%
% OPTIONAL INPUTS:
%    genes:            The genes to find subSystems for 
%                      (Default: model.genes)
%    varargin:         Optional arguments as parameter/value pairs, or parameter struct.
%                       * structResult - return individual Gene Associations as a struct instead of a Cell Array with each gene represented by a field. Gene names might be adapted to fit to field names and all genes will be prefixed with gene_.
%                       * onlyOneSub - Only return one subSystem for each gene.
%                                 
%
% OUTPUT:
%    geneSubSystems:    All subsystems associated with the provided genes.
%
% OPTIONAL OUTPUT:
%    singleList:       A Cell array of size(nGenes,2), with the first column 
%                      representing the gene and the second column
%                      containing the subSystems associated with the gene.
%
% .. Author: - Thomas Pfau 2018

parser = inputParser();
parser.addParamValue('structResult',0,@(x) islogical(x) || isnumeric(x) && (x==1 || x==0));
parser.addParamValue('onlyOneSub',0,@(x) islogical(x) || isnumeric(x) && (x==1 || x==0));

if mod(numel(varargin),2) == 1
    parser.parse(genes,varargin{:});
    genes = model.genes;
else
    parser.parse(varargin{:});
end

if ~exist('genes','var') || isempty(genes)
    genes = model.genes;
end

userxnGeneMat = true;
useRules = false;
%rxnGeneMat is a required field for this function, so if it does not exist,
%build it.
if ~isfield(model,'rxnGeneMat')
    userxnGeneMat = false;
    if isfield(model,'rules')
        useRules = true;
    else
        if ~isfield(model,'grRules')            
            error('No fields to determine Gene - Reaction associations (rxnGeneMat, rules, grRules) found in the model!');
        end
    end
end



%Get the gene positions
genePres = ismember(model.genes,genes);
[oGenePres,oGenePos] = ismember(genes,model.genes(genePres));

if userxnGeneMat
    relAssocs = model.rxnGeneMat(:,genePres);
elseif useRules
    relAssocs = cell2mat(arrayfun(@(y) cellfun(@(x) ~isempty(x), strfind(model.rules,['x(' num2str(y) ')']))',find(genePres),'Uniform',0))';    
else
    relAssocs = cell2mat(cellfun(@(y) cellfun(@(x) ~isempty(x), regexp(model.grRules,['^|[ \(]' regexptranslate y '$|[ \)]']))',model.genes(genePres),'Uniform',0))';    
end
allSubs = model.subSystems(any(relAssocs==1,2));
geneSubSystems = unique([allSubs{:}]);
if parser.Results.onlyOneSub
    cellList = [model.genes(genePres),arrayfun(@(x) model.subSystems{find(relAssocs(:,x),1)},(1:size(relAssocs,2))','Uniform',false)];        
else    
    cellList = [model.genes(genePres),arrayfun(@(x) unique([model.subSystems{relAssocs(:,x) == 1}]),(1:size(relAssocs,2))','Uniform',false)];
end
%Now, adapt the cellList to report on all provided genes (even those not in
%the model.
cellList = cellList(oGenePos(oGenePres),:);
if sum(genePres) ~= numel(genes) %Only do this, if there are actually additional genes
   oGenePres = ismember(genes,cellList(:,1));
   newCellList = cell(length(oGenePres),2);
   newCellList(oGenePres,:) = cellList;
   newCellList(~oGenePres,1) = genes(~oGenePres);
   cellList = newCellList;
end
if parser.Results.structResult    
    cellList(:,1) = strcat('gene_',regexprep(cellList(:,1),'[^a-zA-Z0-9]','_'));    
    singleList = struct();    
    for i = 1:size(cellList,1)
        singleList.(cellList{i,1}) = cellList{i,2};
    end
else
    singleList = cellList;
end
 

    




