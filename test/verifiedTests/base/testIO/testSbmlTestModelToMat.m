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
mkdir 'm_model_collection'
cd([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'base', filesep, 'testIO', filesep, 'm_model_collection']);
copyfile(strcat([CBTDIR, filesep, 'test', filesep, 'models', filesep], 'Abiotrophia_defectiva_ATCC_49176.xml'));
%copyfile(strcat([CBTDIR, filesep, 'test', filesep, 'models', filesep], 'Abiotrophia_defectiva_ATCC_49176.mat'));
copyfile(strcat([CBTDIR, filesep, 'test', filesep, 'models', filesep], 'Sc_iND750_flux1.xml'));

% function outputs
CBTDIR = [];
sbmlTestModelToMat();
tmp = which('initCobraToolbox');
CBTDIR = tmp(1:end - length('/initCobraToolbox.m'));

% test
assert((exist('m_model_collection') == 7));
cd([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'base', filesep, 'testIO', filesep, 'm_model_collection']);
assert((exist('Abiotrophia_defectiva_ATCC_49176.xml') == 2));
%assert((exist('Abiotrophia_defectiva_ATCC_49176.mat') == 2));
assert((exist('Sc_iND750_flux1.xml') == 2));
cd([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'base', filesep, 'testIO']);

% remove the temporary files
rmdir('m_model_collection', 's');

% change to old directory
cd(currentDir);
