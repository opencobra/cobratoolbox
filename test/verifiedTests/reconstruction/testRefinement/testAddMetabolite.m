% The COBRAToolbox: testAddMetabolite.m
%
% Purpose:
%     - addMetabolite(model, metID, 'ParameterName', value, ...) adds one or several metabolites
%       through addMultipleMetabolites. Only the parameters given are passed on (metName ->
%       metNames, metFormula -> metFormulas, ChEBIID -> metChEBIID, KEGGId -> metKEGGID,
%       PubChemID -> metPubChemID, InChi -> metInChIString, Charge -> metCharges, b, csense);
%       a character value of a cell field is wrapped in a cell. A call whose first optional
%       argument is not a parameter name is read in the old positional order (metName,
%       formula, ChEBIID, KEGGId, PubChemID, InChi, Charge, b), skipping empty values; this
%       form is used by addReaction.
%     - Expected values come from the help text (defaults: name = id, b = 0, csense 'E') and
%       from the field defaults of COBRA_structure_fields.tab for fields the model already has.
%
% Function under test:
%     src/reconstruction/refinement/addMetabolite.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a small hand-built model (createModel); no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The second EXAMPLE of the help text uses the parameter name metCharge and fails
%       SEVERITY: cosmetic
%       TRIGGER: model = createModel({'R1','R2','R3'}, {'R1','R2','R3'}, {'A -> B','B -> C',
%         'C -> '}, 'printLevel', 0); addMetabolite(model, 'MetWithForm', 'metFormula', 'H3O',
%         'metCharge', 1)
%       OBSERVED: (R2025a, 2026-11-23) "'metCharge' is not a recognized parameter. For a list of
%         valid name-value pair arguments, see the documentation for this function." at line 97
%       EXPECTED: the example works; the parameter list of the help text names it Charge, and
%         addMetabolite(model, 'MetWithForm', 'metFormula', 'H3O', 'Charge', 1) works
%       LINES: 34
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddMetabolite'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% three metabolites (A[c], B[c], C[c]) and three reactions; createModel gives the fields
% metNames, b and csense, but no metFormulas, metCharges or database fields
model = createModel({'R1', 'R2', 'R3'}, {'R1', 'R2', 'R3'}, {'A -> B', 'B -> C', 'C -> '}, ...
    'printLevel', 0);
assert(~any(isfield(model, {'metFormulas', 'metCharges', 'metKEGGID'})));
nMets = numel(model.mets);

%% one id given as text, all defaults

newModel = addMetabolite(model, 'd[c]');
assert(isequal(newModel.mets, [model.mets; {'d[c]'}]));
% the documented defaults: the name is the id, b = 0, csense 'E'; S gets a zero row
assert(isequal(newModel.metNames{end}, 'd[c]'));
assert(newModel.b(end) == 0 && newModel.csense(end) == 'E');
assert(isequal(size(newModel.S), [nMets + 1, numel(model.rxns)]) && nnz(newModel.S(end, :)) == 0);
assert(isequal(newModel.S(1:nMets, :), model.S));
% parameters left at their default are not passed on, so no field is created for them
assert(~any(isfield(newModel, {'metFormulas', 'metCharges', 'metKEGGID'})));

%% one id with every parameter, cell fields given as text

newModel = addMetabolite(model, 'd[c]', 'metName', 'Ethanol', 'metFormula', 'C2H6O', ...
    'ChEBIID', 'CHEBI:16236', 'KEGGId', 'C00469', 'PubChemID', '702', ...
    'InChi', 'InChI=1S/C2H6O/c1-2-3/h3H,2H2,1H3', 'Charge', -1, 'b', 2, 'csense', 'L');
% each value lands in its model field (text wrapped into a cell); fields that were absent
% are created with their defaults ('' or NaN) for the old metabolites
assert(isequal(newModel.metNames{end}, 'Ethanol'));
assert(isequal(newModel.metFormulas, {''; ''; ''; 'C2H6O'}));
assert(isequal(newModel.metChEBIID{end}, 'CHEBI:16236'));
assert(isequal(newModel.metKEGGID{end}, 'C00469'));
assert(isequal(newModel.metPubChemID{end}, '702'));
assert(isequal(newModel.metInChIString{end}, 'InChI=1S/C2H6O/c1-2-3/h3H,2H2,1H3'));
assert(newModel.metCharges(end) == -1 && all(isnan(newModel.metCharges(1:nMets))));
assert(isequal(newModel.b, [0; 0; 0; 2]));
assert(isequal(newModel.csense, ['E'; 'E'; 'E'; 'L']));

%% several ids with cell and vector values

newModel = addMetabolite(model, {'d[c]', 'e[c]'}, 'metName', {'D', 'E'}, ...
    'Charge', [1, -2], 'b', [0, 5], 'csense', 'GL');
assert(isequal(newModel.mets(end - 1:end), {'d[c]'; 'e[c]'}));
assert(isequal(newModel.metNames(end - 1:end), {'D'; 'E'}));
assert(isequal(newModel.metCharges(end - 1:end), [1; -2]));
assert(isequal(newModel.b(end - 1:end), [0; 5]));
assert(isequal(newModel.csense(end - 1:end), ['G'; 'L']));
% without names the default name is each id
newModel = addMetabolite(model, {'p[c]', 'q[c]'});
assert(isequal(newModel.metNames(end - 1:end), {'p[c]'; 'q[c]'}));

%% the old positional form: empty values are skipped

% order metName, formula, ChEBIID, KEGGId, PubChemID, InChi, Charge, b (as addReaction uses it)
newModel = addMetabolite(model, 'x[c]', 'X name', 'C2H6O', '', 'C00469', '', '', -1, 2);
assert(isequal(newModel.mets{end}, 'x[c]') && isequal(newModel.metNames{end}, 'X name'));
assert(isequal(newModel.metFormulas{end}, 'C2H6O') && isequal(newModel.metKEGGID{end}, 'C00469'));
assert(newModel.metCharges(end) == -1 && newModel.b(end) == 2);
% the empty ChEBIID, PubChemID and InChi are not passed on, so their fields are not created
assert(~any(isfield(newModel, {'metChEBIID', 'metPubChemID', 'metInChIString'})));

%% an id already in the model is an error (raised by addMultipleMetabolites)

assert(verifyCobraFunctionError('addMetabolite', 'inputs', {model, 'A[c]'}, 'testMessage', ...
    sprintf('The following Metabolite ID(s) are already present in the model:\nA[c]')));

% change the directory
cd(currentDir)
