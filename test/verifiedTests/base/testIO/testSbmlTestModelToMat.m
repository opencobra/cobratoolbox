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
CBTDIR = [];
sbmlTestModelToMat();
CBTDIR = fileparts(which('initCobraToolbox'));

% test
assert((exist('m_model_collection') == 7));
cd([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'base', filesep, 'testIO', filesep, 'm_model_collection']);
assert((exist('Abiotrophia_defectiva_ATCC_49176.xml') == 2));
assert((exist('Sc_iND750_flux1.xml') == 2));
cd([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'base', filesep, 'testIO']);

% remove the temporary files and 'm_model_collection' folder - loop for windows because apparently 'rmdir' fails sometimes
isdeleted = false;
k = 0;
while ~isdeleted && k < 10
    try
        rmdir('m_model_collection','s');
        isdeleted = true;
    catch
        k = k + 1; % increase counter for timeout
        pause(1); %wait a second before retry
        rehash;
    end
end

% change to old directory
cd(currentDir);
