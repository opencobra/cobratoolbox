function validJunctionMets = findMetabolicJunctions(model,nRxnsJnc)
%findMetabolicJunctions Find metabolic branchpoints with different numbers
%of branches
%
% validJunctionMets = findMetabolicJunctions(model,nRxnsJnc)
%
%INPUTS
% model                 COBRA model structure
% nRxnJnc               Number of reactions to be considered a junction
%
%OUTPUT
% validJunctionMets     List of junction metabolites
%
% Markus Herrgard 12/14/06

if (isfield(model,'c'))
    selRxnsC = (model.c == 0);
else
    selRxnsC = true(length(model.rxns),1);
end

[baseMetNames,compSymbols,uniqueMetNames,uniqueCompSymbols] = parseMetNames(model.mets);
uniqueMetNames = uniqueMetNames';
for i = 1:length(uniqueMetNames)
    sel = ismember(baseMetNames,uniqueMetNames{i});
    nRxnsMetUni(i) = sum(any(model.S(sel,selRxnsC) ~= 0,1));
end
nRxnsMetUni = full(nRxnsMetUni');
junctionMets = uniqueMetNames(nRxnsMetUni >= nRxnsJnc);

validJunctionMets = {};
for i = 1:length(junctionMets)
    sel = ismember(baseMetNames,junctionMets{i});
    if (length(unique(compSymbols(sel))) == 1)
        selRxns = any(model.S(sel,:) ~= 0,1) & selRxnsC';
        thisRxns = model.rxns(selRxns);
        geneMap = model.rxnGeneMat(findRxnIDs(model,thisRxns),:);
        selNonZero = any(geneMap,2);
        if (sum(selNonZero) == nRxnsJnc & ...
            size(unique(geneMap(selNonZero,:),'rows'),1) == nRxnsJnc)
            validJunctionMets{end+1} = junctionMets{i};
            if (verbFlag)
                fprintf('*** %s ***\n',junctionMets{i});
                for j = 1:length(thisRxns)
                    %fprintf('%s\t',thisRxns{j});
                    geneInd = find(model.rxnGeneMat(findRxnIDs(model,thisRxns{j}),:));
                    if (~isempty(geneInd))
                        thisGenes = model.genes(geneInd);
                        for k = 1:length(thisGenes)
                            fprintf('%s ',thisGenes{k});
                        end
                    end
                    fprintf('\n');
                end
            end
        end
    end
end

validJunctionMets = validJunctionMets';
for i = 1:length(validJunctionMets)
    validJunctionMets{i} = [validJunctionMets{i} '(c)'];
end