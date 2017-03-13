function gpraModel = readSimPhenyGprText(file,model)
%readSimPhenyGprText Parses SimPheny GPRA's in text format into a rxn x gene association
%matrix
%
% gpraModel = readSimPhenyGPRText(file,model)
%
%INPUTS
% file      GPR text file
% model     COBRA model structure
%
%OUTPUT
% gpraModel COBRA model structure with reaction-gene association matrix
% Markus Herrgard 2/23/06

% Read GPRA file
[tmp,tmp,rxnNames,rxnDesrs,rxnEqns,Confs,subSystems,Regions,gpraStrings,proteinStrings,ECs] = ...
    textread(file,'%s %s %s %s %s %s %s %s %s %s %s','delimiter','\t','headerlines',1,'bufsize',200000);

sel = ~strcmp(rxnNames,'');
gpraStrings = gpraStrings(sel);
rxnNames = rxnNames(sel);
subSystems = subSystems(sel);

nRxns = length(rxnNames);
allGenes = {};
% Parse GPRA's
showprogress(0,'Reading GPRA text file ...');
for i = 1:nRxns
    if mod(i,10) == 0
        showprogress(i/nRxns);
    end
    thisGpra = gpraStrings{i};
    thisGpra = regexprep(thisGpra,'+',' and ');
    thisGpra = regexprep(thisGpra,',',' or ');
    [thisGenes,rule] = parseBoolean(thisGpra);
    genes{i} = thisGenes;
    allGenes = [allGenes thisGenes];
    rules{i} = rule;
    grRules{i} = thisGpra;
end

allGenes = unique(allGenes);

% Construct gene to rxn mapping
rxnGeneMat = sparse(nRxns,length(allGenes));
showprogress(0,'Constructing GPR mapping ...');
for i = 1:nRxns
    if mod(i,10) == 0
        showprogress(i/nRxns);
    end
    [tmp,geneInd] = ismember(genes{i},allGenes);
    rxnGeneMat(i,geneInd) = 1;
    for j = 1:length(geneInd)
        rules{i} = strrep(rules{i},['x(' num2str(j) ')'],['x(' num2str(geneInd(j)) ')']);
    end
end

gpraModel.rxns = rxnNames;
gpraModel.genes = columnVector(allGenes);
gpraModel.rules = columnVector(rules);
gpraModel.grRules = grRules;
gpraModel.subSystems = subSystems;
gpraModel.rxnGeneMat = rxnGeneMat;

if (nargin > 1)
    [hasGpra,gpraMap] = ismember(model.rxns,gpraModel.rxns);
    model.genes = columnVector(gpraModel.genes);
    nRxns = length(model.rxns);
    nGenes = length(gpraModel.genes);
    model.rxnGeneMat = sparse(nRxns,nGenes);
    for i = 1:length(model.rxns)
       if (hasGpra(i))
          gpraID = gpraMap(i);
          model.rules{i} = gpraModel.rules{gpraID};
          model.rxnGeneMat(i,:) = gpraModel.rxnGeneMat(gpraID,:);
          model.subSystems{i} = gpraModel.subSystems{gpraID};
          model.grRules{i} = gpraModel.grRules{gpraID};
       else
          model.rules{i} = '';
          model.subSystems{i} = '';
          model.grRules{i} = '';
       end
    end
    model.rules = columnVector(model.rules);
    model.subSystems = columnVector(model.subSystems);
    model.grRules = columnVector(model.grRules);
    gpraModel = model;
end

%     geneString = geneStrings{i};
%     geneList = {};
%     if (~strcmp(geneString,''))
%         if (~isempty(regexp(geneString,',')))
%             if (~isempty(regexp(geneString,'+')))
%                 % Both complexes and isozymes
%                 geneStrTmp = splitString(geneString,',');
%                 for j = 1:length(geneStrTmp)
%                     if (~isempty(regexp(geneStrTmp{j},'+')))
%                         geneListTmp = splitString(geneStrTmp{j},'+');
%                         for k = 1:length(geneListTmp)
%                             geneList{end+1} = geneListTmp{k};
%                         end
%                     else
%                         geneList{end+1} = geneStrTmp{j};
%                     end
%                 end
%             else
%                 % Only isozymes
%                 geneList = splitString(geneString,',');
%             end
%         elseif (~isempty(regexp(geneString,'+')))
%             % Only complexes
%             geneList = splitString(geneString,'+');
%         else
%             % Just a single gene
%             geneList{1} = geneString;
%         end
%     end
%     for j = 1:length(geneList)
%         geneList{j} = regexprep(geneList{j},' ','');
%     end
%     geneLists{i} = unique(geneList);
%     allGenes = union(allGenes,geneList);
% end
%
% % Create rxn to gene association matrix
% rxnGeneMat = sparse(length(rxnNames),length(allGenes));
% for i = 1:length(rxnNames)
%     [tmp,geneInd] = ismember(geneLists{i},allGenes);
%     rxnGeneMat(i,geneInd) = 1;
% end
%
% genes = allGenes';
