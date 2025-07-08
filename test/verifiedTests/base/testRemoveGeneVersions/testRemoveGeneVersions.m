% The COBRAToolbox: testRemoveGeneVersions.m
%
% Purpose:
%     - Test the removeGeneVersions function to ensure it correctly removes
%       gene versions and updates model.genes, model.grRules, model.rules,
%       and model.rxnGeneMat.
%
% Authors:
%     - Initial version: Farid Zare, April 2025
%

global CBTDIR

% Save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% Determine the test path for references
testPath = pwd;


% Load a test model.
% For testing, we create a dummy model with versioned gene and grRules fields.
% Create a minimal test model if getDistributedModel does not return one.
model = struct();
model.rxns    = {'R1'; 'R2'; 'R3'; 'R4'};
model.genes   = {'857.1'; '34.1'; '45.1'; '857.1'; '451.1'; '857.2'; '451.2'};
model.grRules = {'(857.1 and 34.1) or 45.1'; '(857.1 and 451.1) or (857.2 and 451.2)'; '45.1 and (451.1 or 857.2)'; '(45.1 or 34.1) and (451.1 or 857.2)'};

% Expected reference values:
% After removing versions and duplicates, we expect:
ref_genes = {'857'; '34'; '45'; '451'};
ref_grRules = { '(857 and 34) or (45)'; '(857 and 451)'; '(45 and 451) or (857 and 45)'; '(45 and 451) or (34 and 451) or (857 and 45) or (857 and 34)'};
ref_rules = {'( x(1) & x(2) ) | ( x(3) )'; '( x(1) & x(4) )'; '( x(3) & x(4) ) | ( x(1) & x(3) )'; '( x(3) & x(4) ) | ( x(2) & x(4) ) | ( x(1) & x(3) ) | ( x(1) & x(2) )'};
ref_rxnGeneMat = sparse([1, 1, 1, 0; 1, 0, 0, 1; 1, 0, 1, 1; 1, 1, 1, 1]);

fprintf(' -- Running testRemoveGeneVersions: ... ');

% Run the function under test
modelOut = removeGeneVersions(model);

% Assert that modelOut.genes matches the expected output
assert(isequal(modelOut.genes, ref_genes), ...
    'Test failed: modelOut.genes does not match the expected output.');

% Assert that modelOut.grRules matches the expected output
assert(isequal(modelOut.grRules, ref_grRules), ...
    'Test failed: modelOut.grRules does not match the expected output.');

% Assert that modelOut.rules matches the expected output
assert(isequal(modelOut.rules, ref_rules), ...
    'Test failed: modelOut.rules does not match the expected output.');

% Assert that rxnGeneMat matches the expected output
assert(isequal(modelOut.rxnGeneMat, ref_rxnGeneMat), ...
    'Test failed: modelOut.rxnGeneMat does not match the expected output');

fprintf('Done.\n');


% Change back to the original directory
cd(currentDir);
