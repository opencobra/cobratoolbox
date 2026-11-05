% The COBRAToolbox: testRBioNetSaveLoad.m
%
% Purpose:
%     - testRBioNetSaveLoad tests the functionality of rBioNetSaveLoad  and
%       rBioNet_search in the rBioNet extension
%
% Function under test:
%     src/reconstruction/rBioNet/rBioNetSaveLoad.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver. The sections that change databases use copies in a
%     temporary folder. Message boxes are opened and closed by the test.
%
% Coverage exemptions:
%     None besides the defective input listed below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A wrong path of the compartment database is not detected
%       SEVERITY: error
%       TRIGGER: a settings file with a comp_path that does not exist, followed by
%         rBioNetSaveLoad('load', 'comp')
%       OBSERVED: comp_exist is computed from met_path, so the message about the compartment
%         database can never appear (a wrong met_path stops at the check before it) and the call
%         stops in load with an error about the missing file
%       EXPECTED: the message about the compartment database and an empty output
%       LINES: 45, 57-60
%     - DEFECT: Saving prints the whole database
%       SEVERITY: cosmetic
%       TRIGGER: rBioNetSaveLoad('save', 'met', data)
%       OBSERVED: the assignment in eval has no semicolon, so the data are printed to the console
%       EXPECTED: no output
%       LINES: 77, 87, 97
%
% Authors:
%     - Stefania Magnusdottir April 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRBioNetSaveLoad'));
cd(fileDir);

% this test needs no solver, MATLAB toolbox or particular operating system
prepareTest();

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
        fileSave = rBioNetSaveLoad('save', features{i}, fileLoad);
    elseif strcmp(features{i}, 'met')
        fileSave = rBioNetSaveLoad('save', features{i}, fileLoad);
        metab = fileLoad; % need metab data for rBioNet_search test
    elseif strcmp(features{i}, 'rxn')
        fileSave = rBioNetSaveLoad('save', features{i}, fileLoad);
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

%% the sections below work in a temporary folder, on small databases of their own

tmpDir = tempname;
mkdir(tmpDir);
cd(tmpDir);
compartments = {'first'};
metab = {'first'};
rxn = {'first'};
save('compartments.mat', 'compartments');
save('metab.mat', 'metab');
save('rxn.mat', 'rxn');

%% without a settings file a message is shown and the output is 0

% hide other settings files on the MATLAB path (the tutorials ship one)
settingsFiles = which('-all', 'rBioNetSettingsDB.mat');
settingsFolders = cellfun(@fileparts, settingsFiles, 'UniformOutput', false);
cellfun(@rmpath, settingsFolders);
output = rBioNetSaveLoad('load', 'met');
for i = 1:numel(settingsFolders)
    addpath(settingsFolders{i}, '-end');
end
assert(isequal(output, 0));
assert(contains(closeMessageBoxes(), 'The rBioNetSettings file is not in a set path'));

%% a wrong path of the reaction or metabolite database is reported, and the output is empty

% (the relative paths also take the branch for paths without a slash)
comp_path = 'compartments.mat';
met_path = 'metab.mat';
rxn_path = 'missing.mat';
save('rBioNetSettingsDB.mat', 'comp_path', 'met_path', 'rxn_path')
assert(isempty(rBioNetSaveLoad('load', 'rxn')));
assert(contains(closeMessageBoxes(), 'Path for reaction database is not correct.'));

met_path = 'missing.mat';
rxn_path = 'rxn.mat';
save('rBioNetSettingsDB.mat', 'comp_path', 'met_path', 'rxn_path')
assert(isempty(rBioNetSaveLoad('load', 'met')));
assert(contains(closeMessageBoxes(), 'Path for metabolite database is not correct.'));

%% paths without a slash are saved to and loaded from, for each database

met_path = 'metab.mat';
save('rBioNetSettingsDB.mat', 'comp_path', 'met_path', 'rxn_path')
for i = 1:length(features)
    assert(isequal(rBioNetSaveLoad('load', features{i}), {'first'}));
    assert(isequal(rBioNetSaveLoad('save', features{i}, {'second'}), 1));
    assert(isequal(rBioNetSaveLoad('load', features{i}), {'second'}));
end

%% saving without data shows a message, and the output is 0

assert(isequal(rBioNetSaveLoad('save', 'met'), 0));
assert(contains(closeMessageBoxes(), 'No data to save specified.'));
assert(isequal(rBioNetSaveLoad('load', 'met'), {'second'}));

%% an unknown type or mode gives the output 0

assert(isequal(rBioNetSaveLoad('save', 'unknown', {'third'}), 0));
assert(isequal(rBioNetSaveLoad('load', 'unknown'), 0));
assert(isequal(rBioNetSaveLoad('unknown', 'met'), 0));

% remove the temporary folder and its settings file
cd(fileDir);
rmdir(tmpDir, 's');

% remove git tracking
system('git checkout -- compartments.mat')
system('git checkout -- metab.mat')
system('git checkout -- rxn.mat')

% change the directory
cd(currentDir)

function boxText = closeMessageBoxes()
% Returns the text of the open message boxes and closes them, so that no window stays open.
boxes = findall(0, 'Type', 'figure', '-regexp', 'Tag', '^Msgbox_');
boxText = '';
for iBox = 1:numel(boxes)
    boxLines = cellstr(get(findall(boxes(iBox), 'Type', 'text'), 'String'));
    boxText = [boxText, ' ', strjoin(strtrim(boxLines), ' ')];
end
delete(boxes);
end
