function model = destroyDummyModel(model, dummyMetBool, dummyRxnBool, metsOrig, rxnsOrig)
% Remove all traces of dummy metabolites and reactions 
%
% INPUT
% model     COBRA model
%
% OPTIONAL INPUT
% dummyMetBool      m x 1 boolean vector indicating dummy metabolites
% dummyRxnBool      n x 1 boolean vector indicating dummy reactions
% metsOrig          Array indicating the metabolites before creating a dummyModel
% rxnsOrig          Array indicating the reactions before creating dummyModel
%
% OUTPUT
% model     COBRA model without dummy metabolites or reactions
%

if nargin < 2 || isempty(dummyMetBool)
    % remove dummy metabolites
    dummyMetBool = contains(model.mets, 'dummy_Met_');
end
if nargin < 3 || isempty(dummyRxnBool)
    % Remove dummy reactions
    dummyRxnBool = contains(model.rxns, 'dummy_Rxn_');
end
% if nargin < 4 || isempty(metsOrig)
%     % Original metabolites
%     metsOrig = model.mets;
% end
% if nargin < 5 || isempty(rxnsOrig)
%     % Original reactions
%     rxnsOrig = model.rxns;
% end

if any(dummyRxnBool) || any(dummyMetBool)
    model.mets = model.mets(~dummyMetBool);
    model.S = model.S(~dummyMetBool, ~dummyRxnBool);
    model.b = model.b(~dummyMetBool);
    model.rxns = model.rxns(~dummyRxnBool);
    model.rxnNames = model.rxnNames(~dummyRxnBool);
    model.lb = model.lb(~dummyRxnBool);
    model.ub = model.ub(~dummyRxnBool);
    model.c = model.c(~dummyRxnBool);
    
    if isfield(model, 'csense')
        model.csense = model.csense(~dummyMetBool);
    end
    if isfield(model, 'ctrs')
        model.C = model.C(:, ~dummyRxnBool);
    end
    if isfield(model, 'rxnGeneMat')
        model.rxnGeneMat = model.rxnGeneMat(~dummyRxnBool, :);
    end
    if isfield(model, 'rules')
        model.rules = model.rules(~dummyRxnBool);
    end
    if isfield(model, 'subSystems')
        model.subSystems = model.subSystems(~dummyRxnBool);
    end
    if isfield(model, 'SIntMetBool')
        model.SIntMetBool = model.SIntMetBool(~dummyMetBool);
    end
    if isfield(model, 'SIntRxnBool')
        model.SIntRxnBool = model.SIntRxnBool(~dummyRxnBool);
    end
    if isfield(model, 'SConsistentMetBool')
        model.SConsistentMetBool = model.SConsistentMetBool(~dummyMetBool);
    end
    if isfield(model, 'SConsistentRxnBool')
        model.SConsistentRxnBool = model.SConsistentRxnBool(~dummyRxnBool);
    end
    if isfield(model, 'fluxConsistentMetBool')
        model.fluxConsistentMetBool = model.fluxConsistentMetBool(~dummyMetBool);
    end
    if isfield(model, 'fluxConsistentRxnBool')
        model.fluxConsistentRxnBool = model.fluxConsistentRxnBool(~dummyRxnBool);
    end
    if isfield(model, 'thermoFluxConsistentMetBool')
        model.thermoFluxConsistentMetBool = model.thermoFluxConsistentMetBool(~dummyMetBool);
    end
    if isfield(model, 'thermoFluxConsistentRxnBool')
        model.thermoFluxConsistentRxnBool = model.thermoFluxConsistentRxnBool(~dummyRxnBool);
    end
end

if isfield(model,'dummyMetBool')
    model = rmfield(model, 'dummyMetBool');
end
if isfield(model,'dummyRxnBool')
    model = rmfield(model, 'dummyRxnBool');
end

% model.S = model.S(~model.dummyMetBool,~model.dummyRxnBool);
% model.b = model.b(~model.dummyMetBool,1);
% model.csense = model.csense(~model.dummyMetBool,1);
% model.mets = model.mets(~model.dummyMetBool);
% model.rxns = model.rxns(~model.dummyRxnBool);
% model.rxnNames = model.rxnNames(~model.dummyRxnBool);
% model.lb = model.lb(~model.dummyRxnBool);
% model.ub = model.ub(~model.dummyRxnBool);
% model.c = model.c(~model.dummyRxnBool);
% if isfield(model, 'ctrs')
%     model.C = model.C(:,~model.dummyRxnBool);
% end
% if isfield(model, 'rxnGeneMat')
%     model.rxnGeneMat = model.rxnGeneMat(~model.dummyRxnBool,:);
% end
% if isfield(model, 'rules')
%     model.rules = model.rules(~model.dummyRxnBool);
% end
% if isfield(model,'subSystems')
%     model.subSystems = model.subSystems(~model.dummyRxnBool);
% end
% if isfield(model,'SIntRxnBool')
%     model.SIntRxnBool = model.SIntRxnBool(~model.dummyRxnBool);
% end
% if isfield(model,'SConsistentRxnBool')
%     model.SConsistentRxnBool = model.SConsistentRxnBool(~model.dummyRxnBool);
% end
% if isfield(model,'fluxConsistentRxnBool')
%     model.fluxConsistentRxnBool = model.fluxConsistentRxnBool(~model.dummyRxnBool);
% end
% if isfield(model,'thermoFluxConsistentRxnBool')
%     model.thermoFluxConsistentRxnBool = model.thermoFluxConsistentRxnBool(~model.dummyRxnBool);
% end
    
if exist('metsOrig','var')
    % Remove deleted mets/rxns in all the fields
    if ~isequal(model.mets, metsOrig) || ~isequal(model.rxns, rxnsOrig)
        warning('mets/rxns were not consistently deleted in all fields!')
        cbFields = fieldnames(model);
        mets2Delete = ~ismember(metsOrig, model.mets);
        rxns2Delete = ~ismember(rxnsOrig, model.rxns);
        for i = 1:length(cbFields)
            if length(metsOrig) == length(model.(cbFields{i}))
                model.(cbFields{i})(mets2Delete) = [];
            elseif length(rxnsOrig) == length(model.(cbFields{i}))
                model.(cbFields{i})(rxns2Delete) = [];
            end
        end
    end
end

