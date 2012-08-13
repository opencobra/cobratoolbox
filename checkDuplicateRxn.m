function [model,removed] = checkDuplicateRxn(model,method)
%checkDuplicateRxn Checks model for duplicate reactions and removes them
%
% [model,removed] = checkDuplicateRxn(model,method)
%
%INPUTS
% model     Cobra model structure
% method    1 --> checks rxn abbreviations
%           2 --> checks rxn S matrix
%
%OUTPUTS
% model     Cobra model structure with duplicate reactions removed
% removed   reaction numbers that were removed
%
% Aarash Bordbar 02/11/08

[nMets,nRxns] = size(model.S);
cnt = 1;
switch method
    case 1
        h = waitbar(0, 'Checking by Abbreviation ...');
        i = 1;
        while i <= nRxns
            model2 = model;
            model2.rxns{i} = '';
            if isempty(strmatch(model.rxns(i),model2.rxns,'exact')) == 0
                matches = strmatch(model.rxns(i),model2.rxns,'exact');
                nRxns = nRxns - length(matches);
                model2 = removeRxns(model2,model.rxns(i));
                model2.rxns{i} = model.rxns{i};
                model = model2;
                removed(cnt,1) = i;
                cnt = cnt+1;
            end
            i = i+1;
            waitbar(i/nRxns,h);
        end
        close(h);
    case 2
        h = waitbar(0, 'Checking by reaction ...');
        for i = 1:nMets
            possibleMatches = find(model.S(i,:));
            for j = 1:length(possibleMatches)
                for k = 1:length(possibleMatches)
                    if model.S(:,possibleMatches(j)) == model.S(:,possibleMatches(k)) & strcmp(model.rxns(possibleMatches(j)),model.rxns(possibleMatches(k))) == 0
                        model = removeRxns(model,model.rxns(possibleMatches(k)));
                    elseif model.S(:,possibleMatches(j)) == model.S(:,possibleMatches(k)) & strcmp(model.rxns(possibleMatches(j)),model.rxns(possibleMatches(k))) == 1
                        model2 = model;
                        model2.rxns{possibleMatches(j)} = '';
                        model2 = removeRxns(model2,model.rxns(possibleMatches(j)));
                        model2.rxns{possibleMatches(j)} = model.rxns{possibleMatches(j)};
                        model = model2;
                    end
                end
            end
            waitbar(i/nMets,h);
        end
        close(h);
end