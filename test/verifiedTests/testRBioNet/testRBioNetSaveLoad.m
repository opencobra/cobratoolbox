% The COBRAToolbox: testRBioNetSaveLoad.m
%
% Purpose:
%     - testRBioNetSaveLoad tests the functionality of rBioNetSaveLoad  and
%       rBioNet_search in the rBioNet extension
%
% Authors:
%     - Stefania Magnusdottir April 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRBioNetSaveLoad'));
cd(fileDir);

%TEST: rBioNetSaveLoad
% paths to rBioNet database files
comp_path = [fileDir, filesep 'compartments.mat'];
met_path = [fileDir, filesep 'metab.mat'];
rxn_path = [fileDir, filesep 'rxn.mat'];

% save rBioNet settings file
save([fileDir, filesep 'rBioNetSettingsDB.mat'], 'comp_path', 'met_path', 'rxn_path')

% define inputs
features = {'comp', 'met', 'rxn'};

% load and save files
for i = 1:length(features)
    % load file
    fileLoad = rBioNetSaveLoad('load', features{i});
    
    % test if loaded file 
    assert(~isempty(fileLoad))

    % save file
    if strcmp(features{i}, 'comp')
        fileSave = rBioNetSaveLoad('save', features{i}, compartments);
    elseif strcmp(features{i}, 'met')
        fileSave = rBioNetSaveLoad('save', features{i}, metab);
    elseif strcmp(features{i}, 'rxn')
        fileSave = rBioNetSaveLoad('save', features{i}, rxn);
    end
    
    % test if saved file
    assert(logical(fileSave))
end

%TEST: rBioNet_search, needs rBioNetSettings file
% exact match
output = rBioNet_search(metab, 2, 'Urea', 1);

% test that output is correct
for i = 1:size(output, 2)
    assert(isequal(output(1, i), metab(find(ismember(metab(:, 2), 'Urea')), i)))
end

% delete rBioNet settings file
delete([fileDir, filesep 'rBioNetSettingsDB.mat'])

% change the directory
cd(currentDir)
