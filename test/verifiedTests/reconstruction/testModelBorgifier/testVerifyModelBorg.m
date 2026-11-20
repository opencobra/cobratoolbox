% The COBRAToolbox: testVerifyModelBorg.m
%
% Purpose:
%     - verifyModelBorg brings a COBRA model into the form the modelBorgifier scripts expect:
%       it removes fields not listed by TmodelFields, adds missing reaction and metabolite
%       fields (empty texts or zeros), pads short ones, flattens nested cells, turns
%       reactions with abs(lb) > ub forwards (bounds swapped and negated, S column negated),
%       lower-cases and cleans names (fixNames, removeDuplicateNames), takes a missing
%       compartment tag from metNames or else assigns [c], copies rxns and mets to rxnID and
%       metID, fills rxnSEEDID and metSEEDID for SEED identifiers, removes the 1s from
%       formulas (fixChemFormulas), builds rxnEquations and orders fields and entries
%       (orderModelFieldsBorg, organizeModelCool).
%     - Expected values are written down from these rules for three hand-built models of
%       two or three reactions; the option 'keepName' is always given (see exemptions).
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/verifyModelBorg.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation on hand-built models of two or three reactions, no solver.
%
% Coverage exemptions:
%     Lines 208, 210, 216, 217: duplicate reaction or metabolite IDs make makeNamesUnique ask
%     for interactive input (input()); lines 291, 294-298, 300, 308-310, 313-320: a model
%     without description, a call without 'keepName' or an invalid model name make the
%     function ask for the model name with input() (interactive input).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testVerifyModelBorg'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

fields = TmodelFields;
allFields = fields{5};

%% fields added, padded, flattened and removed; a reaction turned forwards

% R2 has lb = -10 > ub = 0, so it is turned: bounds [0, 10] and S column negated.
% c, rxnNames, metNames and metCharge are one entry short; subSystems and the first
% formula are nested cells;
% extraField is not a Tmodel field; the other Tmodel fields are missing.
modelA = struct();
modelA.rxns = {'R1'; 'R2'; 'EX_a'};
modelA.mets = {'a[c]'; 'b[c]'; 'c[c]'};
modelA.S = sparse([-1 0 -1; 1 -1 0; 0 1 0]);
modelA.lb = [0; -10; -10];
modelA.ub = [10; 0; 10];
modelA.c = [0; 1];
modelA.rxnNames = {'R one'; 'R two'};
modelA.subSystems = {{'Sub1'}; {{'Sub2'}}; ''};
modelA.grRules = {'g1 or g2'; ''; 'g3'};
modelA.genes = {'g1'; 'g2'; 'g3'};
modelA.rules = {'x(1) | x(2)'; ''; 'x(3)'};
modelA.metNames = {'A'; 'B'};
modelA.metFormulas = {{'C1H2O1'}; 'C2'; 'H2O1'};
modelA.metCharge = [0; 1];
modelA.extraField = 1;
modelA.description = 'modelA';

verifiedA = verifyModelBorg(modelA, 'keepName', 'Verbose');

% exactly the Tmodel fields, in their order (rules and extraField removed)
assert(isequal(fieldnames(verifiedA), allFields));
assert(strcmp(verifiedA.description, 'modelA'));

% lower-case reaction IDs, copied to rxnID; metabolites already have compartments
assert(isequal(verifiedA.rxns, {'r1'; 'r2'; 'ex_a'}));
assert(isequal(verifiedA.rxnID, verifiedA.rxns));
assert(isequal(verifiedA.mets, {'a[c]'; 'b[c]'; 'c[c]'}));
assert(isequal(verifiedA.metID, verifiedA.mets));

% R2 turned forwards: column [0; -1; 1] negated, bounds [-ub, -lb] = [0, 10]
assert(isequal(full(verifiedA.S), [-1 0 -1; 1 1 0; 0 -1 0]));
assert(isequal(verifiedA.lb, [0; 0; -10]));
assert(isequal(verifiedA.ub, [10; 10; 10]));

% short arrays padded with 0 or an empty text (metNames lower-cased by fixNames; the
% padded name passes removeDuplicateNames as an empty 1 x 0 text, hence isempty)
assert(isequal(verifiedA.c, [0; 1; 0]));
assert(isequal(verifiedA.metCharge, [0; 1; 0]));
assert(isequal(verifiedA.rxnNames(1:2), {'R one'; 'R two'}) && isempty(verifiedA.rxnNames{3}));
assert(isequal(verifiedA.metNames(1:2), {'a'; 'b'}) && isempty(verifiedA.metNames{3}));

