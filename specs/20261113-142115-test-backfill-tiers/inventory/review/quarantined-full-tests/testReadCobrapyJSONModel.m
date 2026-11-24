% The COBRAToolbox: testReadCobrapyJSONModel.m
%
% Purpose:
%     - readCobrapyJSONModel reads a model saved in the JSON format of cobrapy
%       (cobra.io.save_json_model) and returns a COBRA model structure: metabolites, reactions
%       and genes with their attributes, the stoichiometric matrix parsed from the raw text
%       (so that identifiers are kept as written), b = 0, csense 'E', osenseStr 'max', grRules
%       and rules. This test writes small JSON files by hand in a tempname folder and checks:
%       lists of objects with different keys (decoded as cell arrays) and with the same keys
%       (decoded as struct arrays); present, empty, null and absent optional attributes;
%       JSON escapes in metabolite identifiers; a reaction with an empty stoichiometry; genes
%       present, empty or absent, and a rule naming a gene that genes does not list; a model
%       without id and name; a string file name; printLevel 1; and the four errors the
%       function raises plus the two argument checks of its input parser. Expected values are
%       read off the hand-written files.
%     - The older shared test test/verifiedTests/base/testIO/testReadPythonFiles.m also calls
%       this function (with three other readers); this file is its own test (III-Naming).
%
% Function under test:
%     src/base/io/utilities/readCobrapyJSONModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - builds models from hand-written files without a solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: metabolite identifiers written with a \u escape are not found
%       SEVERITY: limitation
%       TRIGGER: a metabolite identifier with a non-ASCII character, which Python's json.dump
%                (ensure_ascii, the cobrapy default) writes as a \u escape, for example
%                {"metabolites":[{"id":"Aé"},{"id":"B"}],"reactions":[{"id":"R1",
%                "metabolites":{"Aé":-1,"B":1},"lower_bound":0,"upper_bound":1}]}
%       OBSERVED: MATLAB R2025a, 2026-11-23: error "Metabolite Au00e9 of reaction R1 is not
%                 defined in the model." jsondecode decodes the identifier to A followed by
%                 char 233, but line 106 only removes the backslash of an escape, giving Au00e9
%       EXPECTED: the model is read with S = [-1; 1], as the NOTE of the help says identifiers
%                 are kept exactly as written
%       LINES: 106
%     - DEFECT: a metabolite identifier containing a brace makes the reaction stoichiometry unreadable
%       SEVERITY: limitation
%       TRIGGER: a metabolite identifier with { or }, for example
%                {"metabolites":[{"id":"A{x}"},{"id":"B"}],"reactions":[{"id":"R1",
%                "metabolites":{"A{x}":-1,"B":1},"lower_bound":0,"upper_bound":1}]}
%       OBSERVED: MATLAB R2025a, 2026-11-23: error "The number of reaction stoichiometries (0)
%                 differs from the number of reactions (1)." The pattern of line 96 does not
%                 allow braces inside a "metabolites" object
%       EXPECTED: the model is read with S = [-1; 1]
%       LINES: 96
%     - DEFECT: an empty model cannot be read
%       SEVERITY: limitation
%       TRIGGER: the file of an empty cobrapy model, {"metabolites":[],"reactions":[],"genes":[],"id":"e"}
%       OBSERVED: MATLAB R2025a, 2026-11-23: error "Input #2 expected to be a cell array, was
%                 double instead." at line 62: jsondecode returns an empty double for [], which
%                 is neither a struct nor a cell array
%       EXPECTED: a model with no metabolites, reactions and genes
%       LINES: 62, 74
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadCobrapyJSONModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% every JSON file is written in a temporary folder removed at the end
tmpDir = tempname;
mkdir(tmpDir);
jsonFile = fullfile(tmpDir, 'model.json');
% the backslash of JSON escapes is written as char(92) so that no editor or tool changes it
bs = char(92);

%% objects with different keys (cell arrays), all attributes, a string file name, printLevel 1

% A_e <-> (EX_A), A_e -> 2.5 B_c (R1), R2: B_c -> C_c with an empty compartment and a null
% charge. Metabolites and reactions have different keys, so jsondecode returns cell arrays
writeJson(jsonFile, ['{"metabolites": [' ...
    '{"id": "A_e", "name": "A", "compartment": "e", "charge": -1, "formula": "C2H3O2"},' ...
    '{"id": "B_c", "name": "B", "compartment": "c", "charge": 2},' ...
    '{"id": "C_c", "name": "", "compartment": "", "charge": null, "formula": ""}],' ...
    '"reactions": [' ...
    '{"id": "EX_A", "name": "exchange", "metabolites": {"A_e": -1.0}, "lower_bound": -10, ' ...
    '"upper_bound": 1000, "gene_reaction_rule": ""},' ...
    '{"id": "R1", "name": "r1", "metabolites": {"A_e": -1, "B_c": 2.5}, "lower_bound": 0, ' ...
    '"upper_bound": 1000, "gene_reaction_rule": "g1 or g2", "objective_coefficient": 1, ' ...
    '"subsystem": "S1"},' ...
    '{"id": "R2", "metabolites": {"B_c": -1e0, "C_c": 1.5E-1}, "lower_bound": -5, ' ...
    '"upper_bound": 5, "gene_reaction_rule": "g2 and g1", "objective_coefficient": 0, ' ...
    '"subsystem": ""}],' ...
    '"genes": [{"id": "g1", "name": "gene one"}, {"id": "g2"}], ' ...
    '"id": "test", "name": "test model", ' ...
    '"compartments": {"e": "extracellular", "c": "cytosol"}, "version": "1"}']);
