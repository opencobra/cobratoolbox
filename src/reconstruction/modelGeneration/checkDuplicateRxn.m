function [modelOut, removedRxnInd, keptRxnInd] = checkDuplicateRxn(model, method, removeFlag, printLevel, boundsFlag)
% Checks model for duplicate reactions and removes them.
% By default, it detects the columns of `S` that are identical upto scalar
% multiplication
%
% USAGE:
%
%    [modelOut, removedRxnInd, keptRxnInd] = checkDuplicateRxn(model, method, removeFlag, printLevel, boundsFlag)
%
% INPUTS:
%    model:             Cobra model structure
%
% OPTIONAL INPUTS:
%    method:            S --> checks rxn `S` matrix (default),
%                       rxnAbbr --> checks rxn abbreviations,
%                       FR --> checks `F + R` matrix, where :math:`S:=-F + R`, which ignores
%                       reaction direction
%
%
% OUTPUTS:
%     modelOut:         COBRA model structure without (with) duplicate reactions
%     removedRxnInd:    Reaction numbers in model that were (should be) removed
%     keptRxnInd:       Reaction numbers in model that were (should be) kept
%
% .. Authors:
%       - Ronan Fleming rewritten 2017
%       - Thomas Pfau June 2017, added boundsFlag

if ~exist('method', 'var')
    method = 'S';
end

if ~exist('printLevel', 'var')
    printLevel = 0;
end

if ~exist('removeFlag', 'var')
    removeFlag = 1;
end

if ~exist('boundsFlag', 'var')
    boundsFlag = 0;
end

[~, nRxn] = size(model.S);

removedRxnInd = [];
keptRxnInd = [];
oneToN = 1:nRxn;

cnt = 0;

switch method
    case {1,'rxnAbbr'}
        if printLevel > 0
            fprintf('%s\n', 'Checking for reaction duplicates by reaction abbreviation ...');
        end
        [~, ia, ic] = unique(model.rxns,'stable');
        removedRxnInd=oneToN(ia);
        %C = setdiff(A,B) for vectors A and B, returns the values in A that
        %are not in B with no repetitions.
        keptRxnInd=setdiff(oneToN,removedRxnInd);
    case {2,'S'}
        if printLevel > 0
            fprintf('%s\n', 'Checking for reaction duplicates by stoichiometry ...');
        end
        % error('in development')
        % depends on the direction of reaction, i.e., reactions
        % otherwise duplicates but going in the opposite direction are not consisered duplicates

        % detect the rows of A that are identical upto scalar multiplication divide each row by the sum of each row.

        % get unique cols, but do not change the order
        % [C,IA,IC] = unique(A,'rows') also returns index vectors IA and IC such
        % that C = A(IA,:) and A = C(IC,:).
        if boundsFlag
            [~, ia, ic] = unique([model.lb, model.S' model.ub], 'rows', 'stable');
        else
            [~, ia, ic] = unique(model.S', 'rows', 'stable');
        end
        nDuplicates = length(ic) - length(ia);
        if nDuplicates > 0
            if printLevel > 0
                fprintf('%u%s\n', nDuplicates, ' duplicate reaction(s) (up to orientation)')
            end
            for n = 1:nRxn
                bool = (ic == n);
                if nnz(bool) > 1
                    ind = oneToN(bool);

                    keptOneRxnInd = ind(1);
                    removedOneRxnInd = ind(end);

                    if length(ind) > 2
                        warning(['Reaction: ' model.rxns{ind(1)} ' has more than one replicate'])
                    end


                    removedRxnInd = [removedRxnInd; removedOneRxnInd];
                    keptRxnInd = [keptRxnInd; keptOneRxnInd];

                    if printLevel > 0
                        %fprintf('%u%s\n',length(removedOneRxnInd),' duplicate reaction(s) (up to orientation)')
                        fprintf('%s\t', '     Keep: ');
                        formulas = printRxnFormula(model, model.rxns{keptOneRxnInd});
                        fprintf('%s\t', 'Duplicate: ');
                        formulas = printRxnFormula(model, model.rxns{removedOneRxnInd});
                    end
                end
            end
        end

    case {'FR'}
        if printLevel > 0
            fprintf('%s\n', 'Checking for reaction duplicates by stoichiometry (up to orientation) ...');
        end

        % vanilla forward and reverse half stoichiometric matrices
        F        = - model.S;
        F(F < 0) = 0;
        R        = model.S;
        R(R < 0) = 0;

        A = F + R;  % invariant to direction of reaction

        % detect the cols of A that are identical upto scalar multiplication
        % divide each col by the sum of each row.
        sumA1 = sum(A, 1);
        sumA1(sumA1 == 0) = 1;
        normalA1 = A * diag(1 ./ sumA1);

        % get unique cols, but do not change the order
        % [C,IA,IC] = unique(A,'rows') also returns index vectors IA and IC such
        % that C = A(IA,:) and A = C(IC,:).
        if boundsFlag
            [~, ia, ic] = unique([model.lb, normalA1' model.ub], 'rows', 'stable');
        else
            [~, ia, ic] = unique(normalA1', 'rows', 'stable');
        end


        for n =1:nRxn
            bool = (ic == n);
            if nnz(bool) > 1
                ind = oneToN(bool);
                if norm(model.S(:, ind(1)) + model.S(:, ind(2))) == 0 || norm(model.S(:, ind(1)) - model.S(:, ind(2))) == 0
                    keptOneRxnInd = ind(1);
                    removedOneRxnInd = ind(end);

                    if length(ind) > 2
                        warning([model.rxns{ind(1)} ' has more than one replicate']);
                    end

                    removedRxnInd = [removedRxnInd; removedOneRxnInd];
                    keptRxnInd = [keptRxnInd; keptOneRxnInd];

                    if printLevel > 0
                        fprintf('%s\t', '     Keep: ');
                        formulas = printRxnFormula(model, model.rxns{keptOneRxnInd});
                        fprintf('%s\t', 'Duplicate: ');
                        formulas = printRxnFormula(model, model.rxns{removedOneRxnInd});
                    end
                %else: these reactions involve the same metabolites but they are not duplicates.
                end
            end
        end
end


if length(removedRxnInd) == 0
    if printLevel > 0
        fprintf('%s\n', ' no duplicates found.');
    end
    modelOut=model;
else
    if removeFlag
        %remove the reactions
        modelOut = removeRxns(model, model.rxns(removedRxnInd));
    else
        modelOut=model;
    end
end
