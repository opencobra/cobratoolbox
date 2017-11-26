% The COBRAToolbox: testSurfNet.m
%
% Purpose:
%     - testSurfNet tests the functionality of surfNet
%       and compares it to expected data.
%
% Authors:
%     - Lemmer El Assal March 2017
%     - Siu Hung Joshua Chan July 2017
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSurfNet'));
cd(fileDir);

model = getDistributedModel('ecoli_core_model.mat');

% generate flux data for testing
s = optimizeCbModel(model, 'max', 'one');
model2 = changeRxnBounds(model, {'EX_glc(e)'; 'EX_fru(e)'}, [0; -10], {'L'; 'L'});
s2 = optimizeCbModel(model2, 'max', 'one');
fluxMatrix = [s.x, s2.x];
rxnsDiff = model.rxns(abs(fluxMatrix(:, 1) - fluxMatrix(:, 2)) > 1e-6);
[m, n] = size(model2.S);

% remove old generated file
delete('surfNet.txt');

% check normal functionalities
diary('surfNet.txt');

% start with a metabolite
metrxn = '13dpg[c]';
surfNet(model, metrxn);
% continue with a reaction
surfNet([], 'GAPD', 0, 'none', 0, 1, [], 0);
% continue with a metabolite
surfNet([], 'g3p[c]', 0, 'none', 0, 1, [], 0);
% print objective reactions given no second input
surfNet(model);
% print a list of reactions without showing details of metabolites
surfNet(model, {'GAPD'; 'FBA'}, [], [], [], 0);
% print *.metNames in reaction formulae
surfNet(model, {'13dpg[c]'; 'GAPD'}, 1);
% show previous steps
surfNet([], [], 1, 'none', 0, 1, [], 0, struct('showPrev', true));

% print with a fixed number of characters per line
surfNet(model, [model.mets(1:10)'; model.rxns(1:10)'], [], [], [], 0, [], 60);
% show previous steps
surfNet([], [], 0, 'none', 0, 0, [], 60, struct('showPrev', true));

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
surfNet(model2, {'13dpg[c]'; 'GAPD'}, [], [], [], [], {{}, {'lb'}});

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
assert(score > 1 - 1e-3);  % some mismatches due to linebreaks and space
fprintf('\nSuccess. Finish testing normal functionalities of surfNet.\n')

% check warnings
diary('surfNet.txt');

% fields not printablable
surfNet(model2, '13dpg[c]', [], [], [], [], {'S'});
surfNet(model2, '13dpg[c]', [], [], [], [], {{}, {'rxnGeneMat'}});
% non-existing met/rxn
surfNet(model2, 'NOTEXIST');

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
% remove the generated file
delete('surfNet.txt');

fprintf('Compare the printed warnings with the expected results ...\n')
assert(~isempty(strfind(textSurfNet, 'Warning: surfNet does not support showing S. Ignore.')))
assert(~isempty(strfind(textSurfNet, 'Warning: surfNet does not support showing rxnGeneMat. Ignore.')))
assert(~isempty(strfind(textSurfNet, 'Warning: The 2nd input is neither a metabolite nor reaction of the model.')))
fprintf('\nSuccess. Finish testing warning output of surfNet.\n')

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
    surfNet;
    assert(false)
catch ME
    assert(strcmp(ME.message, 'The persistent variable modelLocal in surfNet has been cleared. Please re-call the function.'))
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
    ['Incorrect input for field2print. Must be (1) a cell array of two cells, ', ...
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

% change the directory
cd(currentDir)
