% The COBRAToolbox: testElementalBalance.m
%
% Purpose:
%     - Tests computeMW functionality
%
% Authors:
%     - CI integration: Laurent Heirendt

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testElementalBalance'));
cd(fileDir);

% load the model and data
load('testElementalBalanceData.mat');

% run elmental balance with no optional functions
[MW, Ematrix] = computeMW(model);

% check that the molecular weights have been calculated properly
assert(isequal(MW, stdMW))

% check that the Ematrix has been computed correctly
assert(isequal(Ematrix, stdEmatrix))

% run computeMW with a specific met list
[MW, Ematrix, elements, knownWeights, unknownElements] = computeMW(model, model.mets(25:35), false);

% check that the molecular weights have been calculated properly
assert(isequal(MW, stdMW2))

% check that the Ematrix has been computed correctly
assert(isequal(Ematrix, stdEmatrix2))

% check the list of returned elements
assert(isequal(elements, {'C', 'N', 'O', 'H', 'P', 'Other'}))

% empty knownWeights and unknownElements (non-empty only if the genericFomrula 
% flag is turned on)
assert(isempty(knownWeights) & isempty(unknownElements))

% check warning message
model = addMetabolite(model, 'uranium[c]', 'metFormula', 'U');
diary('testElementBalance_warning.txt')
computeMW(model, 'uranium[c]');
diary off
f = fopen('testElementBalance_warning.txt', 'r');
l = fgets(f);
text = '';
while ~isequal(l, -1)
    text = [text, l];
    l = fgets(f);
end
fclose(f);
delete('testElementBalance_warning.txt')
% the warning should contain the following:
re = regexp(text, 'formula \=');
assert(~isempty(re))
text = text(re:end);
re = regexp(text, '''U''');
assert(~isempty(re))
text = text(re:end);
re = regexp(text, 'comp \=');
assert(~isempty(re))
text = text(re:end);
re = regexp(text, 'U');
assert(~isempty(re))

% test genericFormula = true
model = addMetabolite(model, 'hypothetical1[c]', 'metFormula', '((CH2O)3H2O)2H2O');
nMets = numel(model.mets);
model = addMetabolite(model, 'hypothetical2[c]', 'metFormula', '(H2O)2CuSO4Element2');
model = addMetabolite(model, 'hypothetical3[c]', 'metFormula', 'C0H0');
model = addMetabolite(model, 'photon[c]', 'metFormula', 'Mass0');
[MW, Ematrix, elements, knownWeights, unknownElements] = computeMW(model, [], false, true);
% check weights
assert(all(isnan(MW) == isnan(stdMW3)) && max(abs(MW(~isnan(MW)) - stdMW3(~isnan(MW)))) < 1e-5)
% check elements and Ematrix
[yn, id] = ismember(elements, {'C', 'H', 'O', 'P', 'N', 'S', 'U', 'Cu', 'Element', 'Mass'});
assert(all(yn) & numel(elements) == 10)
assert(isequal(Ematrix, stdEmatrix3(:, id)))
% check weights for the known part
assert(all(knownWeights(1:nMets) == MW(1:nMets)))
assert(abs(knownWeights(nMets + 1) - 195.6392) < 1e-4)
assert(all(knownWeights(nMets + (2:3)) == 0))
% check unknownElements
assert(isequal(sort({'Element', 'Mass'}), sort(unknownElements)))

% change the directory
cd(currentDir)
