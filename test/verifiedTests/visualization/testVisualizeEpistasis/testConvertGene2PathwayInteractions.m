% % The COBRAToolbox: testConvertGene2PathwayInteractions.m
% %
% % Purpose:
% %     - testConvertGene2PathwayInteractions tests the whether convertGene2PathwayInteractions
% %     is working correctly
% %
% % Author:
% %     - Original file: Chintan J Joshi - 11/29/2018
%
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertGene2PathwayInteractions'));
cd(fileDir);

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
fprintf('Done!\n');

% change the directory
cd(currentDir)
