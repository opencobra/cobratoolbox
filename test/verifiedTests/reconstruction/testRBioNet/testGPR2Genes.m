% The COBRAToolbox: testGPR2Genes.m
%
% Purpose:
%     - testGPR2Genes tests the functionality of GPR2Genes in the
%     rBioNet extension
%
% Authors:
%     - Stefania Magnusdottir April 2017
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGPR2Genes'));
cd(fileDir);

% load E. coli model
model = getDistributedModel('ecoli_core_model.mat');

% extract genes from grRules
Genes = GPR2Genes(model.grRules);

% test output
assert(isequal(model.genes, Genes'))

% change the directory
cd(currentDir)
