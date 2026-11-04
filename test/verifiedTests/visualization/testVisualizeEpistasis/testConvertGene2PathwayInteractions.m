% The COBRAToolbox: testConvertGene2PathwayInteractions.m
%
% Purpose:
%     - testConvertGene2PathwayInteractions tests the whether convertGene2PathwayInteractions
%     is working correctly
%
% Function under test:
%     src/visualization/visualizeEpistasis/convertGene2PathwayInteractions.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no solver; stored reference data.
%
% Coverage exemptions:
%     Lines 67, 73: unreachable, the private subfunction convertMyCell2List has one caller,
%     which always passes dimSense = 2.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Author:
%     - Original file: Chintan J Joshi - 11/29/2018
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertGene2PathwayInteractions'));
cd(fileDir);

% no solver or toolbox is needed
prepareTest();

% get the inputs
load('refData_visualizeEpistasis.mat', 'epiColi','subsys','usys');

% get the outputs
load('refData_visualizeEpistasis.mat','Nall');

% list of solver packages: none needed

% run convertGene2PathwayInteractions
[Nall1.neg,Nall1.zer,Nall1.nd,Nall1.pos] = convertGene2PathwayInteractions(epiColi.sE,subsys,usys);

fprintf('Testing conversion of genes interactions to pathway interactions...');
% check the first output
assert(sum(sum(Nall1.neg~=Nall.neg))==0);
% check the second output
assert(sum(sum(Nall1.zer~=Nall.zer))==0);
% check the third output
assert(sum(sum(Nall1.nd~=Nall.nd))==0);
% check the fourth output
assert(sum(sum(Nall1.pos~=Nall.pos))==0);

% without the third input the unique subsystems are taken from the second input
assert(isequal(sort(usys), unique(cellfun(@(x) x{1}, subsys, 'UniformOutput', false))));
[Nall2.neg, Nall2.zer, Nall2.nd, Nall2.pos] = convertGene2PathwayInteractions(epiColi.sE, subsys);
assert(isequal(Nall2, Nall1));
fprintf('Done!\n');

% change the directory
cd(currentDir)
