% The COBRAToolbox: testFindSubsystemOfGenes.m
%
% Purpose:
%     - testFindSubsystemOfGenes tests the whether findSubystemOfGenes
%     is working correctly
%
% Function under test:
%     src/visualization/visualizeEpistasis/findSubsystemOfGenes.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; stored E. coli model.
%
% Coverage exemptions:
%     Lines 98, 104: unreachable, the private subfunction convertMyCell2List has one caller,
%     which always passes dimSense = 2.
%     Lines 127, 130, 141-144, 146-147: unreachable, the private subfunction findRxnsConstrained
%     has one caller, which always passes the genes and verbFlag = false.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Only the last reaction of a gene gives its subsystem
%       SEVERITY: wrong-result
%       TRIGGER: a gene that catalyses reactions in more than one subsystem
%       OBSERVED: the loop over the reactions of the gene overwrites rxnInds, so subs and
%         subsys hold the subsystem of its last reaction only
%       EXPECTED: the subsystems of all the reactions of the gene, as the output description
%         and the comment on checking all the reactions state
%       LINES: 46-48, 50
%     - DEFECT: A reaction with several subsystems stops with an error
%       SEVERITY: error
%       TRIGGER: model.subSystems as a cell array of cell arrays, with a reaction that holds two
%         subsystems
%       OBSERVED: the gene gets a cell inside a cell, which convertMyCell2List passes on, and
%         unique fails because the list is not a cell array of character vectors
%       EXPECTED: the subsystems of the gene are listed one by one
%       LINES: 56, 60
%
% Author:
%     - Original file: Chintan J Joshi - 11/29/2018
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindSubsystemOfGenes'));
cd(fileDir);

% no solver or toolbox is needed
prepareTest();

% get the inputs
Coli = readCbModel('refData_visualizeEpistasis.mat','modelName','Coli');
load('refData_visualizeEpistasis.mat', 'genesColi');

% get the outputs
load('refData_visualizeEpistasis.mat','rxns','subsys','subsysGenes','usys');

% list of solver packages: none needed

% run findSubsystemOfGenes
[rxns1,subsys1,subsysGenes1,usys1] = findSubsystemOfGenes(Coli,genesColi);

fprintf('Testing findSubsystemOfGenes...');
% check the first output
for i=1:length(rxns)
    assert(sum(ismember(rxns{i},rxns1{i}))==length(rxns{i}));
end
% check the second output
for i=1:length(subsys)
    assert(sum(ismember(subsys{i},subsys1{i}))==length(subsys{i}));
end
% check the third output
for i=1:length(subsysGenes)
    assert(sum(ismember(subsysGenes{i},subsysGenes1{i}))==length(subsysGenes{i}));
end
% check the fourth output
for i=1:length(usys)
    assert(sum(ismember(usys{i},usys1{i}))==length(usys{i}));
end

% without the second input the genes of the model are used
[rxnsAll, subsysAll, ~, usysAll, geneCountAll, rxnNamesAll] = findSubsystemOfGenes(Coli);
[rxnsExplicit, subsysExplicit] = findSubsystemOfGenes(Coli, Coli.genes);
assert(numel(rxnsAll) == numel(Coli.genes));
assert(isequal(rxnsAll, rxnsExplicit) && isequal(subsysAll, subsysExplicit));
assert(issorted(geneCountAll) && numel(geneCountAll) == numel(usysAll));
assert(numel(rxnNamesAll) == numel(Coli.genes));
assert(numel(rxnNamesAll{1}) == numel(rxnsAll{1}));

% subsystems as a cell array of cell arrays, the current model format, give the same result
ColiCell = Coli;
ColiCell.subSystems = cellfun(@(x) {x}, Coli.subSystems, 'UniformOutput', false);
[~, subsysCell, ~, usysCell] = findSubsystemOfGenes(ColiCell, genesColi);
assert(isequal(subsysCell, subsys1) && isequal(usysCell, usys1));
fprintf('Done!\n');

% change the directory
cd(currentDir)
