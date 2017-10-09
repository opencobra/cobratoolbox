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
% creating the default folder 'm_model_collection' for function call without input arguments, copying xml files to be worked on to this folder
mkdir 'm_model_collection'
cd([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'base', filesep, 'testIO', filesep, 'm_model_collection']);
copyfile(strcat([CBTDIR, filesep, 'test', filesep, 'models', filesep], 'Abiotrophia_defectiva_ATCC_49176.xml'));
% copying xml file as mat file so that it will be deleted by the function
copyfile(strcat([CBTDIR, filesep, 'test', filesep, 'models', filesep], 'Abiotrophia_defectiva_ATCC_49176.xml'), 'Abiotrophia_defectiva_ATCC_49176.mat');
copyfile(strcat([CBTDIR, filesep, 'test', filesep, 'models', filesep], 'Sc_iND750_flux1.xml'));
cd([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'base', filesep, 'testIO']);

% function outputs
% emptying CBTDIR global variable so that the function can recreate that
clear CBTDIR
sbmlTestModelToMat();
CBTDIR = fileparts(which('initCobraToolbox'));

% test
assert((exist('m_model_collection') == 7));
cd([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'base', filesep, 'testIO', filesep, 'm_model_collection']);
assert((exist('Abiotrophia_defectiva_ATCC_49176.xml') == 2));
assert((exist('Sc_iND750_flux1.xml') == 2));
cd([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'base', filesep, 'testIO']);

% since rmdir fails on windows it will be ignored and added to .gitignore
if isunix
try
rmdir('m_model_collection','s')
end
end

% back to old directory
cd(currentDir);
