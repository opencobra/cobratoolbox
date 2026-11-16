% The COBRAToolbox: testReadBooleanRegModel.m
%
% Purpose:
%     - readBooleanRegModel reads a Boolean regulatory network (spreadsheet with the columns
%       name, rule and type) and returns its metabolite, regulator and target rules, with the
%       metabolite rules linked to the exchange and internal reactions of a metabolic model and
%       the regulator and target rules rewritten in terms of metState and regState. The test
%       writes one spreadsheet with every rule type to a tempname folder and checks every
%       output field against values worked out by hand from the rules and the model.
%
% Function under test:
%     src/base/io/utilities/readBooleanRegModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a three-reaction createModel model and a spreadsheet in a tempname folder; no
%     solver.
%
% Coverage exemptions:
%     Line 47: the default file iMHruletest.xls is not distributed (defect below), and an .xls
%     copy written by MATLAB cannot be read back here: without Excel, xlsread reports "XLS File
%     contains unicode text which is not yet supported" (MATLAB R2025a on Linux), and a
%     spreadsheet of another format saved under the .xls name is "not in recognized format".
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A file without a rule of every type stops with an error
%       SEVERITY: limitation
%       TRIGGER: readBooleanRegModel(model, file) with a file that has xcm and reg rows only
%       OBSERVED: error "Unrecognized field name "icmRules"." at line 131; files without
%         metabolite, pool, regulator or target rows fail the same way at lines 98, 146, 150
%         and 177, because those fields are created only inside the loops
%       EXPECTED: empty fields for the rule types the file does not contain
%       LINES: 98, 131, 146, 150, 177
%     - DEFECT: The default file iMHruletest.xls is not distributed
%       SEVERITY: limitation
%       TRIGGER: readBooleanRegModel(model) in a folder without iMHruletest.xls
%       OBSERVED: no file of that name exists in the repository, so the call with one argument
%         fails in xlsread unless the user provides the file in the current folder
%       EXPECTED: a distributed example file, or a required fileName argument
%       LINES: 47
%     - DEFECT: Pool members written with spaces around + are not found
%       SEVERITY: limitation
%       TRIGGER: an xcp row with the rule 'a[e] + b[e] + zz'
%       OBSERVED: the members are split with the spaces kept ('a_e ', ' b_e ', ' zz'), so
%         none matches a metabolite name ("pool1: metabolite a_e  not in regulatory network
%         model") and the pool is empty; the test writes the members without spaces
%       EXPECTED: the members trimmed and matched (pool [2; 1])
%       LINES: 76, 139
%     - DEFECT: The message for a missing exchange reaction names the wrong metabolite
%       SEVERITY: cosmetic
%       TRIGGER: an xcm row whose exchange reaction is in the model followed by one whose
%         reaction is not
%       OBSERVED: line 110 indexes the xcm rows with the position i in the list of missing
%         reactions, so the name of the first xcm row is printed with the missing reaction;
%         the test lists the missing reaction first, where both positions agree
%       EXPECTED: the name of the row whose reaction is missing
%       LINES: 110
%     - DEFECT: The message for a missing internal reaction has no line break
%       SEVERITY: cosmetic
%       TRIGGER: an icm rule naming a reaction that is not in the model
%       OBSERVED: "d_c: rxn R9 not found in the metabolic model" is followed on the same line
%         by the next message
%       EXPECTED: one message per line, as the other messages
%       LINES: 125
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadBooleanRegModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% metabolic model: R1 (index 1), R2 (index 2) and the exchange EX_a (index 3)
model = createModel({'R1', 'R2', 'EX_a'}, {'R1', 'R2', 'EX_a'}, ...
    {'a[c] -> b[c]', 'b[c] -> c[c]', 'a[c] <=> '});

% regulatory network with every rule type. Metabolite rows come first, so the metabolite
% indices are b_e 1, a_e 2, c_e 3, d_c 4, e_c 5, pool1 6, pool2 7; regulators r1 1, r2 2, r3 3
ruleSheet = {'name', 'rule', 'type'; ...
    'b[e]', 'EX-zz', 'xcm'; ...            % exchange reaction not in the model (message)
    'a[e]', 'EX_a', 'xcm'; ...             % exchange reaction 3
    'c[e]', 'NA', 'xcm'; ...               % no exchange reaction, no message
    'd[c]', 'if R1 | R9', 'icm'; ...       % 'if ' removed; R9 not in the model (message)
    'e[c]', 'R2 | =0', 'icm'; ...          % '=0' is not reported
    'pool1', 'a[e]+b[e]+zz', 'xcp'; ...    % zz is not a metabolite (message)
    'pool2', 'd[c]', 'icp'; ...
    'r1', 'a[e] & ~r2', 'reg'; ...         % a metabolite and a regulator
    'r2', 'qq | d[c]', 'regc'; ...         % qq unknown (message): the parsed rule is empty
    'r3', 'NA', 'reg'; ...                 % NA: empty rule, no message
    'g1', 'r1 | e[c]', 'tar'; ...
    'g2', 'ww', 'tar'; ...                 % ww unknown (message)
    'g3', 'NA', 'tar'};

tmpDir = tempname;
mkdir(tmpDir);
ruleFile = fullfile(tmpDir, 'rules.xlsx');
writecell(ruleSheet, ruleFile);

%% metabolite rules: names, rules and types, with [x] replaced by _x and 'if ' removed

regModel = readBooleanRegModel(model, ruleFile);
assert(isequal(regModel.mets.name, {'b_e'; 'a_e'; 'c_e'; 'd_c'; 'e_c'; 'pool1'; 'pool2'}));
assert(isequal(regModel.mets.type, {'xcm'; 'xcm'; 'xcm'; 'icm'; 'icm'; 'xcp'; 'icp'}));
assert(isequal(regModel.mets.rule(1:5), {'EX-zz'; 'EX_a'; 'NA'; 'R1 | R9'; 'R2 | =0'}));
% pool rules are split at + into the member names
assert(isequal(regModel.mets.rule{6}, {'a_e'; 'b_e'; 'zz'}));
assert(isequal(regModel.mets.rule{7}, {'d_c'}));

%% extracellular metabolites: index of the exchange reaction ('-' read as '_'), 0 if absent

assert(isequal(regModel.mets.excInd, [0; 3; 0]));

%% intracellular metabolites: reactions found are replaced by fluxVector(<index>)

% R1 and R2 are reactions 1 and 2; R9 and '=0' are not in the model and keep x(2)
assert(isequal(regModel.mets.icmRules, {'fluxVector(1) | x(2)'; 'fluxVector(2) | x(2)'}));

%% pools: indices of the member metabolites, members not in the network are dropped

assert(isequal(regModel.mets.pool{1}, [2; 1]));
assert(isequal(regModel.mets.pool{2}, 4));
assert(isequal(size(regModel.mets.pool), [2, 1]));

%% regulator rules: metState/regState indices; any unknown element empties the rule

assert(isequal(regModel.regs.name, {'r1'; 'r2'; 'r3'}));
assert(isequal(regModel.regs.rule, {'a_e & ~r2'; 'qq | d_c'; 'NA'}));
assert(isequal(regModel.regs.comp{1}, {'a_e', 'r2'}));
assert(isequal(regModel.regs.comp{2}, {'qq', 'd_c'}));
assert(isequal(regModel.regs.comp{3}, {'NA'}));
assert(isequal(regModel.regs.ruleParsed{1}, 'metState(2) & ~regState(2)'));
assert(isempty(regModel.regs.ruleParsed{2}));
assert(isempty(regModel.regs.ruleParsed{3}));

%% target rules: same rewriting as the regulator rules

assert(isequal(regModel.tars.name, {'g1'; 'g2'; 'g3'}));
assert(isequal(regModel.tars.rule, {'r1 | e_c'; 'ww'; 'NA'}));
assert(isequal(regModel.tars.comp{1}, {'r1', 'e_c'}));
assert(isequal(regModel.tars.ruleParsed{1}, 'regState(1) | metState(5)'));
assert(isempty(regModel.tars.ruleParsed{2}));
assert(isempty(regModel.tars.ruleParsed{3}));

% remove the temporary folder and change the directory
rmdir(tmpDir, 's');
cd(currentDir)
