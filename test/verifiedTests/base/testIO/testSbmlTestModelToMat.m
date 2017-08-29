% The COBRAToolbox: testSbmlTestModelToMat.m
%
% Purpose:
%     - test the sbmlTestModelToMat function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSbmlTestModelToMat'));
cd(fileDir);

% test variables
CBTDIR = [];

% function outputs
sbmlTestModelToMat();

% test
x = exist('m_model_collection');
assert(isequal(x, 7));
cd([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'base', filesep, 'testIO', filesep, 'm_model_collection']);
x = exist('Abiotrophia_defectiva_ATCC_49176.xml');
assert(isequal(x, 2));
x = exist('Abiotrophia_defectiva_ATCC_49176.mat');
assert(isequal(x, 2));
x = exist('Sc_iND750_flux1.xml');
assert(isequal(x, 2));
cd([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'base', filesep, 'testIO']);

% change to old directory
cd(currentDir);
