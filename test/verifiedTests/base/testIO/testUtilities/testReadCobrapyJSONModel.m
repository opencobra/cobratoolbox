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
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): valid cobrapy files stop the call (defects below), graded error by the lead
%       under research R5's consistency rule (a documented input that fails when used), so this
%       file makes no assertion about the function. The full test described above, which
%       passes on the current code for every other input and reaches every line, is kept in
%       specs/20261113-142115-test-backfill-tiers/inventory/review/quarantined-full-tests/ as
%       the starting point once the defects are fixed.
%
% Function under test:
%     src/base/io/utilities/readCobrapyJSONModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - builds models from hand-written files without a solver.
%
% Coverage exemptions:
%     every line - readCobrapyJSONModel is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: metabolite identifiers written with a \u escape are not found
%       SEVERITY: error
%       TRIGGER: a metabolite identifier with a non-ASCII character, which Python's json.dump
%                (ensure_ascii, the cobrapy default) writes as a \u escape, for example
%                {"metabolites":[{"id":"A\u00e9"},{"id":"B"}],"reactions":[{"id":"R1",
%                "metabolites":{"A\u00e9":-1,"B":1},"lower_bound":0,"upper_bound":1}]}
%       OBSERVED: MATLAB R2025a, 2026-11-23: error "Metabolite Au00e9 of reaction R1 is not
%                 defined in the model." jsondecode decodes the identifier to A followed by
%                 char 233, but line 106 only removes the backslash of an escape, giving Au00e9
%       EXPECTED: the model is read with S = [-1; 1], as the NOTE of the help says identifiers
%                 are kept exactly as written
%       LINES: 106
%     - DEFECT: a metabolite identifier containing a brace makes the reaction stoichiometry unreadable
%       SEVERITY: error
%       TRIGGER: a metabolite identifier with { or }, for example
%                {"metabolites":[{"id":"A{x}"},{"id":"B"}],"reactions":[{"id":"R1",
%                "metabolites":{"A{x}":-1,"B":1},"lower_bound":0,"upper_bound":1}]}
%       OBSERVED: MATLAB R2025a, 2026-11-23: error "The number of reaction stoichiometries (0)
%                 differs from the number of reactions (1)." The pattern of line 96 does not
%                 allow braces inside a "metabolites" object
%       EXPECTED: the model is read with S = [-1; 1]
%       LINES: 96
%     - DEFECT: an empty model cannot be read
%       SEVERITY: error
%       TRIGGER: the file of an empty cobrapy model, {"metabolites":[],"reactions":[],"genes":[],"id":"e"}
%       OBSERVED: MATLAB R2025a, 2026-11-23: error "Input #2 expected to be a cell array, was
%                 double instead." at line 62: jsondecode returns an empty double for [], which
%                 is neither a struct nor a cell array
%       EXPECTED: a model with no metabolites, reactions and genes
%       LINES: 62, 74
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.
%     - Converted to the quarantine layout by the lead (severity error, research R5), 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadCobrapyJSONModel'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
