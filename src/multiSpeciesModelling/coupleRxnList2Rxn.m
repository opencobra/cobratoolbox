function [modelCoupled]=coupleRxnList2Rxn(model,rxnList,rxnC,c,u)
% 
% This function adds coupling constraints to the fluxes `vi` of a given list of reactions
% (`RxnList`).The constraints are proportional to the flux `v` of a specified
% reaction `rxnC`, so that for all reactions in `RxnList` `vi ~ vrxnC`.
% For all reactions, a threshold `u` on flux is set (default value: 0.01).
%
% To add a coupling constraint to a reaction, a coupling vector `c` is
% determined (default value 1000). `c` is multiplied by `vrxnC`, so that for
% all irreversible reactions in `RxnList vi - c * vrxnC <= u`.
%
% For all reversible reactions, the following equation holds true for the
% reverse direction: `vi + c * vrxnC >= u`.
%
% The output is a coupled model (`modelCoupled`), in which for every new
% entry in `modelCoupled.b` a "slack" variable has been added
% to `modelCoupled.mets`.
%
% USAGE:
%
%    [modelCoupled] = coupleRxnList2Rxn(model, rxnList, rxnC, c, u)
%
% INPUTS:
%    model:         model structure
%    rxnList:       array of reaction names
%    rxnC:          reaction that should be coupled with each reaction in the
%                   reaction list
%    c:             vector of coupling factors for each rxn in rxnList (default c = 1000)
%    u:             vector of lower bounds one reaction couples (default u = 0.01)
%
% OUTPUT:
%    modelCoupled:  coupled model
% .. Authors:
%    - Sept 2011 AH/IT
%    - May 2012: Added a warning if the coupled reaction is not in model. AH

if ~exist('rxnList', 'var') || isempty(rxnList)
    rxnList = model.rxns;
end

if exist('c', 'var')
    c = c * ones(length(rxnList), 1);
end

if ~exist('c', 'var') || isempty(c)
    c = 1000 * ones(length(rxnList), 1);
end

if exist('u', 'var')
    u = u * ones(length(rxnList), 1);
end

if ~exist('u', 'var') || isempty(u)
    u = 0.01 * ones(length(rxnList), 1);
end

% model.csense
if ~isfield(model, 'csense') || isempty(model.csense)
    % assume all constraints are equality
    model.csense(1:length(model.b), 1) = 'E';
end

% find index for rxnC
rxnCID = find(ismember(model.rxns, rxnC));

if isempty(find(ismember(model.rxns, rxnC)))
    fprintf('Reaction not in model!');
    modelCoupled = [];

else modelCoupled = model;
    if ~isfield(modelCoupled, 'A')
        modelCoupled.A = modelCoupled.S;
    end
    [nRows, nCols] = size(modelCoupled.A);
    nRows = nRows + 1;

    for i = 1:length(rxnList)
        RID = find(ismember(modelCoupled.rxns, rxnList(i)));
        % for every reaction, update modelCoupled.A
        % add 1 to position of RID, and -c to position of rxnCID, creates new row in A
        modelCoupled.A(nRows, RID) = 1;
        modelCoupled.A(nRows, rxnCID) = - c(i);
        modelCoupled.b(nRows, 1) = u(i);
        modelCoupled.mets(nRows, 1) = strcat('slack_', rxnList(i));
        modelCoupled.csense(nRows) = 'L';
        nRows = nRows +1;

        % for reversible reactions we add a "mirror" constraint
        if modelCoupled.lb(RID) < 0
            modelCoupled.A(nRows,RID) = 1;
            modelCoupled.A(nRows,rxnCID) = c(i);
            modelCoupled.b(nRows,1) = - u(i);
            modelCoupled.mets(nRows,1) = strcat('slack_', rxnList(i), '_R');
            modelCoupled.csense(nRows) = 'G';
            nRows = nRows +1;
        end
    end

    modelCoupled.csense = modelCoupled.csense';
end
