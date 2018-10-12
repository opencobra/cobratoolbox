function [modelCoupled] = coupleRxnList2Rxn(model, rxnList, rxnC, c, u)
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
%    model:           model structure
%    rxnList:         array of reaction names
%    rxnC:            reaction that should be coupled with each reaction in the
%                     reaction list
%    c:               vector of coupling factors for each rxn in rxnList (default c = 1000)
%    u:               vector of lower bounds one reaction couples (default u = 0.01)
%
% OUTPUT:
%    modelCoupled:    coupled model
%
% .. Authors:
%    - Sept 2011 AH/IT
%    - May 2012: Added a warning if the coupled reaction is not in model. AH

if ~exist('rxnList', 'var') || isempty(rxnList)
    rxnList = model.rxns;   
end

if ischar(rxnC)
    rxnC = {rxnC};
end

if ~exist('c', 'var') || isempty(c)
    c = 1000; 
end

if ~exist('u', 'var') || isempty(u)
    u = 0.01;
end

nRxnList = numel(rxnList);
% create the constraint IDs.
ctrs = [strcat('slack_',rxnList)';strcat('slack_',rxnList,'_R')'];
ctrs = ctrs(:);
% get those reactions which are not reversible.
[pres,pos] = ismember(rxnList,model.rxns);
revs = model.lb(pos(pres)) < 0;
toRemove = [false(1,nRxnList);~revs'];
toRemove = toRemove(:);

% if rxnC is not part of the rxnList, we add it to the end for constraint
% addition.
if isempty(intersect(rxnList,rxnC))
    rxnList(end+1) = rxnC;
end
% get the rxnC Position;
rxnCID = find(ismember(rxnList,rxnC));

plusminus = [ones(1,nRxnList);-ones(1,nRxnList)];
plusminus = plusminus(:);

% generate the coefficient matrix
coefs = sparse(2*nRxnList,nRxnList + numel(setdiff(rxnC,rxnList)));
% determine the indices for the coefficients.
rxnInd =  [1:nRxnList;1:nRxnList];
rxnInd = rxnInd(:);
constInd = 1:2*nRxnList;
coefs(sub2ind(size(coefs),constInd',rxnInd)) = 1;
% set the coupling coefficients
cs = - plusminus * c;
coefs(:,rxnCID ) = cs;
% determine the senses for the indices
dsenses = [repmat('L',1,nRxnList);repmat('G',1,nRxnList)];
dsenses = dsenses(:);
ds = plusminus * u;


% remove non reversible reactions
ds = ds(~toRemove);
ctrs = ctrs(~toRemove);
coefs = coefs(~toRemove,:);
dsenses = dsenses(~toRemove);

modelCoupled = addCOBRAConstraints(model,rxnList,ds,'c', coefs,'dsense',dsenses, 'ConstraintID',ctrs);

