% % The COBRAToolbox: testFindSubsystemOfGenes.m
% %
% % Purpose:
% %     - testFindSubsystemOfGenes tests the whether findSubystemOfGenes
% %     is working correctly
% %
% % Author:
% %     - Original file: Chintan J Joshi - 11/29/2018
%
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindSubsystemOfGenes'));
cd(fileDir);

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
fprintf('Done!\n');

% change the directory
cd(currentDir)