% nested cells flattened to texts
assert(isequal(verifiedA.subSystems, {'Sub1'; 'Sub2'; ''}));

% nested formula flattened and 1s removed from formulas
assert(isequal(verifiedA.metFormulas, {'CH2O'; 'C2'; 'H2O'}));

% missing fields added as empty texts; no SEED identifiers here
emptyFields = {'rxnECNumbers', 'rxnKEGGID', 'rxnReferences', 'rxnNotes', 'metKEGGID', ...
    'metChEBIID', 'metPubChemID', 'metInChIString'};
for iField = 1:numel(emptyFields)
    assert(isequal(verifiedA.(emptyFields{iField}), {''; ''; ''}));
end
assert(all(cellfun(@isempty, verifiedA.rxnSEEDID)));
assert(all(cellfun(@isempty, verifiedA.metSEEDID)));
assert(isequal(verifiedA.grRules, modelA.grRules));
assert(isequal(verifiedA.genes, modelA.genes));

% reaction equations from S and the new bounds
assert(isequal(verifiedA.rxnEquations, {'a[c] --> b[c]'; 'c[c] --> b[c]'; 'a[c] <==>'}));

%% compartments taken from metNames; SEED identifiers; missing c and metCharge

% mets have no compartment, their names do: 'cpd00001' -> 'cpd00001[e]' and name 'water';
% 'X' -> 'x[c]'. c, metCharge and metFormulas are missing and are added as zeros or ''.
% organizeModelCool puts x[c] (in two reactions) before cpd00001[e] (in one).
modelB = struct();
modelB.rxns = {'rxn00001'; 'EX_x'};
modelB.mets = {'cpd00001'; 'X'};
modelB.S = sparse([-1 0; 1 -1]);
modelB.lb = [0; -10];
modelB.ub = [10; 10];
modelB.rxnNames = {'Water transport'; 'X exchange'};
modelB.metNames = {'Water[e]'; 'X[c]'};
modelB.description = 'modelB';

verifiedB = verifyModelBorg(modelB, 'keepName', 'Verbose');

assert(isequal(verifiedB.mets, {'x[c]'; 'cpd00001[e]'}));
assert(isequal(verifiedB.metNames, {'x'; 'water'}));
assert(isequal(full(verifiedB.S), [1 -1; -1 0]));
assert(isequal(verifiedB.rxns, {'rxn00001'; 'ex_x'}));
assert(isequal(verifiedB.c, [0; 0]));
assert(isequal(verifiedB.metCharge, [0; 0]));
assert(isequal(verifiedB.metFormulas, {''; ''}));

% SEED identifiers recognised in rxns (rxn + 5 digits) and in mets without compartment
assert(strcmp(verifiedB.rxnSEEDID{1}, 'rxn00001') && isempty(verifiedB.rxnSEEDID{2}));
assert(isempty(verifiedB.metSEEDID{1}) && strcmp(verifiedB.metSEEDID{2}, 'cpd00001'));
assert(isequal(verifiedB.rxnEquations, {'cpd00001[e] --> x[c]'; 'x[c] <==>'}));

%% no compartment anywhere: the metabolite is assigned to the cytosol [c]

% organizeModelCool puts d[c] (in two reactions) before a[c] (in one)

modelC = struct();
modelC.rxns = {'R1'; 'EX_d'};
modelC.mets = {'a[c]'; 'd'};
modelC.S = sparse([-1 0; 1 -1]);
modelC.lb = [0; -10];
modelC.ub = [10; 10];
modelC.metNames = {'A'; 'D'};
modelC.description = 'modelC';

verifiedC = verifyModelBorg(modelC, 'keepName', 'Verbose');

assert(isequal(verifiedC.mets, {'d[c]'; 'a[c]'}));
assert(isequal(verifiedC.metID, verifiedC.mets));
assert(isequal(verifiedC.metNames, {'d'; 'a'}));
assert(numel(verifiedC.rxnNames) == 2 && all(cellfun(@isempty, verifiedC.rxnNames)));
assert(isequal(verifiedC.rxnEquations, {'a[c] --> d[c]'; 'd[c] <==>'}));

% change the directory
cd(currentDir)
