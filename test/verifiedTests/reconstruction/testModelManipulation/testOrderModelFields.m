% The COBRAToolbox: testOrderModelFields.m
%
% Purpose:
%     - orderModelFields reorders the fields of a model: first the fields defined in the COBRA
%       field definitions (getDefinedFieldProperties), in the order of the definitions, then the
%       remaining fields in alphabetical order. The field values are not changed.
%       Characterization test that PINS the current behaviour (feature
%       20261102-142225-tier2-test-pilot, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the field order of ecoli_core_model asserted below was recorded from
%       the first run on 2026-11-02 with ecoli_core_model (no solver). It was not derived
%       independently, so it guards consistency, not independent correctness (Tier 5). The
%       order rule itself is also checked against getDefinedFieldProperties.
%
% Function under test:
%     src/reconstruction/refinement/orderModelFields.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261102-142225-tier2-test-pilot, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOrderModelFields'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites, 137 genes, compartments c and e)
model = getDistributedModel('ecoli_core_model.mat');

%% the fields of a model in reverse order are put in the order of the field definitions

% reverse the field order of the loaded model, so that the function has to reorder every field
reversedModel = orderfields(model, flipud(fieldnames(model)));
orderedModel = orderModelFields(reversedModel);
orderedFields = fieldnames(orderedModel);

% Tier-5 reference order (first run, 2026-11-02): all 19 fields of ecoli_core_model are defined
% fields, in the order of the field definitions
expectedFields = {'S'; 'mets'; 'b'; 'csense'; 'rxns'; 'lb'; 'ub'; 'c'; 'osenseStr'; 'genes'; ...
    'rules'; 'metFormulas'; 'metNames'; 'grRules'; 'rxnGeneMat'; 'rxnNames'; 'subSystems'; ...
    'description'; 'modelID'};
assert(isequal(orderedFields, expectedFields));

% the order agrees with the field definitions: the position of every field in the definitions
% increases along the result
fieldDefinitions = getDefinedFieldProperties();
[isDefined, definitionPos] = ismember(orderedFields, fieldDefinitions(:, 1));
assert(all(isDefined));
assert(issorted(definitionPos));

% the values are unchanged (isequal compares structures field by field, whatever their order)
assert(isequal(orderedModel, model));

% the result does not depend on the input order: the loaded model gives the same order, and
% ordering an ordered model changes nothing
assert(isequal(fieldnames(orderModelFields(model)), expectedFields));
assert(isequal(fieldnames(orderModelFields(orderedModel)), expectedFields));

%% fields that are not defined are kept after the defined fields, in alphabetical order

% add three fields that are not in the field definitions, in non-alphabetical order
extendedModel = model;
extendedModel.zNote = 'last';
extendedModel.aNote = 'first';
extendedModel.rxnExtraData = zeros(numel(model.rxns), 1);
orderedModel = orderModelFields(extendedModel);
orderedFields = fieldnames(orderedModel);

% the defined fields come first, in the definition order, then the added fields sorted
fieldDefinitions = getDefinedFieldProperties();
isDefined = ismember(orderedFields, fieldDefinitions(:, 1));
assert(all(isDefined(1:19)) && ~any(isDefined(20:end)));
assert(isequal(orderedFields(20:end), {'aNote'; 'rxnExtraData'; 'zNote'}));

% no field is lost or added and the values are unchanged
assert(numel(orderedFields) == numel(fieldnames(extendedModel)));
assert(isequal(orderedModel, extendedModel));

% change the directory
cd(currentDir)
