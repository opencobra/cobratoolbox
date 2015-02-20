function [model,removed, newModel, removedRxns, cnt, cnt2] = checkDuplicateRxn(model,method)
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
removed = '';
removedRxns = cell(0); 
cnt = 1;
cnt2 = 1;
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
		newModel = model;
		[~, ia, ic] = unique(newModel.S', 'rows');
		reactionsToRemove = cell(0);
		if (length(ia) ~= length(ic))
			for rxnInd=1:max(ic)
				% If the current reaction appears more than once
				if (sum(rxnInd == ic) > 1)
					identicalRxns = find(ic == rxnInd);
					rxnWithDuplicates = newModel.rxns(identicalRxns(1));
					rxnsToRemove = newModel.rxns(identicalRxns(2:end))';
					% Same abbreviation
					if (strcmp(rxnWithDuplicates, rxnsToRemove))
						model2 = newModel;
						model2.rxns(identicalRxns(1)) = '';
						model2 = removeRxns(model2, rxnsToRemove);
						model2.rxns(identicalRxns(1)) = rxnWithDuplicates;
						removedRxns = [removedRxns; rxnsToRemove'];
						cnt2 = cnt2+1;
					else
						reactionsToRemove = [reactionsToRemove, rxnsToRemove];
					end
				end
				waitbar(rxnInd/max(ic), h);
			end
			removedRxns = [removedRxns; reactionsToRemove'];
			newModel = removeRxns(newModel, reactionsToRemove);
			cnt2 = cnt2 + length(reactionsToRemove);
		end
		close(h);
		h = waitbar(0, 'Checking by reaction ...');
        for i = 1:nMets
            possibleMatches = find(model.S(i,:));
            for j = 1:length(possibleMatches)
                for k = (j+1):length(possibleMatches)
					%[i j k] - for each metabolite (i), find all reactions it
					%participates in, and then do a nested loop (j & k) on all the
					%reactions specific to this metabolite.
					
					% This has a bug, because it reomves reactions from the
					% model, which can also removes metabolites, so it should
					% repeat the loop with the same i, which is impossible
					% in matlab (so it could be kludged by doing i--
					% maybe). Or use removeRxns without removing
					% metabolites, and then remove empty metaoblites at the
					% end. Fixed by shifting possibleMatches.
					% Also added removeMetabolites at the beginning, to
					% remove unused metabolites before getting nMets.
					if model.S(:,possibleMatches(j)) == model.S(:,possibleMatches(k)) & strcmp(model.rxns(possibleMatches(j)),model.rxns(possibleMatches(k))) == 0
                        model = removeRxns(model,model.rxns(possibleMatches(k)));
                        removed{cnt,1} = model.rxns(possibleMatches(k));
                        cnt = cnt+1;
						possibleMatches(k:end) = possibleMatches(k:end) - 1;
                    elseif model.S(:,possibleMatches(j)) == model.S(:,possibleMatches(k)) & strcmp(model.rxns(possibleMatches(j)),model.rxns(possibleMatches(k))) == 1
                        model2 = model;
                        model2.rxns{possibleMatches(j)} = '';
                        model2 = removeRxns(model2,model.rxns(possibleMatches(j)));
                        model2.rxns{possibleMatches(j)} = model.rxns{possibleMatches(j)};
                        model = model2;
                        removed{cnt,1} = model.rxns{possibleMatches(j)};
                        cnt = cnt+1;
						possibleMatches(k:end) = possibleMatches(k:end) - 1;
                    end
                end
            end
            waitbar(i/nMets,h);
        end
        close(h);
end