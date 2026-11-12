% The COBRAToolbox: testSurfNet.m
%
% Purpose:
%     - testSurfNet tests the functionality of surfNet
%       and compares it to expected data.
%
% Function under test:
%     src/analysis/exploration/surfNet.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation (the flux vectors come from optimizeCbModel); ecoli_core_model loaded
%     through getDistributedModel, LP solver required.
%
% Coverage exemptions:
%     Lines 348-349: unreachable, the assignment above them sets metF only where rxnF is false and
%       then rxnF only where metF is false, so a field is never marked as both.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Searching with a flux vector stops with an error
%       SEVERITY: error
%       TRIGGER: a query that is no identifier and matches reactions, together with a flux vector,
%         for example surfNet(model, 'glucose', 't', 0.6, 'flux', solution.x)
%       OBSERVED: the search listing reads fluxLocal(id) although id is only set after the search,
%         so the call fails with "Unrecognized function or variable 'id'"
%       EXPECTED: the matching reactions are listed with their fluxes
%       LINES: 522, 543, 566
%     - DEFECT: The message for a partial field name shows a literal backslash n
%       SEVERITY: cosmetic
%       TRIGGER: a partial field name in printFields that matches several fields, for example 'met'
%       OBSERVED: the message starts with the two characters backslash and n, because error is
%         called with the text as its only argument, which is not processed as a format
%       EXPECTED: the message starts on a new line
%       LINES: 319, 333
%
% Authors:
%     - Lemmer El Assal March 2017
%     - Siu Hung Joshua Chan July 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSurfNet'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
prepareTest('needsLP', true);

fprintf(' -- Running testSurfNet ... ');

model = getDistributedModel('ecoli_core_model.mat');

% generate flux data for testing
s = optimizeCbModel(model, 'max', 'one');
model2 = changeRxnBounds(model, {'EX_glc(e)'; 'EX_fru(e)'}, [0; -10], {'L'; 'L'});
s2 = optimizeCbModel(model2, 'max', 'one');
fluxMatrix = [s.x, s2.x];
rxnsDiff = model.rxns(abs(fluxMatrix(:, 1) - fluxMatrix(:, 2)) > 1e-6);
[m, n] = size(model2.S);

% remove old generated file
if exist('surfNet.txt', 'file')
    delete('surfNet.txt');
end

% check normal functionalities
diary('surfNet.txt');

% start with a metabolite
metrxn = '13dpg[c]';
surfNet(model, metrxn);
% continue with a reaction (through clicking only)
surfNet([], 'GAPD', 0, NaN, 0, 1, [], 0);
% continue with a metabolite (through clicking only)
surfNet([], 'g3p[c]', 0, NaN, 0, 1, [], 0);
% print objective reactions given no second input
surfNet(model);
% print a list of reactions without showing details of metabolites
surfNet(model, {'GAPD'; 'FBA'}, [], [], [], 0);
% print *.metNames in reaction formulae
surfNet(model, {'13dpg[c]'; 'GAPD'}, 1);
% show previous steps (through clicking only)
surfNet([], [], 1, NaN, 0, 1, [], 0, [], struct('showPrev', true));

% print with a fixed number of characters per line
surfNet(model, [model.mets(1:10)'; model.rxns(1:10)'], [], [], [], 0, [], 60);
% show previous steps (through clicking only)
surfNet([], [], 0, NaN, 0, 0, [], 60, [], struct('showPrev', true));

