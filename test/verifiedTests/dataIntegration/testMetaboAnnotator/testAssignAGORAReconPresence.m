% The COBRAToolbox: testAssignAGORAReconPresence.m
%
% Purpose:
%     - assignAGORAReconPresence flags each metabolite (or, with reaction = 1, each reaction)
%       of a metabolite structure whose VMHId appears in the AGORA2 table
%       (Metabolites_AGORA2_refined.xlsx or Reactions_AGORA2_refined.xlsx, first column) with
%       Agora2 = 1, and each whose VMHId appears in Recon3D_Dec2017.mat (Recon3D.mets without
%       the compartment suffix, or Recon3D.rxns) with Recon3D = 1, each with a dated source
%       '<file>:automatic:'. Recon3D_Dec2017.mat is loaded from the data folder next to
%       tutorial_MetaboAnnotator when it exists there, otherwise from the search path.
%     - The test writes small AGORA2 tables and Recon3D_Dec2017.mat files by hand into
%       temporary folders and runs the function from them. Each folder also holds an empty
%       tutorial_MetaboAnnotator.m, so that which() finds it in the current folder: the first
%       folder has a data subfolder (the tutorial branch), the second has the MAT file in the
%       folder itself (the search-path branch). The two Recon3D files list different
%       metabolites, which shows which one was loaded. Expected values are the identifiers
%       written (hand derivation). Recon3D identifiers that no metabolite carries are not
%       added to the structure.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/connect2resources/assignAGORAReconPresence.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, a hand-built metabolite structure, spreadsheets and a
%     hand-built Recon3D structure (the shipped Recon3D_Dec2017.mat is not loaded).
%
% Coverage exemptions:
%     Lines 84-108: unreachable (dead code). A Recon3D identifier is a hit only when it is
%     the VMHId of a metabolite of the structure, and the field names searched (line 75) are
%     the field names of that same structure (line 28), so isfield on line 76 is always true.
%     Lines 118-141: unreachable (dead code), the branch is disabled by 'elseif 0' (line 112).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAssignAGORAReconPresence'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the hand-built AGORA2 tables (first column: VMH id; the header row is read as well)
agoraMetRows = {'Abbreviation', 'Name'; 'glc_D', 'D-Glucose'; 'atp', 'ATP'; 'agoraOnly', 'X'};
agoraRxnRows = {'Abbreviation', 'Name'; 'HEX1', 'Hexokinase'; 'agoraRxnOnly', 'X'};

% a Recon3D structure for each folder: the tutorial copy lists glc_D and h2o, the copy on the
% search path lists only h2o; both list a metabolite and a reaction that no entry carries
Recon3D = struct();
Recon3D.mets = {'glc_D[c]'; 'glc_D[e]'; 'h2o[c]'; 'reconOnly[c]'};
Recon3D.metNames = {'D-Glucose'; 'D-Glucose'; 'Water'; 'Recon only'};
Recon3D.rxns = {'HEX1'; 'PGI'; 'EX_glc_D(e)'};
Recon3D.rxnNames = {'Hexokinase'; 'Glucose-6-phosphate isomerase'; 'Exchange'};
tutorialDir = tempname;
mkdir(fullfile(tutorialDir, 'data'));
save(fullfile(tutorialDir, 'data', 'Recon3D_Dec2017.mat'), 'Recon3D');
Recon3D.mets = {'h2o[c]'; 'reconOnly[c]'};
Recon3D.metNames = {'Water'; 'Recon only'};
Recon3D.rxns = {'PGI'};
Recon3D.rxnNames = {'Glucose-6-phosphate isomerase'};
searchPathDir = tempname;
mkdir(searchPathDir);
save(fullfile(searchPathDir, 'Recon3D_Dec2017.mat'), 'Recon3D');
clear Recon3D
for sandboxDir = {tutorialDir, searchPathDir}
    writecell(agoraMetRows, fullfile(sandboxDir{1}, 'Metabolites_AGORA2_refined.xlsx'));
    writecell(agoraRxnRows, fullfile(sandboxDir{1}, 'Reactions_AGORA2_refined.xlsx'));
    % an empty script: which('tutorial_MetaboAnnotator') returns the current folder
    fid = fopen(fullfile(sandboxDir{1}, 'tutorial_MetaboAnnotator.m'), 'w');
    fprintf(fid, '%% placeholder written by testAssignAGORAReconPresence\n');
    fclose(fid);
