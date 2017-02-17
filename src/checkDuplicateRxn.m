function [model,removedRxnInd, keptRxnInd] = checkDuplicateRxn(model,method,removeFlag,printLevel)
%checkDuplicateRxn Checks model for duplicate reactions and removes them
%
% [model,removedRxnInd] = checkDuplicateRxn(model,method)
%
%INPUTS
% model     Cobra model structure
% method    1 --> checks rxn abbreviations
%           2 --> checks rxn S matrix
%
%OUTPUTS
% model     Cobra model structure with duplicate reactions removedRxnInd
% removedRxnInd   reaction numbers that were removedRxnInd

% Ronan Fleming rewritten 2017

if ~exist('printLevel','var')
    printLevel=0;
end

[~,nRxn] = size(model.S);

removedRxnInd=[];
keptRxnInd=[];
oneToN=1:nRxn;

cnt = 0;

switch method
    case 1
        if printLevel>0
            fprintf('%s\n','Checking for reaction duplicates by stoichometry ...');
        end
        if 0
            i = 1;
            while i <= nRxn
                model2 = model;
                model2.rxns{i} = '';
                if isempty(strmatch(model.rxns(i),model2.rxns,'exact')) == 0
                    matches = strmatch(model.rxns(i),model2.rxns,'exact');
                    nRxn = nRxn - length(matches);
                    model2 = removeRxns(model2,model.rxns(i));
                    model2.rxns{i} = model.rxns{i};
                    model = model2;
                    removedRxnInd(cnt,1) = i;
                    cnt = cnt+1;
                end
                i = i+1;
            end
        else
            %error('in development')
            %depends on the direction of reaction, i.e., reactions
            %otherwise duplicates but going in the opposite direction are
            %not consisered duplicates
            
            %detect the rows of A that are identical upto scalar multiplication
            %divide each row by the sum of each row.
            
            %get unique cols, but do not change the order
            % [C,IA,IC] = unique(A,'rows') also returns index vectors IA and IC such
            % that C = A(IA,:) and A = C(IC,:).
            [~,ia, ic] = unique(model.S','rows','stable');
            
            nDuplicates=length(ic)-length(ia);
            if nDuplicates>0
                if printLevel>0
                    fprintf('%u%s\n',nDuplicates,' duplicate reaction(s) (up to orientation)')
                end
                for n=1:nRxn
                    bool=ic==n;
                    if nnz(bool)>1
                        ind=oneToN(bool);
                        keptOneRxnInd=ind(1);
                        removedOneRxnInd=ind(end);
                        if length(ind)>2
                            warning([model.rxns{ind(1)} ' has more than one replicate'])
                        end
                        removedRxnInd=[removedRxnInd;removedOneRxnInd];
                        keptRxnInd=[keptRxnInd;keptOneRxnInd];
                        if printLevel>0
                            %fprintf('%u%s\n',length(removedOneRxnInd),' duplicate reaction(s) (up to orientation)')
                            fprintf('%s\t','     Keep: ');
                            formulas = printRxnFormula(model,model.rxns{keptOneRxnInd});
                            fprintf('%s\t','Duplicate: ');
                            formulas = printRxnFormula(model,model.rxns{removedOneRxnInd});
                        end
                    end
                end
            end
        end
    case 2
        if printLevel>0
            fprintf('%s\n','Checking for reaction duplicates by stoichometry (up to orientation) ...');
        end
        if 0
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
                            removedRxnInd = [removedRxnInd; rxnsToRemove'];
                            cnt = cnt+1;
                        else
                            reactionsToRemove = [reactionsToRemove, rxnsToRemove];
                        end
                        rxnsKept = [rxnsKept; rxnWithDuplicates];
                        duplicateReactions = [duplicateReactions; {rxnsToRemove}];
                    end
                end
                removedRxnInd = [removedRxnInd; reactionsToRemove'];
                
                model = removeRxns(model, reactionsToRemove);
                cnt = cnt + length(reactionsToRemove);
                rxnRelationship.keptRxns = rxnsKept;
                rxnRelationship.duplicates = duplicateReactions;
            end
        else
            %vanilla forward and reverse half stoichiometric matrices
            F       = -model.S;
            F(F<0)  =    0;
            R       =  model.S;
            R(R<0)  =    0;
            
            A=F+R;%invariant to direction of reaction
            %A=[F;R];
            
            %detect the cols of A that are identical upto scalar multiplication
            %divide each col by the sum of each row.
            sumA1          = sum(A,1);
            sumA1(sumA1==0)  = 1;
            normalA1          = A*diag(1./sumA1);
            
            %get unique cols, but do not change the order
            % [C,IA,IC] = unique(A,'rows') also returns index vectors IA and IC such
            % that C = A(IA,:) and A = C(IC,:).
            [~,ia, ic] = unique(normalA1','rows','stable');
            
            for n=1:nRxn
                bool=ic==n;
                if nnz(bool)>1
                    ind=oneToN(bool);
                    if norm(model.S(:,ind(1))+model.S(:,ind(2)))==0 | norm(model.S(:,ind(1))-model.S(:,ind(2)))==0
                        keptOneRxnInd=ind(1);
                        removedOneRxnInd=ind(end);
                        if length(ind)>2
                            warning([model.rxns{ind(1)} ' has more than one replicate'])
                        end
                        removedRxnInd=[removedRxnInd;removedOneRxnInd];
                        keptRxnInd=[keptRxnInd;keptOneRxnInd];
                        if printLevel>0
                            fprintf('%s\t','     Keep: ');
                            formulas = printRxnFormula(model,model.rxns{keptOneRxnInd});
                            fprintf('%s\t','Duplicate: ');
                            formulas = printRxnFormula(model,model.rxns{removedOneRxnInd});
                        end
                    else
                        %these reactions involve the same metabolites but
                        %they are not duplicates.
                    end
                end
            end
        end
end
if length(removedRxnInd)==0
    if printLevel>0
        fprintf('%s\n',' no duplicates found.')
    end
else
    if removeFlag
        %remove the reactions
        model = removeRxns(model, model.rxns(removedRxnInd));
    end
end