% print connected reactions and the corresponding fluxes in a flux vector
surfNet(model, 'pyr[c]', [], s.x, 0);
% print connected reactions with nonzero fluxes only in a flux vector
surfNet(model, 'pyr[c]', [], s.x);
% compare multiple flux vectors
surfNet(model, rxnsDiff, [], fluxMatrix, [], 0);
surfNet(model, rxnsDiff, [], fluxMatrix', [], 0);

% print customized fields
[model2.newRxnProp, model2.newMetProp] = deal(cell(1, n), cell(1, m));
model2.newRxnProp{findRxnIDs(model2, 'GAPD')} = {'a', 'b'};  % cellstr with cells
model2.newMetProp{findMetIDs(model2, '13dpg[c]')} = {'c', 'd'};
[model2.newRxnProp2, model2.newMetProp2] = deal(char('C' * ones(n, 1)), char('E' * ones(m, 1)));  % character arrays
surfNet(model2, {'13dpg[c]'; 'GAPD'}, [], [], [], [], {'metFormulas', 'subSystems', ...
    'grRules', 'b', 'c', 'ub', 'newRxnProp', 'newMetProp', 'newRxnProp2', 'newMetProp2'});
surfNet(model2, {'13dpg[c]'; 'GAPD'}, [], [], [], [], 'lb');

% starting with a gene
surfNet(model, 'b1241')
% continue with another gene shown in the reactions
surfNet([], 'b1478', 0, NaN, 0, 1, [], 0);

% test the search function
surfNet(model, 'glucose')
surfNet(model, 'glucose', 't', 0.6)  % with a more relaxed threshold
surfNet(model, 'ATP')  % a query term with multiple matches in the same object
diary off;

% load the text files
[text1, text2] = deal('');
f = fopen('refData_surfNet.txt', 'r');
l = fgets(f);
while ~isequal(l, -1)
    text1 = [text1, l];
    l = fgets(f);
end
fclose(f);

f = fopen('surfNet.txt', 'r');
l = fgets(f);
while ~isequal(l, -1)
    text2 = [text2, l];
    l = fgets(f);
end
fclose(f);
% locations of linebreaks not constant. Replace linebreaks and consecutive spaces with single space
text1 = regexprep(text1, '\s*', ' ');
text2 = regexprep(text2, '\s*', ' ');

% remove the generated file
delete('surfNet.txt');

% compare the similarity of text using a simple scheme
% (no need to solve a DP here, the two strings are supposed to be highly similar)
[j1, j2, match] = deal(1, 1, 0);
while j1 <= numel(text1) && j2 <= numel(text2)
    if ~strcmp(text1(j1), text2(j2))
        % find the next closest identical character
        [j1skip, j2skip] = deal(1);
        while j2 + j2skip <= numel(text2) && ~strcmp(text1(j1), text2(j2 + j2skip))
            j2skip = j2skip + 1;
        end
        while j1 + j1skip <= numel(text1) && ~strcmp(text1(j1 + j1skip), text2(j2))
           j1skip = j1skip + 1;
        end
        % take the closer identical character from the two strings
        [j1, j2] = deal(j1 + (j1skip <= j2skip) * j1skip, j2 + (j1skip > j2skip) * j2skip);
    end
    match = match + 1;
    [j1, j2] = deal(j1 + 1, j2 + 1);
end
% subtract the last false match if the comparison is terminated due to the
% end of the strings rather than match found
match = match - (j1 == numel(text1) + 2 | j2 == numel(text2) + 2);
score = ((match / numel(text1)) * (match / numel(text2))) ^ 0.5;

fprintf('Compare the printed with the expected results ...\n')
assert(score > 1 - 1e-2);  % some mismatches due to linebreaks and space
fprintf('\nSuccess. Finish testing normal functionalities of surfNet.\n')

% check warnings
diary('surfNet.txt');

% fields not printable
%surfNet(model, object, metNameFlag, flux, nonzeroFluxFlag, showMets, printFields, charPerLine, similarity)
surfNet(model2, '13dpg[c]', [], [], [], [], {'S'});
surfNet(model2, '13dpg[c]', [], [], [], [], {{}, {'rxnGeneMat'}});
% non-existing met/rxn or incorrect input type
surfNet(model2, 'NOTEXIST');
surfNet({{}});

diary off;

% load the text file
textSurfNet = '';
f = fopen('surfNet.txt', 'r');
l = fgets(f);
while ~isequal(l, -1)
    textSurfNet = [textSurfNet, l];
    l = fgets(f);
end
textSurfNet = regexprep(textSurfNet, '\s*', ' ');
fclose(f);

fprintf('Compare the printed warnings with the expected results ...\n')
assert(contains(textSurfNet, 'Warning: surfNet does not support showing S. Ignore.'))
assert(contains(textSurfNet, 'Warning: surfNet does not support showing rxnGeneMat. Ignore.'))
assert(contains(textSurfNet, 'Warning: No related mets, rxns or genes are found from the search. Please try other query terms.'))
assert(contains(textSurfNet, 'Warning: The query term must be either a string or an array of string.'))
assert(contains(textSurfNet, '''NOTEXIST'' is not a metabolite, reaction or gene of the model. Searching for related objects:'))

fprintf('\nSuccess. Finish testing warning output of surfNet.\n')

% remove the generated file
delete('surfNet.txt');

% print a random reaction when the 2nd input 'metrxn' is not given and
% no objective reactions exist.
fprintf('Test printing random reactions ...\n')
model2.c(:) = 0;
surfNet(model2)
surfNet(model2, [], [], fluxMatrix);

fprintf('Test error messages ...\n')
% error messages
% no initialized model exists
clear surfNet
try
    surfNet();
    assert(false)
catch ME
    assert(strcmp(ME.message, 'The persistent variable modelLocal in surfNet is empty. Please supply a COBRA model.'))
end

% incorrect flux matrix input
try
    surfNet(model2, 'fdp[c]', [], fluxMatrix(1:(end - 1), :));
    assert(false)
catch ME
    assert(strcmp(ME.message, 'Input flux vector has incorrect dimension.'))
end

% add two fields with incorrect size and unsupported datatype
[model2.rxnABC, model2.metABC] = deal(repmat(struct(), n - 1, 2), repmat(struct(), m - 1, 2));
incorrectFieldInput = {{'NOTEXIST'}; 'description'; {'rxnABC', 'metABC'}; 0};
% nonexistent fields
errMsg = {'The following field(s) is(are) not in the model: NOTEXIST'; ...
    ... % unrecognizable fields
    'The following field(s) cannot be recognized as met or rxn field(s): description'; ...
    ... % incorrect size and data type
    sprintf(['Incorrect size of the following met field(s): metABC\n', ...
    'The following met field(s) is(are) neither numeric nor cell array of characters: metABC\n', ...
    'Incorrect size of the following rxn field(s): rxnABC\n', ...
    'The following rxn field(s) is(are) neither numeric nor cell array of characters: rxnABC']); ...
    ... % incorrect input format
    ['The value of ''printFields'' is invalid. Must be (1) a cell array of two cells, ', ...
    '1st cell being a character array for met fields and 2nd for rxn fields, ', ...
    'or (2) a character array of field names recognizable from the field names or the sizes.']};
for j = 1:numel(incorrectFieldInput)
    try
        surfNet(model2, 'fdp[c]', [], [], [], [], incorrectFieldInput{j});
        assert(false)
    catch ME
        assert(strcmp(ME.message, errMsg{j}))
    end
end

fprintf('\nSuccess. Finish testing error messages of surfNet.\n')

% test name-value pair input
for j = 1:3
    if exist(['surfNet' num2str(j) '.txt'], 'file')
        delete(['surfNet' num2str(j) '.txt']);
    end
end
surfNet(model, metrxn);

for j = 1:3
    if exist(['surfNet' num2str(j) '.txt'], 'file')
        delete(['surfNet' num2str(j) '.txt'])
    end
end

% reference data
diary('surfNet1.txt')
surfNet(model, 'GAPD');
surfNet([], [], [], [], [], 0);
% print a list of reactions without showing details of metabolites
surfNet(model, {'GAPD'; 'FBA'}, [], [], [], 0);
% print *.metNames in reaction formulae
surfNet(model, {'13dpg[c]'; 'GAPD'}, 1);
% print with a fixed number of characters per line
surfNet(model, [model.mets(1:10)'; model.rxns(1:10)'], [], [], [], 0, [], 60);
surfNet(model, 'pyr[c]', [], s.x, 0);
surfNet(model, 'pyr[c]', [], s.x);
surfNet(model, rxnsDiff, [], fluxMatrix, [], 0);
surfNet(model2, '13dpg[c]', [], [], [], [], {'default', 'lb', 'subSystems'});
diary off

% name-value pair input
diary('surfNet2.txt')
surfNet(model, 'GAPD');
surfNet('showMets', 0);
surfNet(model, {'GAPD'; 'FBA'}, 'showMets', 0)
surfNet(model, {'13dpg[c]'; 'GAPD'}, 'metNameFlag', 1);
surfNet(model, [model.mets(1:10)'; model.rxns(1:10)'], 'showMets', 0, 'charPerLine', 60);
surfNet(model, 'pyr[c]', 'flux', s.x, 'nonzeroFluxFlag', 0);
surfNet(model, 'pyr[c]', 'flux', s.x);
surfNet(model, rxnsDiff, 'flux', fluxMatrix, 'showMets', 0);
surfNet(model2, '13dpg[c]', 'printFields', {'default', 'lb', 'subSystems'});
diary off

% name-value pair input with partial matching
diary('surfNet3.txt')
surfNet(model, 'GAPD');
surfNet('s', 0);
surfNet(model, {'GAPD'; 'FBA'}, 's', 0)
surfNet(model, {'13dpg[c]'; 'GAPD'}, 'm', 1);
surfNet(model, [model.mets(1:10)'; model.rxns(1:10)'], 's', 0, 'c', 60);
surfNet(model, 'pyr[c]', 'f', s.x, 'n', 0);
surfNet(model, 'pyr[c]', 'f', s.x);
surfNet(model, rxnsDiff, 'f', fluxMatrix, 's', 0);
surfNet(model2, '13dpg[c]', 'p', {'d', 'lb', 'sub'});
diary off

textSurfNet = repmat({''}, 3, 1);
for j = 1:3
    f = fopen(['surfNet' num2str(j) '.txt'], 'r');
    l = fgets(f);
    while ~isequal(l, -1)
        textSurfNet{j} = [textSurfNet{j}, l];
        l = fgets(f);
    end
    fclose(f);
    delete(['surfNet' num2str(j) '.txt']);
end
assert(isequal(textSurfNet{1}, textSurfNet{2}))
assert(isequal(textSurfNet{1}, textSurfNet{3}))

%% too many input arguments are refused
assert(verifyCobraFunctionError('surfNet', 'inputs', {model, 'GAPD', 0, [], 0, 1, [], 0, 0.8, [], 1}, ...
    'testMessage', 'Too many input arguments'));

%% a list with an unknown term shows the known terms first and then searches for the others
printed = evalc('surfNet(model, {''NOTEXIST''; ''GAPD''})');
assert(strfind(printed, 'Rxn #') < strfind(printed, '''NOTEXIST'' is not a metabolite'));

%% a nonzeroFluxFlag between 0 and 1 is the tolerance for nonzero fluxes
sparseFlux = zeros(numel(model.rxns), 1);
sparseFlux(strcmp(model.rxns, 'PYK')) = 0.1;
sparseFlux(strcmp(model.rxns, 'PDH')) = 2;
printed = evalc('surfNet(model, ''pyr[c]'', ''flux'', sparseFlux, ''nonzeroFluxFlag'', 0.5)');
assert(contains(printed, 'PDH'));
assert(~contains(printed, 'PYK'));

%% a model without GPR information prints no GPR, for the default and for a given field list
modelNoGpr = rmfield(model, {'grRules', 'rules'});
printed = evalc('surfNet(modelNoGpr, ''GAPD'')');
assert(contains(printed, 'Rxn #') && ~contains(printed, 'grRules'));
printed = evalc('surfNet(modelNoGpr, ''GAPD'', ''printFields'', {''lb'', ''grRules''})');
assert(contains(printed, 'LB: -1000') && ~contains(printed, 'grRules'));

%% partial field names may also be given per object type
printed = evalc('surfNet(model, ''GAPD'', ''printFields'', {{''metFor''}, {''rxnNa''}})');
assert(contains(printed, 'glyceraldehyde-3-phosphate dehydrogenase'));
assert(contains(printed, 'C3H5O6P'));

%% a partial field name that fits several fields is refused
errorMessage = '';
try
    surfNet(model, 'GAPD', 'printFields', {'met'});
catch ME
    errorMessage = ME.message;
end
assert(contains(errorMessage, 'The partial input "met" matches to >1 fields: mets, metFormulas, metNames'));

%% a search with one bound shows only that bound
printed = evalc('surfNet(model, ''glucose'', ''t'', 0.6, ''printFields'', {''lb''})');
assert(contains(printed, 'LB, matches') && ~contains(printed, 'UB'));
printed = evalc('surfNet(model, ''glucose'', ''t'', 0.6, ''printFields'', {''ub''})');
assert(contains(printed, 'UB, matches') && ~contains(printed, 'LB'));

%% a search can also find genes, without or with gene fields of the model
printed = evalc('surfNet(model, ''b124'', ''t'', 0.6)');
assert(contains(printed, 'Gene   matches'));
assert(contains(printed, 'genes:b1241'));
modelGeneNames = model;
modelGeneNames.geneNames = strcat('name', model.genes);
modelGeneNames.geneFamily = model.genes;
printed = evalc('surfNet(modelGeneNames, ''b124'', ''t'', 0.6)');
assert(contains(printed, 'geneNames, geneFamily, matches'));
assert(contains(printed, 'nameb1241'));

%% a gene that findRxnsFromGenes cannot find under its name shows no reactions
printed = evalc('surfNet(modelGeneNames, ''b1241'')');
assert(contains(printed, 'Gene #') && contains(printed, 'none'));

%% the reactions of a gene are shown with fluxes and with each single bound
% the reaction names are hyperlinks, which are taken out to read the line
removeLinks = @(text) regexprep(text, '<a href="[^"]*">|</a>', '');
printed = evalc('surfNet(model, ''b1241'', ''flux'', sparseFlux)');
assert(contains(removeLinks(printed), 'ACALD (0)'));
printed = evalc('surfNet(model, ''b1241'', ''printFields'', {''lb''})');
assert(contains(removeLinks(printed), 'ACALD, LB: -1000'));
printed = evalc('surfNet(model, ''b1241'', ''printFields'', {''ub''})');
assert(contains(removeLinks(printed), 'ACALD, UB: 1000'));

%% an identifier used for a reaction and a metabolite shows the reaction, with a warning
modelSameName = model;
modelSameName.mets{1} = 'GAPD';
lastwarn('');
printed = evalc('surfNet(modelSameName, ''GAPD'')');
assert(contains(lastwarn, 'GAPD corresponds to a rxn, met at the same time'));
assert(contains(printed, 'Rxn #'));

%% a very small stoichiometric coefficient is printed in exponential notation
modelTiny = model;
modelTiny.S(findMetIDs(model, '13dpg[c]'), findRxnIDs(model, 'GAPD')) = 1e-8;
printed = evalc('surfNet(modelTiny, ''GAPD'')');
assert(contains(printed, '1.00e-08'));

fprintf('Done.\n');
fprintf('testSurfNet passed successfully.\n');

% change the directory
cd(currentDir)
