% The COBRAToolbox: testModel2xls.m
%
% Purpose:
%     - model2xls writes a model to an Excel workbook with a 'Reaction List' sheet (one column
%       per reaction field present: identifiers, names, formulas, GPR rules, bounds as text,
%       objective, subsystems) and a 'Metabolite List' sheet (identifiers, names, formulas,
%       charges, compartment names). This test writes small hand-built models and reads the
%       sheets back: the formulas are those of printRxnFormula, the GPR rules those of
%       creategrRulesField, the objective is negated for a minimisation, nested subsystems are
%       joined with ';', strings longer than 5000 characters are cut, metabolites without a
%       compartment get [u] (Unknown) and compartment names come from the model, the given
%       symbols or getDefaultCompartments.
%
% Function under test:
%     src/base/io/utilities/model2xls.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - file output for hand-built models of two or three reactions, no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: compSymbols without compNames stops the call
%       SEVERITY: limitation
%       TRIGGER: model2xls(createModel({'R1'}, {''}, {'a[c] -> b[c]'}), fileName, {'c'})
%       OBSERVED: MATLAB R2025a: "Not enough input arguments." at line 173; compNames, documented
%       as optional, is read whenever compSymbols is given
%       EXPECTED: the documentation to say that compNames must be given with compSymbols, or
%       the symbols used as names
%       LINES: 87-94, 173
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testModel2xls'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% setupxlwrite adds the xlwrite folders and Java libraries: save both to restore them
pathBefore = path;
javaPathBefore = javaclasspath('-dynamic');

% all workbooks are written to a temporary folder
outputFolder = tempname;
mkdir(outputFolder);

%% default compartments, GPR rules, minimisation and nested subsystems

model = createModel({'R1'; 'EX_a'}, {'reaction one'; 'exchange of a'}, ...
    {'a[c] -> b[c]'; 'a[c] <=> '}, 'grRuleList', {'g1 or g2'; ''}, 'printLevel', 0);
model.osenseStr = 'min';
model.c = [1; 0];
model.subSystems = {{'S1', 'S2'}; {'S3'}};
fileName = [outputFolder filesep 'defaults.xls'];
model2xls(model, fileName);

[~, ~, reactionSheet] = xlsread(fileName, 'Reaction List');
expectedFormulas = printRxnFormula(model, 'printFlag', 0);
expectedRules = creategrRulesField(model);
% header row: the fields present, in the documented order
assert(isequal(reactionSheet(1, :), {'Abbreviation', 'Description', 'Reaction', 'GPR', ...
    'Lower bound', 'Upper bound', 'Objective', 'Subsystem'}));
% exact: identifiers, names and formulas copied; bounds and objective written as text, the
% objective negated for a minimisation; nested subsystems joined with ';'
assert(isequal(reactionSheet(2:end, 1), model.rxns));
assert(isequal(reactionSheet(2:end, 2), model.rxnNames));
assert(isequal(reactionSheet(2:end, 3), expectedFormulas));
assert(isequal(reactionSheet{2, 4}, expectedRules.grRules{1}));
% an empty GPR rule is an empty cell, read back as NaN
assert(isnan(reactionSheet{3, 4}));
assert(isequal(reactionSheet(2:end, 5:8), {'0', '1000', '-1', 'S1;S2'; '-1000', '1000', '0', 'S3'}));

[~, ~, metaboliteSheet] = xlsread(fileName, 'Metabolite List');
[defaultSymbols, defaultNames] = getDefaultCompartments();
% exact: identifiers and names, compartment name of [c] from getDefaultCompartments
assert(isequal(metaboliteSheet(1, :), {'Abbreviation', 'Description', 'Compartment'}));
assert(isequal(metaboliteSheet(2:end, 1:2), [model.mets, model.metNames]));
assert(isequal(metaboliteSheet(2:end, 3), ...
    repmat(defaultNames(strcmp(defaultSymbols, 'c')), 2, 1)));

%% compartments of the model, a metabolite without compartment, charges and a long name

model = createModel({'R1'; 'R2'}, {repmat('n', 1, 5001); 'second'}, ...
    {'a[e] -> b[e]'; 'b[e] -> x[e]'}, 'printLevel', 0);
% x loses its compartment; without rules or grRules no GPR column is written
model.mets{3} = 'x';
model = rmfield(model, intersect(fieldnames(model), {'rules'; 'grRules'}));
model.osenseStr = 'max';
model.c = [0; 1];
model.subSystems = {'S1'; 'S2'};
model.comps = {'e'};
model.compNames = {'extracellular'};
model.metCharges = [0; -1; 2];
fileName = [outputFolder filesep 'modelCompartments.xls'];
model2xls(model, fileName);

[~, ~, reactionSheet] = xlsread(fileName, 'Reaction List');
% exact: the 5001-character name is cut to 5000; the objective of a maximisation is kept;
% subsystems that are not all nested are written as given; without rules there is no GPR
assert(isequal(reactionSheet(1, :), {'Abbreviation', 'Description', 'Reaction', ...
    'Lower bound', 'Upper bound', 'Objective', 'Subsystem'}));
assert(isequal(reactionSheet{2, 2}, repmat('n', 1, 5000)));
assert(isequal(reactionSheet(2:end, 6), {'0'; '1'}));
assert(isequal(reactionSheet{2, 7}, 'S1'));

[~, ~, metaboliteSheet] = xlsread(fileName, 'Metabolite List');
% exact: x has no compartment, so it is written as x[u] in the compartment 'Unknown'; the
% names of [e] come from model.compNames; charges are written as numbers
assert(isequal(metaboliteSheet(1, :), {'Abbreviation', 'Description', 'Charge', 'Compartment'}));
assert(isequal(metaboliteSheet(2:end, 1), {'a[e]'; 'b[e]'; 'x[u]'}));
assert(isequal(metaboliteSheet(2:end, 3), {0; -1; 2}));
assert(isequal(metaboliteSheet(2:end, 4), {'extracellular'; 'extracellular'; 'Unknown'}));

%% compartments given as inputs, all metabolites with a compartment

model = createModel({'R1'}, {'only'}, {'a[x] -> b[x]'}, 'printLevel', 0);
fileName = [outputFolder filesep 'givenCompartments.xls'];
model2xls(model, fileName, {'x'}, {'compartment x'});

[~, ~, metaboliteSheet] = xlsread(fileName, 'Metabolite List');
% exact: the given name of [x] is used (the cytosol is added to the symbols only as a
% fallback and no metabolite uses it)
assert(isequal(metaboliteSheet(2:end, 1), {'a[x]'; 'b[x]'}));
assert(isequal(metaboliteSheet(2:end, end), {'compartment x'; 'compartment x'}));

% remove the temporary folder, restore the MATLAB and Java paths and change the directory
rmdir(outputFolder, 's');
path(pathBefore);
addedJars = setdiff(javaclasspath('-dynamic'), javaPathBefore);
if ~isempty(addedJars)
    javarmpath(addedJars{:});
end
cd(currentDir)
