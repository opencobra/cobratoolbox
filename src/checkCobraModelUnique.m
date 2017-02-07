function model = checkCobraModelUnique(model,renameFlag)
%checkCobraModelUnique Check uniqueness of reaction and metabolite names
%
% model = checkCobraModelUnique(model,renameFlag)
%
%INPUT
% model         COBRA model structure
%
%OPTIONAL INPUT
% renameFlag    Renames non-unique reaction names and metabolites
%               (Default = false)
%
%OUTPUT
% model         COBRA model structure
%
% Markus Herrgard 10/17/07
% Stefania Magnusdottir 07/02/17    Replace use of findRxnIDs and
%                                   findMetIDs, both only return one index
%                                   even if more are found in model.

if nargin < 2
    renameFlag = false;
end

[rxnName, rxnCnt] = countUnique(model.rxns);
rxnInd = find(rxnCnt > 1);
if ~isempty(rxnInd)
    fprintf('Model contains non-unique reaction names - consider renaming reactions using checkCobraModelUnique\n');
    for i = 1:length(rxnInd)
        thisRxnName = rxnName{rxnInd(i)};
        fprintf('%s\t%d\n', thisRxnName, rxnCnt(rxnInd(i)));
        if renameFlag
            fprintf('Renaming non-unique reactions\n');
            rxnIDs = find(ismember(model.rxns, thisRxnName));
            for j = 1:length(rxnIDs)
                model.rxns{rxnIDs(j)} = [thisRxnName '_' num2str(j)];
                fprintf('%s\n', model.rxns{rxnIDs(j)});
            end
        end
    end
end

[metName, metCnt] = countUnique(model.mets);
metInd = find(metCnt > 1);
if ~isempty(metInd)
    fprintf('Model contains non-unique metabolite names - consider renaming metabolites using checkCobraModelUnique\n');
    for i = 1:length(metInd)
        thisMetName = metName{metInd(i)};
        fprintf('%s\n', thisMetName);
        if renameFlag
            fprintf('Renaming non-unique metabolites\n');
            metIDs = find(ismember(model.mets, thisMetName));
            for j = 1:length(metIDs)
                model.mets{metIDs(j)} = [thisMetName '_' num2str(j)];
                fprintf('%s\n', model.mets{metIDs(j)});
            end
        end
    end
end
