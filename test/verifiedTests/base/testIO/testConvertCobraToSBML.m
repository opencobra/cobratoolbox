% The COBRAToolbox: testConvertCobraToSBML.m
%
% Purpose:
%     - test the convertCobraToSBML function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertCobraToSBML'));
cd(fileDir);

% test variables
sbmlLevel = 0;
sbmlVersion = 0;
compSymbolList = '';
compNameList = '';
model = getDistributedModel('ecoli_core_model.mat');

% function outputs
warning('off', 'all')
  sbmlModel = convertCobraToSBML(model, sbmlLevel, sbmlVersion, compSymbolList, compNameList);
  sbmlModel_2 = convertCobraToSBML(model, sbmlLevel, sbmlVersion);
  assert(length(lastwarn()) > 0)
warning('on', 'all')
% test
assert(isequaln(sbmlModel, sbmlModel_2));

% change to old directory
cd(currentDir);
