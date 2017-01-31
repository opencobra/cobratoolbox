function [model,removed, rxnRelationship] = checkDuplicateRxn(model,method)
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
% Uri David Akavia 20-Feb-2014

model = removeMetabolites(model, model.mets(all(model.S == 0,2)));
[nMets,nRxns] = size(model.S);
removed = cell(0); 
cnt = 0;
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
		[~, ia, ic] = unique(model.S', 'rows');
		reactionsToRemove = cell(0);
		rxnsKept = cell(0);
		duplicateReactions = cell(0);
		if (length(ia) ~= length(ic))
			for rxnInd=1:max(ic)
				% If the current reaction appears more than once
				if (sum(rxnInd == ic) > 1)
					identicalRxns = find(ic == rxnInd);
					rxnWithDuplicates = model.rxns(identicalRxns(1));
					rxnsToRemove = model.rxns(identicalRxns(2:end))';
					% Same abbreviation
					if (strcmp(rxnWithDuplicates, rxnsToRemove))
						model2 = model;
						model2.rxns(identicalRxns(1)) = '';
						model2 = removeRxns(model2, rxnsToRemove);
						model2.rxns(identicalRxns(1)) = rxnWithDuplicates;
						removed = [removed; rxnsToRemove'];
						cnt = cnt+1;
					else
						reactionsToRemove = [reactionsToRemove, rxnsToRemove];
					end
					rxnsKept = [rxnsKept; rxnWithDuplicates];
					duplicateReactions = [duplicateReactions; {rxnsToRemove}];
				end
				waitbar(rxnInd/max(ic), h);
			end
			removed = [removed; reactionsToRemove'];
			model = removeRxns(model, reactionsToRemove);
			cnt = cnt + length(reactionsToRemove);
			rxnRelationship.keptRxns = rxnsKept;
			rxnRelationship.duplicates = duplicateReactions;
		end
		close(h);
end