% printLevel 1 prints "Model test read: 3 metabolites, 3 reactions." (not captured)
model = readCobrapyJSONModel(string(jsonFile), 'printLevel', 1);
% metabolite attributes: empty and null values keep the defaults ('' and charge 0)
assert(isequal(model.mets, {'A_e'; 'B_c'; 'C_c'}));
assert(isequal(model.metNames, {'A'; 'B'; ''}));
assert(isequal(model.metFormulas, {'C2H3O2'; ''; ''}));
assert(isequal(model.metCharges, [-1; 2; 0]));
assert(isequal(model.metComps, {'e'; 'c'; ''}));
% reaction attributes: an absent name and an empty subsystem keep ''
assert(isequal(model.rxns, {'EX_A'; 'R1'; 'R2'}));
assert(isequal(model.rxnNames, {'exchange'; 'r1'; ''}));
assert(isequal(model.lb, [-10; 0; -5]) && isequal(model.ub, [1000; 1000; 5]));
assert(isequal(model.c, [0; 1; 0]));
assert(isequal(model.subSystems, {''; 'S1'; ''}));
% stoichiometry from the text: 1.5E-1 and -1e0 are read as numbers; the values are exact
% decimal conversions of the written strings, compared with a tolerance of 1e-12
assert(issparse(model.S) && isequal(size(model.S), [3 3]));
assert(max(max(abs(full(model.S) - [-1 -1 0; 0 2.5 -1; 0 0 0.15]))) < 1e-12);
% fixed fields: b = 0, equality constraints, maximisation
assert(isequal(model.b, zeros(3, 1)) && isequal(model.csense, repmat('E', 3, 1)) && strcmp(model.osenseStr, 'max'));
% genes (different keys: cell array) and rules generated from the grRules
assert(isequal(model.genes, {'g1'; 'g2'}));
assert(isequal(model.grRules, {''; 'g1 or g2'; 'g2 and g1'}));
assert(isequal(model.rules, {''; 'x(1) | x(2)'; 'x(2) & x(1)'}));
assert(strcmp(model.modelID, 'test') && strcmp(model.modelName, 'test model'));

%% objects with the same keys (struct arrays) and absent optional attributes

% all metabolites, reactions and genes have identical keys, so jsondecode returns struct
% arrays. The reactions have no name, bounds, objective, subsystem or rule: bounds and
% objective default to 0. No reaction has a rule, so rules are initialised empty
writeJson(jsonFile, ['{"metabolites": [{"id": "A_e"}, {"id": "B_e"}],' ...
    '"reactions": [{"id": "R1", "metabolites": {"A_e": -1, "B_e": 1}},' ...
    '{"id": "R2", "metabolites": {"B_e": -2}}],' ...
    '"genes": [{"id": "g1"}, {"id": "g2"}], "id": "", "name": ""}']);
model = readCobrapyJSONModel(jsonFile);
assert(isequal(model.mets, {'A_e'; 'B_e'}) && isequal(model.rxns, {'R1'; 'R2'}));
assert(isequal(model.metNames, {''; ''}) && isequal(model.metCharges, [0; 0]));
assert(isequal(model.lb, [0; 0]) && isequal(model.ub, [0; 0]) && isequal(model.c, [0; 0]));
assert(isequal(model.rxnNames, {''; ''}) && isequal(model.subSystems, {''; ''}));
% integer coefficients, exact
assert(isequal(full(model.S), [-1 0; 1 -2]));
assert(isequal(model.genes, {'g1'; 'g2'}));
assert(isequal(model.grRules, {''; ''}) && isequal(model.rules, {''; ''}));
% empty id and name keep ''
assert(strcmp(model.modelID, '') && strcmp(model.modelName, ''));

%% JSON escapes in identifiers and a reaction with an empty stoichiometry