end

newMetabolite = @(vmhId, name) struct('VMHId', vmhId, 'metNames', name);
metabolites = struct();
metabolites.VMH_glc_D = newMetabolite('glc_D', 'D-Glucose');  % in AGORA2 and Recon3D
metabolites.VMH_h2o = newMetabolite('h2o', 'Water');          % in Recon3D only
metabolites.VMH_xyz = newMetabolite('xyz', 'Unknown');        % in neither

%% metabolites, Recon3D from the data folder of the tutorial (default reaction = 0)

cd(tutorialDir);
annotated = assignAGORAReconPresence(metabolites);

% glc_D is in both sources; the compartment suffix [c] of Recon3D is removed before matching
assert(isequal(annotated.VMH_glc_D.Agora2, 1) && isequal(annotated.VMH_glc_D.Recon3D, 1));
assert(startsWith(annotated.VMH_glc_D.Agora2_source, 'Metabolites_AGORA2_refined.xlsx:automatic:'));
assert(startsWith(annotated.VMH_glc_D.Recon3D_source, 'Recon3D_Dec2017.mat:automatic:'));
% h2o is only in Recon3D, xyz in neither
assert(~isfield(annotated.VMH_h2o, 'Agora2') && isequal(annotated.VMH_h2o.Recon3D, 1));
assert(~isfield(annotated.VMH_xyz, 'Agora2') && ~isfield(annotated.VMH_xyz, 'Recon3D'));
% identifiers of the tables that no metabolite carries are not added
assert(isequal(fieldnames(annotated), fieldnames(metabolites)));

% reaction = 0 given explicitly is the default
annotatedExplicit = assignAGORAReconPresence(metabolites, 0);
assert(isequal(annotatedExplicit.VMH_glc_D.Recon3D, 1) && ~isfield(annotatedExplicit.VMH_xyz, 'Recon3D'));

%% metabolites, Recon3D from the search path (no data folder next to the tutorial)

cd(searchPathDir);
annotated = assignAGORAReconPresence(metabolites);
% this Recon3D lists h2o but not glc_D: the file of the current folder was loaded
assert(isequal(annotated.VMH_h2o.Recon3D, 1) && ~isfield(annotated.VMH_glc_D, 'Recon3D'));
assert(isequal(annotated.VMH_glc_D.Agora2, 1));
assert(isequal(fieldnames(annotated), fieldnames(metabolites)));

%% reactions (reaction = 1)

reactions = struct();
reactions.VMH_HEX1 = struct('VMHId', 'HEX1', 'rxnNames', 'Hexokinase');   % in AGORA2 and Recon3D
reactions.VMH_PGI = struct('VMHId', 'PGI', 'rxnNames', 'Isomerase');      % in Recon3D only
reactions.VMH_ABC = struct('VMHId', 'ABC', 'rxnNames', 'Unknown');        % in neither

cd(tutorialDir);
annotated = assignAGORAReconPresence(reactions, 1);
assert(isequal(annotated.VMH_HEX1.Agora2, 1) && isequal(annotated.VMH_HEX1.Recon3D, 1));
assert(startsWith(annotated.VMH_HEX1.Agora2_source, 'Reactions_AGORA2_refined.xlsx:automatic:'));
assert(startsWith(annotated.VMH_HEX1.Recon3D_source, 'Recon3D_Dec2017.mat:automatic:'));
assert(~isfield(annotated.VMH_PGI, 'Agora2') && isequal(annotated.VMH_PGI.Recon3D, 1));
assert(~isfield(annotated.VMH_ABC, 'Agora2') && ~isfield(annotated.VMH_ABC, 'Recon3D'));
% Recon3D reactions that no entry carries (EX_glc_D(e)) are not added
assert(isequal(fieldnames(annotated), fieldnames(reactions)));

% remove the temporary folders and change the directory
cd(currentDir)
rmdir(tutorialDir, 's');
rmdir(searchPathDir, 's');
