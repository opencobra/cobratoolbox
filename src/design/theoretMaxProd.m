function [ExRxns,MaxTheoOut]= theoretMaxProd(model, criterion, inputrxn, normalize, rxns)
% Determines the max theoretical output for each exchange reaction
%
% USAGE:
%
%    [ExRxns, MaxTheoOut]= theoreticalMaxProduction(model, criterion, inputrxn, normalize, rxns)
%
% INPUT:
%    model:
%
% OPTIONAL INPUT:
%    criterion:   One of
%
%                   * 'pr_mol' (default)
%                   * 'pr_mw'  (same thing in molecular weight)
%                   * 'pr_other_mol' (other carbon compounds secretion rate)
%                   * 'pr_other_mw'  (same thing in molecular weight)
%                     weight yield)
%    inputrxn:    the input reaction ('EX_glu(e)', etc.)
%    normalize:   normalize by input flux.  Either the flux rate in mol or
%                 in molecular weight (Default = false)
%    rxns:        Selection Vector (1 for selected, 0 otherwise)
%
% OUTPUTS:
%    ExRxns:      Vector of exchange reactions
%    MaxThroOut:  The max theoretical output for each exchange reaction
%
% .. Author: - Jan Schellenberger 11/7/08

if nargin < 2 % find the exchange reactions
    criterion = 'pr_mol';
end
if isempty(criterion)
    criterion = 'pr_mol';
end
if nargin < 4
    normalize = false;
end

if nargin < 5
    [selExc,selUpt] = findExcRxns(model,0,0);
else
    selExc = rxns;
end

ExRxns = model.rxns(selExc);

[mw Ematrix] = computeMW(model, [], false);
MaxTheoOut = zeros(size(ExRxns));
if(strcmp(criterion, 'pr_mol') || strcmp(criterion, 'pr_mw') )
    inputRxnID = findRxnIDs(model, inputrxn);
    inputMetID = find(model.S(:,inputRxnID));
    for i=1:length(ExRxns)
        % make the new objective vector
        newC = zeros(length(model.c),1);
                rxn =  ExRxns(i);
        rxnID = find(strcmp(model.rxns,rxn));
        metID = find(model.S(:,rxnID));
        newC(rxnID,1) = 1;
        model.c = newC;
        % run the LP optimization
        FBAsolution = optimizeCbModel(model);
        % store the result
        if(strcmp(criterion, 'pr_mol') )
            MaxTheoOut(i,1) = FBAsolution.f;
            if normalize
                MaxTheoOut(i,1) = MaxTheoOut(i,1)/abs(FBAsolution.x(inputRxnID));
            end
        else
            MaxTheoOut(i,1) = FBAsolution.f * mw(metID);
            if normalize
                MaxTheoOut(i,1) = MaxTheoOut(i,1)/(abs(FBAsolution.x(inputRxnID))*mw(inputMetID));
            end
        end
    end

elseif( strcmp(criterion, 'pr_other_mol') || strcmp(criterion, 'pr_other_mw'))
    inputRxnID = findRxnIDs(model, inputrxn);
    inputMetID = find(model.S(:,inputRxnID));
    cmets = zeros(length(model.mets),1);
    cmets(Ematrix(:,1)~=0) = 1;
    coefficients = zeros(size(model.c));
    inputRxnID = findRxnIDs(model, inputrxn);
    selExcF = find(selExc);

    for i=1:length(ExRxns)
        rxnID = selExcF(i);
        metID = find(model.S(:,rxnID));
        if cmets(metID)>0
            coefficients(rxnID) = mw(metID);
%             if strcmp(ExRxns(i), 'EX_co2(e)') % get rid of CO2 if required
%                 coefficients(rxnID) = 0;
%             end
        end
    end

    for i=1:length(ExRxns)
        % make the new objective vector
        newC = zeros(length(model.c),1);
        rxnID = find(strcmp(model.rxns,ExRxns(i)));
        newC(rxnID,1) = 1;
        model.c = newC;
        % run the LP optimization
        FBAsolution = optimizeCbModel(model);
%            optimalFlux = FBAsolution.f;
        cf2 = coefficients;
        cf2(inputRxnID) = 0;
        cf2(rxnID) = 0;
        if( strcmp(criterion, 'pr_other_mol') )
            MaxTheoOut(i,1) = sum(FBAsolution.x .* (cf2>0) .* (FBAsolution.x > 0));
            if normalize
                MaxTheoOut(i,1) = MaxTheoOut(i,1)/abs(FBAsolution.x(inputRxnID));
            end
        else
            MaxTheoOut(i,1) = sum(FBAsolution.x .* (cf2) .* (FBAsolution.x > 0));
            if normalize
                MaxTheoOut(i,1) = MaxTheoOut(i,1)/(abs(FBAsolution.x(inputRxnID))*mw(inputMetID));
            end
        end
    end
else
    display('unknown criterion');
    criterion
end