% identifiers A/x (written A\/x) and B"q (written B\"q): jsondecode decodes them, and the
% stoichiometry parsed from the raw text must decode them the same way to find the
% metabolites. R2 has an empty "metabolites" object, so its column of S is zero
idSlash = ['A' bs '/x'];
idQuote = ['B' bs '"q'];
writeJson(jsonFile, ['{"metabolites": [{"id": "' idSlash '"}, {"id": "' idQuote '", "name": "q"}],' ...
    '"reactions": [{"id": "R1", "metabolites": {"' idSlash '": -1, "' idQuote '": 3}, ' ...
    '"lower_bound": 0, "upper_bound": 1},' ...
    '{"id": "R2", "metabolites": {}, "lower_bound": 0, "upper_bound": 1}]}']);
model = readCobrapyJSONModel(jsonFile);
assert(isequal(model.mets, {'A/x'; 'B"q'}));
assert(isequal(full(model.S), [-1 0; 3 0]));

%% no genes field, an empty genes list, and a rule naming a gene not listed in genes

% no "genes" key and no "id"/"name" keys: genes is an empty 0 x 1 cell, modelID and
% modelName stay ''
writeJson(jsonFile, ['{"metabolites": [{"id": "A"}],' ...
    '"reactions": [{"id": "R1", "metabolites": {"A": 1}, "gene_reaction_rule": ""}]}']);
model = readCobrapyJSONModel(jsonFile);
assert(iscell(model.genes) && isequal(size(model.genes), [0 1]));
assert(isequal(model.rules, {''}));
assert(strcmp(model.modelID, '') && strcmp(model.modelName, ''));
% an empty "genes" list gives the same empty gene list
writeJson(jsonFile, ['{"metabolites": [{"id": "A"}],' ...
    '"reactions": [{"id": "R1", "metabolites": {"A": 1}}], "genes": []}']);
model = readCobrapyJSONModel(jsonFile);
assert(iscell(model.genes) && isequal(size(model.genes), [0 1]));
% the rule names g2, which genes does not list: generateRules (printLevel 0, no warning)
% appends g2 to genes and the rule points to it
writeJson(jsonFile, ['{"metabolites": [{"id": "A"}],' ...
    '"reactions": [{"id": "R1", "metabolites": {"A": 1}, "gene_reaction_rule": "g1 and g2"}],' ...
    '"genes": [{"id": "g1"}]}']);
model = readCobrapyJSONModel(jsonFile);
assert(isequal(model.genes, {'g1'; 'g2'}));
assert(isequal(model.rules, {'x(1) & x(2)'}));

%% errors raised by the function, with their exact messages

% missing file
missingFile = fullfile(tmpDir, 'missing.json');
assert(verifyCobraFunctionError('readCobrapyJSONModel', 'inputs', {missingFile}, ...
    'testMessage', sprintf('File %s not found.', missingFile)));
% JSON without a "reactions" key and JSON without a "metabolites" key
writeJson(jsonFile, '{"metabolites": []}');
assert(verifyCobraFunctionError('readCobrapyJSONModel', 'inputs', {jsonFile}, ...
    'testMessage', sprintf('%s is not a cobrapy JSON model.', jsonFile)));
writeJson(jsonFile, '{"reactions": []}');
assert(verifyCobraFunctionError('readCobrapyJSONModel', 'inputs', {jsonFile}, ...
    'testMessage', sprintf('%s is not a cobrapy JSON model.', jsonFile)));
% a reaction without a "metabolites" object: one stoichiometry for two reactions
writeJson(jsonFile, ['{"metabolites": [{"id": "A_e"}],' ...
    '"reactions": [{"id": "R1"}, {"id": "R2", "metabolites": {"A_e": 1}}]}']);
assert(verifyCobraFunctionError('readCobrapyJSONModel', 'inputs', {jsonFile}, ...
    'testMessage', 'The number of reaction stoichiometries (1) differs from the number of reactions (2).'));
% a stoichiometry naming a metabolite that the model does not define
writeJson(jsonFile, ['{"metabolites": [{"id": "A_e"}],' ...
    '"reactions": [{"id": "R1", "metabolites": {"A_e": -1, "X_e": 1}}]}']);
assert(verifyCobraFunctionError('readCobrapyJSONModel', 'inputs', {jsonFile}, ...
    'testMessage', 'Metabolite X_e of reaction R1 is not defined in the model.'));

%% arguments refused by the input parser

% the file name must be text and printLevel numeric or logical (the messages are MATLAB's
% inputParser messages, so only the error is checked)
assert(verifyCobraFunctionError('readCobrapyJSONModel', 'inputs', {1}));
assert(verifyCobraFunctionError('readCobrapyJSONModel', 'inputs', {jsonFile, 'printLevel', 'high'}));

% remove the temporary folder and change the directory
rmdir(tmpDir, 's');
cd(currentDir)

function writeJson(fileName, text)
% writes text verbatim (no format conversion) to fileName
fid = fopen(fileName, 'w');
fprintf(fid, '%s', text);
fclose(fid);
end
