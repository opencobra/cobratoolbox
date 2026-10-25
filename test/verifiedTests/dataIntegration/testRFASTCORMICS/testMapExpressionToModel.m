% The COBRAToolbox: testMapExpressionToModel.m
%
% Purpose:
%     - mapExpressionToModel maps discretised expression data to the genes of a model through a
%     dictionary of identifiers and then to reactions through the gene rules, printing the number of
%     matched genes.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/transcriptomics/rFASTCORMICS/mapExpressionToModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 74-78, the fallbacks for dictionary columns that cannot be assigned directly: the
%     dictionary is converted to a cell array first, so every column can be assigned and the
%     fallbacks cannot be reached.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Invalid input is reported by a message and leaves the output unassigned
%       SEVERITY: error
%       TRIGGER: a dictionary that is not a table, row names with empty entries, or row names that
%         match nothing in the dictionary, when the output is requested
%       OBSERVED: the function prints a message (or nothing for the no-match case) and returns
%         before assigning mapping, so a call with an output argument stops with "Output argument
%         mapping not assigned"
%       EXPECTED: an error with a clear message, or an empty mapping
%       LINES: 35-50
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMapExpressionToModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% model with three genes and three reactions: r1 = g1 and g2, r2 = g3, r3 without rule
model.genes = {'g1'; 'g2'; 'g3'};
model.rxns = {'r1'; 'r2'; 'r3'};
model.rules = {'x(1) & x(2)'; 'x(3)'; ''};

% dictionary: a table whose columns hold identifiers (probe names and gene names)
dico = table({'p1'; 'p2'; 'p3'}, {'g1'; 'g2'; 'g3'}, 'VariableNames', {'probe', 'gene'});
rownames = {'p1'; 'p2'; 'p3'};
data = [1 -1; 1 1; -1 1];

%% expression of genes and reactions

text = evalc('mapping = mapExpressionToModel(model, data, dico, rownames);');
assert(contains(text, '3 of 3 genes of the model matched'));
% r1: min of g1 (1, -1) and g2 (1, 1); r2: g3 (-1, 1); r3 has no rule
assert(isequal(mapping, [1 -1; -1 1; 0 0]));

%% genes with transcript suffixes can be matched after removing the suffix

transcriptModel = model;
transcriptModel.genes = {'g1.1'; 'g2.1'; 'g3.1'};
text = evalc('mapping = mapExpressionToModel(transcriptModel, data, dico, rownames, 1);');
assert(contains(text, 'Transcripts will temporarily be removed'));
assert(isequal(mapping, [1 -1; -1 1; 0 0]));
% without the option the suffixed genes are not found
text = evalc('mapping = mapExpressionToModel(transcriptModel, data, dico, rownames);');
assert(contains(text, '0 of 3 genes of the model matched'));
assert(all(mapping(:) == 0));

%% several probes for one gene take the highest value

dico2 = table({'p1'; 'p2'; 'p3'}, {'g1'; 'g1'; 'g3'}, 'VariableNames', {'probe', 'gene'});
text = evalc('mapping = mapExpressionToModel(model, data, dico2, rownames);');
% g1 gets the maximum of its two probes (1,-1) and (1,1) = (1,1); g2 has no probe, so r1 = min(g1, 0)
assert(contains(text, '2 of 3 genes of the model matched'));
assert(isequal(mapping(2, :), [-1 1]));

%% invalid input is reported and no output is produced

% the dictionary must be a table
notATable = {'p1'};
text = evalc('mapExpressionToModel(model, data, notATable, rownames);');
assert(contains(text, 'dico must be a table'));
% row names must not be empty
emptyName = {'p1'; ''; 'p3'};
text = evalc('mapExpressionToModel(model, data, dico, emptyName);');
assert(contains(text, 'rownames contains empty entries'));
% requesting the output in these cases stops with an error (see the known defect in the header)
failed = false;
try
    evalc('result = mapExpressionToModel(model, data, notATable, rownames);');
catch
    failed = true;
end
assert(failed);
% no match between the row names and the dictionary: nothing is printed
otherNames = {'q1'; 'q2'; 'q3'};
text = evalc('mapExpressionToModel(model, data, dico, otherNames);');
assert(isempty(text));

% change the directory
cd(currentDir)
